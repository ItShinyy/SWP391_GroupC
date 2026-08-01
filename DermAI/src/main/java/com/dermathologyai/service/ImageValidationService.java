package com.dermathologyai.service;

import com.dermathologyai.config.AppConfig;
import jakarta.servlet.http.Part;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.imageio.ImageIO;
import javax.imageio.ImageReadParam;
import javax.imageio.stream.ImageInputStream;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.Iterator;

/** Accepts any decodable image within hard size/dimension caps; does not convert or compress. */
public class ImageValidationService {
    private static final Logger logger = LoggerFactory.getLogger(ImageValidationService.class);
    private final int maxBytes = AppConfig.getInt("hard.max.upload.bytes", 10 * 1024 * 1024);
    private final int maxWidth = AppConfig.getInt("hard.max.image.width", 8192);
    private final int maxHeight = AppConfig.getInt("hard.max.image.height", 8192);
    private final long maxPixels = AppConfig.getInt("hard.max.image.pixels", 32_000_000);

    public NormalizedImage normalize(Part part) throws ImageValidationException {
        if (part == null || part.getSize() <= 0) {
            throw new ImageValidationException("An image file is required.");
        }
        if (part.getSize() > maxBytes) {
            throw new ImageValidationException("The image exceeds the approved upload limit.");
        }
        byte[] raw;
        try (InputStream input = part.getInputStream()) {
            raw = input.readNBytes(maxBytes + 1);
        } catch (IOException e) {
            throw new ImageValidationException("The image could not be read.");
        }
        if (raw.length > maxBytes) {
            throw new ImageValidationException("The image exceeds the approved upload limit.");
        }
        try (ImageInputStream input = ImageIO.createImageInputStream(new ByteArrayInputStream(raw))) {
            if (input == null) {
                throw new ImageValidationException("The uploaded image cannot be safely processed.");
            }
            Iterator<javax.imageio.ImageReader> readers = ImageIO.getImageReaders(input);
            if (!readers.hasNext()) {
                throw new ImageValidationException("The uploaded image is not a supported image format.");
            }
            javax.imageio.ImageReader reader = readers.next();
            try {
                reader.setInput(input, true, true);
                int width = reader.getWidth(0);
                int height = reader.getHeight(0);
                if (width <= 0 || height <= 0 || width > maxWidth || height > maxHeight || (long) width * height > maxPixels) {
                    throw new ImageValidationException("The image dimensions exceed the approved limit.");
                }
                BufferedImage decoded = reader.read(0, new ImageReadParam());
                if (decoded == null) {
                    throw new ImageValidationException("The uploaded image is malformed.");
                }
                return new NormalizedImage(raw, sha256(raw), width, height);
            } finally {
                reader.dispose();
            }
        } catch (ImageValidationException e) {
            throw e;
        } catch (IOException | RuntimeException e) {
            logger.warn("Image validate failed: {}", e.toString());
            throw new ImageValidationException("The uploaded image cannot be safely processed.");
        }
    }

    private static String sha256(byte[] data) throws ImageValidationException {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(data));
        } catch (NoSuchAlgorithmException e) {
            throw new ImageValidationException("Image hashing is unavailable.");
        }
    }

    public static class ImageValidationException extends Exception {
        public ImageValidationException(String message) { super(message); }
    }
}
