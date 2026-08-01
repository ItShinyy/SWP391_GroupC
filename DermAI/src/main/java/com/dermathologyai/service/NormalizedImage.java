package com.dermathologyai.service;

/** Original image bytes used for both inference and protected object storage. */
public record NormalizedImage(byte[] bytes, String sha256, int width, int height) {
}
