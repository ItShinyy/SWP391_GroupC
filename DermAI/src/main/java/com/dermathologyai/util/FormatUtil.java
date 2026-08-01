package com.dermathologyai.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public class FormatUtil {
    public static final DateTimeFormatter DATE_VN = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    public static final DateTimeFormatter DATE_TIME_VN = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter DATE_ISO = DateTimeFormatter.ISO_LOCAL_DATE;

    /**
     * Escapes a string for use in a CSV field.
     * Prevents CSV Macro Injection (Formula Injection) by quoting the field
     * and escaping potentially dangerous starting characters.
     */
    public static String escapeCsv(String value) {
        if (value == null || value.isEmpty()) return "\"\"";

        if (value.startsWith("=") || value.startsWith("+")
            || value.startsWith("-") || value.startsWith("@")
            || value.startsWith("\t") || value.startsWith("\r")) {
            value = "'" + value;
        }

        value = value.replace("\"", "\"\"");
        return "\"" + value + "\"";
    }

    public static String formatDate(LocalDate date) {
        return date == null ? "" : date.format(DATE_VN);
    }

    public static String formatDateTime(LocalDateTime dateTime) {
        return dateTime == null ? "" : dateTime.format(DATE_TIME_VN);
    }

    /** AI may store 0–1 or 0–100; always return display percent 0–100. */
    public static double confidencePercent(double score) {
        if (score <= 0) return 0;
        return score <= 1.0 ? score * 100.0 : score;
    }

    public static long confidencePercentRounded(double score) {
        return Math.round(confidencePercent(score));
    }

    /** Accepts dd/MM/yyyy or yyyy-MM-dd. Blank → null. Invalid → null. */
    public static LocalDate parseDate(String raw) {
        if (raw == null || raw.isBlank()) return null;
        String value = raw.trim();
        try {
            if (value.contains("/")) return LocalDate.parse(value, DATE_VN);
            return LocalDate.parse(value, DATE_ISO);
        } catch (DateTimeParseException e) {
            return null;
        }
    }
}
