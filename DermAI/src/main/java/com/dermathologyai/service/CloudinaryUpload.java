package com.dermathologyai.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.dermathologyai.config.AppConfig;

import java.io.IOException;
import java.util.Map;
import java.util.Objects;

/** Public Cloudinary image upload for non-diagnosis attachments (issue reports, etc.). */
public final class CloudinaryUpload {
    private CloudinaryUpload() {}

    public static String uploadPublicImage(byte[] content, String folder, String publicId) throws IOException {
        if (content == null || content.length == 0) {
            throw new IOException("Empty image content.");
        }
        Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", AppConfig.require("cloudinary.cloud.name"),
                "api_key", AppConfig.require("cloudinary.api.key"),
                "api_secret", AppConfig.require("cloudinary.api.secret"),
                "secure", true
        ));
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> result = cloudinary.uploader().upload(content, ObjectUtils.asMap(
                    "folder", folder,
                    "public_id", publicId,
                    "resource_type", "image",
                    "overwrite", false,
                    "unique_filename", false
            ));
            String url = result == null ? null : Objects.toString(result.get("secure_url"), null);
            if (url == null || url.isBlank()) {
                throw new IOException("Cloudinary returned no secure_url.");
            }
            return url;
        } catch (IOException e) {
            throw e;
        } catch (Exception e) {
            throw new IOException("Cloudinary upload failed.", e);
        }
    }
}
