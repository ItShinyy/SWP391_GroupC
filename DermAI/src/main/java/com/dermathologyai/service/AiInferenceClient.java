package com.dermathologyai.service;

import com.dermathologyai.config.AppConfig;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.Duration;
import java.util.Base64;

/** Java → FastAPI screening client. Active package is loaded by FastAPI from active/. */
public class AiInferenceClient {
    private static final Gson GSON = new Gson();
    private static final SecureRandom NONCE_RANDOM = new SecureRandom();
    private final HttpClient httpClient = HttpClient.newBuilder()
        .version(HttpClient.Version.HTTP_1_1)
        .connectTimeout(Duration.ofMillis(AppConfig.getInt("ai.connect.timeout.ms", 3000)))
        .build();

    public ScreeningResponse screen(String attemptId, NormalizedImage image) throws AiInferenceException {
        if (!AppConfig.getBoolean("ai.service.enabled", false)) {
            throw new AiInferenceException("AI screening is not enabled in this environment.");
        }
        JsonObject body = new JsonObject();
        body.addProperty("attemptId", attemptId);
        body.addProperty("inputSha256", image.sha256());
        body.addProperty("imageBase64", Base64.getEncoder().encodeToString(image.bytes()));
        HttpRequest request = HttpRequest.newBuilder(internalUri("/internal/screenings"))
            .timeout(Duration.ofMillis(AppConfig.getInt("ai.read.timeout.ms", 60000)))
            .header("Content-Type", "application/json")
            .header("X-AI-Service-Key", AppConfig.require("ai.service.api.key"))
            .header("X-AI-Request-Nonce", nonce())
            .header("X-AI-Request-Timestamp", Long.toString(System.currentTimeMillis() / 1000))
            .POST(HttpRequest.BodyPublishers.ofString(GSON.toJson(body), StandardCharsets.UTF_8))
            .build();
        try {
            HttpResponse<InputStream> response = httpClient.send(request, HttpResponse.BodyHandlers.ofInputStream());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new AiInferenceException(
                    "The screening service did not accept the request (HTTP " + response.statusCode()
                        + detailSuffix(response.body()) + ")."
                );
            }
            byte[] responseBody;
            try (InputStream stream = response.body()) {
                responseBody = readBounded(stream, AppConfig.getInt("ai.max.response.bytes", 15 * 1024 * 1024));
            }
            ScreeningResponse result = fromJson(new String(responseBody, StandardCharsets.UTF_8));
            result.verify(attemptId, image.sha256());
            return result;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new AiInferenceException("The screening request was interrupted.", e);
        } catch (IOException | IllegalArgumentException e) {
            throw new AiInferenceException("The screening service is unavailable.", e);
        }
    }

    private static String detailSuffix(InputStream body) {
        if (body == null) return "";
        try (body) {
            byte[] bytes = readBounded(body, 4096);
            String text = new String(bytes, StandardCharsets.UTF_8).trim();
            if (text.isEmpty()) return "";
            try {
                JsonObject json = JsonParser.parseString(text).getAsJsonObject();
                if (json.has("detail")) return ": " + json.get("detail");
            } catch (RuntimeException ignored) {
                // keep raw
            }
            return ": " + (text.length() > 300 ? text.substring(0, 300) : text);
        } catch (IOException | AiInferenceException ignored) {
            return "";
        }
    }

    private static byte[] readBounded(InputStream input, int maximumBytes) throws IOException, AiInferenceException {
        byte[] data = input.readNBytes(maximumBytes + 1);
        if (data.length > maximumBytes) {
            throw new AiInferenceException("The screening response exceeded the approved size limit.");
        }
        return data;
    }

    private static ScreeningResponse fromJson(String json) throws AiInferenceException {
        try {
            JsonObject data = JsonParser.parseString(json).getAsJsonObject();
            String eigencamB64 = getString(data, "eigencamBase64");
            byte[] heatmap = eigencamB64 == null || eigencamB64.isBlank() ? null : Base64.getDecoder().decode(eigencamB64);
            return new ScreeningResponse(
                data.get("attemptId").getAsString(),
                data.get("accepted").getAsBoolean(),
                getString(data, "rejectionCode"),
                getString(data, "canonicalClassCode"),
                getDouble(data, "top1Confidence"),
                getString(data, "modelReleaseId"),
                data.get("inputSha256").getAsString(),
                heatmap
            );
        } catch (RuntimeException e) {
            throw new AiInferenceException("The screening response is invalid.", e);
        }
    }

    private static String getString(JsonObject data, String key) {
        return data.has(key) && !data.get(key).isJsonNull() ? data.get(key).getAsString() : null;
    }

    private static Double getDouble(JsonObject data, String key) {
        return data.has(key) && !data.get(key).isJsonNull() ? data.get(key).getAsDouble() : null;
    }

    private static URI internalUri(String path) throws AiInferenceException {
        try {
            URI base = URI.create(AppConfig.require("ai.service.base.url"));
            if ("production".equalsIgnoreCase(AppConfig.get("app.env", "development")) && !"https".equalsIgnoreCase(base.getScheme())) {
                throw new AiInferenceException("Production AI service communication requires TLS.");
            }
            return URI.create(base.toString().replaceAll("/+$", "") + path);
        } catch (IllegalArgumentException e) {
            throw new AiInferenceException("The AI service address is invalid.", e);
        }
    }

    private static String nonce() {
        byte[] value = new byte[32];
        NONCE_RANDOM.nextBytes(value);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value);
    }

    public record ScreeningResponse(String attemptId, boolean accepted, String rejectionCode,
                                    String canonicalClassCode, Double top1Confidence, String modelVersion,
                                    String inputSha256, byte[] eigenCamPng) {
        private void verify(String expectedAttemptId, String expectedHash) throws AiInferenceException {
            if (!expectedAttemptId.equals(attemptId) || !expectedHash.equals(inputSha256)) {
                throw new AiInferenceException("The screening response did not match the approved request.");
            }
            if (accepted && (canonicalClassCode == null || top1Confidence == null)) {
                throw new AiInferenceException("The accepted screening response is incomplete.");
            }
            if (accepted && (eigenCamPng == null || eigenCamPng.length == 0)) {
                throw new AiInferenceException("The accepted screening response is missing its required explanation image.");
            }
            if (!accepted && eigenCamPng != null) throw new AiInferenceException("A rejected screening response included media.");
        }
    }

    public static class AiInferenceException extends Exception {
        public AiInferenceException(String message) { super(message); }
        public AiInferenceException(String message, Throwable cause) { super(message, cause); }
    }
}
