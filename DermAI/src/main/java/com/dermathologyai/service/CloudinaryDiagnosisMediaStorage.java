package com.dermathologyai.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.dermathologyai.config.AppConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.Map;
import java.util.Objects;

/** Cloudinary upload/delete only; delivery URLs are built outside this class. */
public class CloudinaryDiagnosisMediaStorage {
    private static final Logger logger = LoggerFactory.getLogger(CloudinaryDiagnosisMediaStorage.class);
    private final Cloudinary cloudinary;

    public CloudinaryDiagnosisMediaStorage() {
        this.cloudinary = new Cloudinary(ObjectUtils.asMap(
            "cloud_name", AppConfig.require("cloudinary.cloud.name"),
            "api_key", AppConfig.require("cloudinary.api.key"),
            "api_secret", AppConfig.require("cloudinary.api.secret"),
            "secure", true
        ));
    }

    public String upload(String objectKey, byte[] content, String contentType, String sha256) throws IOException {
        if (sha256 == null || !sha256.matches("[0-9a-f]{64}")) {
            throw new IOException("Private media checksum is invalid.");
        }
        String publicId = CloudinaryMediaKeys.canonicalPublicId(objectKey);
        String format = CloudinaryMediaKeys.formatHint(objectKey, contentType);
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> result = cloudinary.uploader().upload(content, ObjectUtils.asMap(
                "public_id", publicId,
                "resource_type", "image",
                "type", "authenticated",
                "overwrite", false,
                "unique_filename", false,
                "invalidate", false,
                "format", format,
                "context", "sha256=" + sha256
            ));
            String storedId = result == null ? null : Objects.toString(result.get("public_id"), null);
            if (storedId == null || storedId.isBlank()) storedId = publicId;
            logger.info("Private media uploaded requested={} stored={}", objectKey, storedId);
            return storedId;
        } catch (Exception e) {
            logger.error("Private media upload failed key={} cause={}", publicId, rootMessage(e), e);
            throw new IOException("Private media upload failed.", e);
        }
    }

    public void delete(String objectKey) throws IOException {
        if (objectKey == null || objectKey.isBlank()) return;
        String publicId = CloudinaryMediaKeys.canonicalPublicId(objectKey);
        try {
            Map<?, ?> result = cloudinary.uploader().destroy(publicId, ObjectUtils.asMap(
                "resource_type", "image",
                "type", "authenticated",
                "invalidate", true
            ));
            Object status = result == null ? null : result.get("result");
            if (status != null && !"ok".equals(status.toString()) && !"not found".equalsIgnoreCase(status.toString())) {
                throw new IOException("Private media cleanup failed: " + status);
            }
        } catch (IOException e) {
            throw e;
        } catch (Exception e) {
            throw new IOException("Private media cleanup failed.", e);
        }
    }

    private static String rootMessage(Throwable error) {
        Throwable current = error;
        while (current.getCause() != null && current.getCause() != current) current = current.getCause();
        String message = current.getMessage();
        return message == null || message.isBlank() ? current.getClass().getSimpleName() : message;
    }
}
