package com.dermathologyai.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.InputStream;
import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

public class AppConfig {
    private static final Logger logger = LoggerFactory.getLogger(AppConfig.class);
    private static final Properties properties = new Properties();
    private static final Properties environmentFileProperties = new Properties();

    static {
        try (InputStream in = AppConfig.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (in != null) {
                properties.load(in);
                logger.info("Application properties loaded successfully.");
            } else {
                logger.error("Unable to find application.properties");
            }
        } catch (Exception e) {
            logger.error("Error loading application.properties", e);
        }

        loadEnvironmentFile();
    }

    public static String get(String key) {
        String systemValue = System.getProperty(toEnvironmentKey(key));
        if (systemValue == null || systemValue.isBlank()) {
            systemValue = System.getProperty(key);
        }
        if (systemValue != null && !systemValue.isBlank()) {
            return systemValue.trim();
        }
        String environmentValue = System.getenv(toEnvironmentKey(key));
        if (environmentValue != null && !environmentValue.isBlank()) {
            return environmentValue.trim();
        }
        String fileValue = environmentFileProperties.getProperty(toEnvironmentKey(key));
        if (fileValue == null || fileValue.isBlank()) {
            fileValue = environmentFileProperties.getProperty(key);
        }
        if (fileValue != null && !fileValue.isBlank()) {
            return fileValue.trim();
        }
        return properties.getProperty(key);
    }

    public static String get(String key, String defaultValue) {
        String value = get(key);
        return value == null || value.isBlank() ? defaultValue : value;
    }

    public static int getInt(String key, int defaultValue) {
        String value = get(key);
        if (value != null) {
            try {
                return Integer.parseInt(value);
            } catch (NumberFormatException e) {
                logger.warn("Invalid integer runtime configuration for {}", toEnvironmentKey(key));
            }
        }
        return defaultValue;
    }

    public static boolean getBoolean(String key, boolean defaultValue) {
        String value = get(key);
        if (value != null) {
            return Boolean.parseBoolean(value);
        }
        return defaultValue;
    }

    public static String require(String key) {
        String value = get(key);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException("Missing required runtime configuration: " + toEnvironmentKey(key));
        }
        return value;
    }

    private static String toEnvironmentKey(String key) {
        return key.toUpperCase().replace('.', '_').replace('-', '_');
    }

    private static void loadEnvironmentFile() {
        String configuredPath = System.getProperty("APP_ENV_FILE");
        if (configuredPath == null || configuredPath.isBlank()) configuredPath = System.getenv("APP_ENV_FILE");
        Path environmentFile = resolveEnvironmentFile(configuredPath);
        if (environmentFile == null) return;

        try {
            // Parse manually: java.util.Properties treats '\' as escapes and corrupts Windows paths.
            for (String rawLine : Files.readAllLines(environmentFile)) {
                String line = rawLine.trim();
                if (line.isEmpty() || line.startsWith("#")) continue;
                int separator = line.indexOf('=');
                if (separator <= 0) continue;
                String key = line.substring(0, separator).trim();
                String value = line.substring(separator + 1).trim();
                if (!key.isEmpty()) {
                    environmentFileProperties.setProperty(key, value);
                }
            }
            logger.info("Loaded local runtime environment configuration from an external file.");
        } catch (IOException e) {
            logger.warn("Unable to load local runtime environment configuration.");
        }
    }

    private static Path resolveEnvironmentFile(String configuredPath) {
        if (configuredPath != null && !configuredPath.isBlank()) {
            Path configured = Path.of(configuredPath.trim());
            return Files.isRegularFile(configured) ? configured : null;
        }
        Path cwd = Path.of("local.properties");
        if (Files.isRegularFile(cwd)) return cwd;

        // NetBeans: target/DermAI/... ; Cargo: target/cargo-tomcat10x/webapps/DermAI/...
        // Walk up until we find project-root local.properties (next to pom.xml).
        try {
            URL resource = AppConfig.class.getClassLoader().getResource("application.properties");
            if (resource == null || !"file".equalsIgnoreCase(resource.getProtocol())) return null;
            Path dir = Path.of(resource.toURI()).getParent();
            for (int i = 0; i < 8 && dir != null; i++, dir = dir.getParent()) {
                Path candidate = dir.resolve("local.properties");
                if (Files.isRegularFile(candidate) && Files.isRegularFile(dir.resolve("pom.xml"))) {
                    return candidate;
                }
            }
            return null;
        } catch (URISyntaxException | IllegalArgumentException e) {
            return null;
        }
    }
}
