package com.skinai.util;

import jakarta.servlet.http.Part;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

public class StorageUtil {
    private static final Logger logger = LoggerFactory.getLogger(StorageUtil.class);

    // TODO: Integrate Firebase Storage later. Currently using local file system.

    public static String saveFile(Part filePart, String uploadDir) throws IOException {
        String originalFileName = extractFileName(filePart);
        if (originalFileName == null || originalFileName.isEmpty()) {
            return null;
        }

        String newFileName = generateFileName(originalFileName);
        File uploadDirFile = new File(uploadDir);
        if (!uploadDirFile.exists()) {
            uploadDirFile.mkdirs();
        }

        String filePath = uploadDir + File.separator + newFileName;
        filePart.write(filePath);
        logger.info("File saved to {}", filePath);
        
        // Return relative path for web access
        return "/uploads/" + newFileName;
    }

    public static boolean deleteFile(String relativePath, String uploadBaseDir) {
        if (relativePath == null || relativePath.isEmpty()) return false;
        
        // Convert relative path /uploads/filename.ext to absolute path
        String fileName = relativePath.substring(relativePath.lastIndexOf("/") + 1);
        String filePath = uploadBaseDir + File.separator + fileName;
        
        File file = new File(filePath);
        if (file.exists()) {
            boolean deleted = file.delete();
            if (deleted) logger.info("Deleted file {}", filePath);
            return deleted;
        }
        return false;
    }

    private static String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return null;
    }

    private static String generateFileName(String originalName) {
        String extension = "";
        int i = originalName.lastIndexOf('.');
        if (i > 0) {
            extension = originalName.substring(i);
        }
        return UUID.randomUUID().toString() + extension;
    }
}
