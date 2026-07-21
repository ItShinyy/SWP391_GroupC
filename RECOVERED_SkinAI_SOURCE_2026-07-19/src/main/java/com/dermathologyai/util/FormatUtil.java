package com.dermathologyai.util;

public class FormatUtil {

    /**
     * Escapes a string for use in a JSON value.
     * Prevents JSON Injection (XSS) by properly escaping quotes and backslashes.
     */
    public static String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r");
    }

    /**
     * Escapes a string for use in a CSV field.
     * Prevents CSV Macro Injection (Formula Injection) by quoting the field
     * and escaping potentially dangerous starting characters.
     */
    public static String escapeCsv(String value) {
        if (value == null || value.isEmpty()) return "\"\"";
        
        // Anti CSV Injection
        if (value.startsWith("=") || value.startsWith("+") || 
            value.startsWith("-") || value.startsWith("@") || 
            value.startsWith("\t") || value.startsWith("\r")) {
            value = "'" + value;
        }
        
        // Double quotes are escaped by doubling them in CSV
        value = value.replace("\"", "\"\"");
        
        return "\"" + value + "\"";
    }
}
