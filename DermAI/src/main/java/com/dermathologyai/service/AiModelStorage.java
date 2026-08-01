package com.dermathologyai.service;

import com.dermathologyai.config.AppConfig;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.Duration;
import java.util.Comparator;
import java.util.Set;
import java.util.stream.Stream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/** Stores AI packages under ai.models.root and atomically updates active/. */
public class AiModelStorage {
    private static final Set<String> REQUIRED = Set.of(
        "model.onnx", "labels.json", "reference_features.npz", "metadata.json"
    );
    private final HttpClient httpClient = HttpClient.newBuilder()
        .connectTimeout(Duration.ofMillis(AppConfig.getInt("ai.connect.timeout.ms", 3000)))
        .build();

    public Path modelsRoot() {
        return Path.of(AppConfig.require("ai.models.root")).toAbsolutePath().normalize();
    }

    public Path modelDir(String storagePath) {
        Path root = modelsRoot();
        Path dir = root.resolve(storagePath).normalize();
        if (!dir.startsWith(root)) throw new IllegalArgumentException("Invalid model storage path.");
        return dir;
    }

    public Path activeDir() {
        return modelsRoot().resolve("active");
    }

    /** Extract zip into models/{id}/, validate files + FastAPI package check. Returns storage_path relative to root. */
    public String installPackage(String modelId, InputStream zipStream) throws IOException {
        Path root = modelsRoot();
        Files.createDirectories(root.resolve("models"));
        Path target = root.resolve("models").resolve(modelId);
        if (Files.exists(target)) throw new IOException("Model directory already exists.");
        Path temp = root.resolve("models").resolve(modelId + ".tmp");
        deleteRecursive(temp);
        Files.createDirectories(temp);
        try {
            unzip(zipStream, temp);
            flattenIfSingleRoot(temp);
            for (String name : REQUIRED) {
                if (!Files.isRegularFile(temp.resolve(name))) {
                    throw new IOException("Package is missing required file: " + name);
                }
            }
            readPackageVersion(temp);
            validateWithFastApi(temp);
            Files.move(temp, target, StandardCopyOption.ATOMIC_MOVE);
            return "models/" + modelId;
        } catch (IOException | RuntimeException e) {
            deleteRecursive(temp);
            deleteRecursive(target);
            if (e instanceof IOException io) throw io;
            throw new IOException(e.getMessage(), e);
        }
    }

    /** Copy package into active/ via temp + atomic replace. */
    public void activateAtomically(String storagePath) throws IOException {
        Path source = modelDir(storagePath);
        for (String name : REQUIRED) {
            if (!Files.isRegularFile(source.resolve(name))) {
                throw new IOException("Cannot activate incomplete package: missing " + name);
            }
        }
        // ponytail: validated at install; activate only swaps + invalidate
        Path root = modelsRoot();
        Path active = activeDir();
        Path staging = root.resolve("active.staging-" + System.nanoTime());
        Path backup = root.resolve("active.backup-" + System.nanoTime());
        deleteRecursive(staging);
        Files.createDirectories(staging);
        for (String name : REQUIRED) {
            Files.copy(source.resolve(name), staging.resolve(name), StandardCopyOption.REPLACE_EXISTING);
        }
        try {
            if (Files.exists(active)) {
                Files.move(active, backup, StandardCopyOption.ATOMIC_MOVE);
            }
            Files.move(staging, active, StandardCopyOption.ATOMIC_MOVE);
            deleteRecursive(backup);
            invalidateActiveRuntime();
        } catch (IOException e) {
            if (Files.exists(backup) && !Files.exists(active)) {
                try { Files.move(backup, active, StandardCopyOption.ATOMIC_MOVE); } catch (IOException ignored) { }
            }
            deleteRecursive(staging);
            throw e;
        }
    }

    /** Remove filesystem active/ so it cannot drift from DB after deactivate. */
    public void clearActive() throws IOException {
        deleteRecursive(activeDir());
        invalidateActiveRuntime();
    }

    public void deleteStorage(String storagePath) throws IOException {
        deleteRecursive(modelDir(storagePath));
    }

    public String readName(Path packageDir) throws IOException {
        JsonObject meta = JsonParser.parseString(Files.readString(packageDir.resolve("metadata.json"))).getAsJsonObject();
        return meta.has("name") ? meta.get("name").getAsString() : "DermAI";
    }

