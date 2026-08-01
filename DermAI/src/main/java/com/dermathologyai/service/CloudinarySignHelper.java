package com.dermathologyai.service;

import com.cloudinary.AuthToken;
import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.dermathologyai.config.AppConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/** Builds signed Cloudinary delivery URLs outside the storage interface. */
public final class CloudinarySignHelper {
    private static final Logger logger = LoggerFactory.getLogger(CloudinarySignHelper.class);

    private CloudinarySignHelper() {}

    public static String signedOptimizedUrl(String publicId) {
        if (publicId == null || publicId.isBlank()) {
            throw new IllegalArgumentException("publicId is required.");
        }
        // Match upload rules: DB may still hold keys with .jpg/.png from older runs.
        String canonicalId = CloudinaryMediaKeys.canonicalPublicId(publicId);
        int ttlSeconds = clampTtl(AppConfig.getInt("media.signed.url.ttl.seconds", 600));
        Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
            "cloud_name", AppConfig.require("cloudinary.cloud.name"),
            "api_key", AppConfig.require("cloudinary.api.key"),
            "api_secret", AppConfig.require("cloudinary.api.secret"),
            "secure", true
        ));

        // Authenticated assets require a signed URL. Avoid f_auto here — it can mismatch
        // signature/format for authenticated delivery on some account settings.
        var url = cloudinary.url()
            .secure(true)
            .signed(true)
            .resourceType("image")
            .type("authenticated");

        String tokenKey = AppConfig.get("cloudinary.auth.token.key", "").trim();
        if (!tokenKey.isBlank()) {
            url.authToken(new AuthToken(tokenKey).duration(ttlSeconds));
        }

        try {
            String delivery = url.generate(canonicalId);
            logger.debug("Cloudinary signed URL ready publicId={} canonical={}", publicId, canonicalId);
            return delivery;
        } catch (RuntimeException e) {
            logger.error("Cloudinary signed URL failed publicId={} canonical={}", publicId, canonicalId, e);
            throw e;
        }
    }

    private static int clampTtl(int seconds) {
        if (seconds < 300) return 300;
        if (seconds > 600) return 600;
        return seconds;
    }
}
