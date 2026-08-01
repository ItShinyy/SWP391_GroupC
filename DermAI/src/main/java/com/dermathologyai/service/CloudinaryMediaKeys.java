package com.dermathologyai.service;

import java.util.Locale;

/** Shared Cloudinary public_id normalization for upload + signed delivery. */
final class CloudinaryMediaKeys {
    private CloudinaryMediaKeys() {}

    /**
     * Image public_ids must not include a file extension (Cloudinary stores format separately).
     * Also trims leading/trailing slashes.
     */
    static String canonicalPublicId(String objectKey) {
        if (objectKey == null) return null;
        String key = objectKey.trim().replace('\\', '/');
        while (key.startsWith("/")) key = key.substring(1);
        while (key.endsWith("/")) key = key.substring(0, key.length() - 1);
        int slash = key.lastIndexOf('/');
        String name = slash >= 0 ? key.substring(slash + 1) : key;
        String path = slash >= 0 ? key.substring(0, slash + 1) : "";
        int dot = name.lastIndexOf('.');
        if (dot > 0) {
            String ext = name.substring(dot + 1).toLowerCase(Locale.ROOT);
            if (ext.equals("jpg") || ext.equals("jpeg") || ext.equals("png") || ext.equals("webp") || ext.equals("gif")) {
                name = name.substring(0, dot);
            }
        }
        return path + name;
    }

    static String formatHint(String objectKey, String contentType) {
        if (contentType != null) {
            String ct = contentType.toLowerCase(Locale.ROOT);
            if (ct.contains("png")) return "png";
            if (ct.contains("webp")) return "webp";
            if (ct.contains("gif")) return "gif";
            if (ct.contains("jpeg") || ct.contains("jpg")) return "jpg";
        }
        if (objectKey != null) {
            String lower = objectKey.toLowerCase(Locale.ROOT);
            if (lower.endsWith(".png")) return "png";
            if (lower.endsWith(".webp")) return "webp";
            if (lower.endsWith(".gif")) return "gif";
        }
        return "jpg";
    }
}