    public String readVersion(Path packageDir) throws IOException {
        JsonObject meta = JsonParser.parseString(Files.readString(packageDir.resolve("metadata.json"))).getAsJsonObject();
        return meta.get("version").getAsString();
    }

    private void readPackageVersion(Path packageDir) throws IOException {
        JsonObject meta = JsonParser.parseString(Files.readString(packageDir.resolve("metadata.json"))).getAsJsonObject();
        if (!meta.has("package_version") || !"1".equals(meta.get("package_version").getAsString())) {
            throw new IOException("Unsupported or missing package_version (expected \"1\").");
        }
        if (!meta.has("version") || meta.get("version").getAsString().isBlank()) {
            throw new IOException("metadata.json is missing version.");
        }
    }

    private void validateWithFastApi(Path packageDir) throws IOException {
        String base = AppConfig.get("ai.service.base.url");
        if (base == null || base.isBlank()) {
            throw new IOException("ai.service.base.url is required to validate model packages.");
        }
        JsonObject body = new JsonObject();
        body.addProperty("packageDirectory", packageDir.toAbsolutePath().toString());
        HttpRequest request = HttpRequest.newBuilder(URI.create(base.replaceAll("/+$", "") + "/internal/packages/validate"))
            .timeout(Duration.ofMillis(AppConfig.getInt("ai.read.timeout.ms", 60000)))
            .header("Content-Type", "application/json")
            .header("X-AI-Service-Key", AppConfig.require("ai.service.api.key"))
            .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
            .build();
        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new IOException("Package validation failed: " + response.body());
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IOException("Package validation interrupted.", e);
        }
    }

    /** Marks FastAPI active-package cache stale; next screening reloads once. */
    private void invalidateActiveRuntime() {
        String base = AppConfig.get("ai.service.base.url");
        if (base == null || base.isBlank() || !AppConfig.getBoolean("ai.service.enabled", false)) {
            return;
        }
        try {
            HttpRequest request = HttpRequest.newBuilder(URI.create(base.replaceAll("/+$", "") + "/internal/packages/invalidate"))
                .timeout(Duration.ofMillis(AppConfig.getInt("ai.connect.timeout.ms", 3000)))
                .header("X-AI-Service-Key", AppConfig.require("ai.service.api.key"))
                .POST(HttpRequest.BodyPublishers.noBody())
                .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                // Next screening will still fail healthy()/ensure_loaded if files are wrong; do not roll back FS.
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } catch (IOException | IllegalStateException ignored) {
            // AI may be offline during activate; next successful health/screen loads after invalidate retry.
        }
    }

    private static void unzip(InputStream zipStream, Path target) throws IOException {
        try (ZipInputStream zip = new ZipInputStream(zipStream)) {
            ZipEntry entry;
            while ((entry = zip.getNextEntry()) != null) {
                Path out = target.resolve(entry.getName()).normalize();
                if (!out.startsWith(target)) throw new IOException("Zip entry escapes package directory.");
                if (entry.isDirectory()) {
                    Files.createDirectories(out);
                } else {
                    Files.createDirectories(out.getParent());
                    Files.copy(zip, out, StandardCopyOption.REPLACE_EXISTING);
                }
            }
        }
    }

    private static void flattenIfSingleRoot(Path dir) throws IOException {
        try (Stream<Path> stream = Files.list(dir)) {
            Path[] children = stream.toArray(Path[]::new);
            if (children.length == 1 && Files.isDirectory(children[0])) {
                Path nested = children[0];
                try (Stream<Path> nestedStream = Files.list(nested)) {
                    for (Path child : nestedStream.toArray(Path[]::new)) {
                        Files.move(child, dir.resolve(child.getFileName()), StandardCopyOption.REPLACE_EXISTING);
                    }
                }
                deleteRecursive(nested);
            }
        }
    }

    private static void deleteRecursive(Path path) throws IOException {
        if (path == null || !Files.exists(path)) return;
        try (Stream<Path> walk = Files.walk(path)) {
            walk.sorted(Comparator.reverseOrder()).forEach(p -> {
                try { Files.deleteIfExists(p); } catch (IOException ignored) { }
            });
        }
    }
}
