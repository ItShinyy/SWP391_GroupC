package com.dermathologyai.util;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

public class GoogleAuthUtil {
    private static final Logger logger = LoggerFactory.getLogger(GoogleAuthUtil.class);
    private static final Gson GSON = new Gson();
    private static final HttpClient HTTP = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    public static class TokenResponse {
        public String access_token;
    }

    public static class UserInfoResponse {
        public String sub;
        public String email;
        public boolean email_verified;
        public String name;
        public String picture;
    }

    public static String buildAuthUrl(String clientId, String redirectUri, String scope, String state) {
        return "https://accounts.google.com/o/oauth2/v2/auth?" +
               "client_id=" + clientId +
               "&redirect_uri=" + redirectUri +
               "&response_type=code" +
               "&scope=" + scope +
               "&access_type=online" +
               "&state=" + URLEncoder.encode(state, StandardCharsets.UTF_8);
    }

    public static TokenResponse exchangeCodeForTokens(String code, String clientId, String clientSecret, String redirectUri) {
        try {
            String params = "code=" + URLEncoder.encode(code, StandardCharsets.UTF_8) +
                            "&client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8) +
                            "&client_secret=" + URLEncoder.encode(clientSecret, StandardCharsets.UTF_8) +
                            "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8) +
                            "&grant_type=authorization_code";
            HttpRequest request = HttpRequest.newBuilder(URI.create("https://oauth2.googleapis.com/token"))
                    .timeout(Duration.ofSeconds(15))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(params, StandardCharsets.UTF_8))
                    .build();
            HttpResponse<String> response = HTTP.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (response.statusCode() == 200) {
                return GSON.fromJson(response.body(), TokenResponse.class);
            }
            logger.error("Token exchange failed with code: {}", response.statusCode());
        } catch (IOException | InterruptedException | JsonSyntaxException e) {
            if (e instanceof InterruptedException) {
                Thread.currentThread().interrupt();
            }
            logger.error("Error exchanging code for tokens", e);
        }
        return null;
    }

    public static UserInfoResponse getUserInfo(String accessToken) {
        try {
            HttpRequest request = HttpRequest.newBuilder(URI.create("https://www.googleapis.com/oauth2/v3/userinfo"))
                    .timeout(Duration.ofSeconds(15))
                    .header("Authorization", "Bearer " + accessToken)
                    .GET()
                    .build();
            HttpResponse<String> response = HTTP.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (response.statusCode() == 200) {
                return GSON.fromJson(response.body(), UserInfoResponse.class);
            }
            logger.error("Failed to get user info: {}", response.statusCode());
        } catch (IOException | InterruptedException | JsonSyntaxException e) {
            if (e instanceof InterruptedException) {
                Thread.currentThread().interrupt();
            }
            logger.error("Error getting user info", e);
        }
        return null;
    }
}
