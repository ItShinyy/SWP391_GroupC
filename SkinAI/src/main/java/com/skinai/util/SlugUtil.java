package com.skinai.util;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Pattern;

public class SlugUtil {
    private static final Pattern NONLATIN = Pattern.compile("[^\\w-]");
    private static final Pattern WHITESPACE = Pattern.compile("[\\s]");
    private static final Pattern EDGESDASHES = Pattern.compile("(^-|-$)");

    public static String generateSlug(String input) {
        if (input == null) return "";
        
        String nowhitespace = WHITESPACE.matcher(input).replaceAll("-");
        String normalized = Normalizer.normalize(nowhitespace, Normalizer.Form.NFD);
        // Remove diacritics
        normalized = normalized.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        String slug = NONLATIN.matcher(normalized).replaceAll("");
        slug = EDGESDASHES.matcher(slug).replaceAll("");
        
        return slug.toLowerCase(Locale.ENGLISH);
    }
    
    public static String makeUnique(String slug) {
        return slug + "-" + System.currentTimeMillis();
    }
}
