package com.skinai.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class GoogleOAuthUtil {
    private static final Logger logger = LoggerFactory.getLogger(GoogleOAuthUtil.class);

    public static String buildAuthUrl(String clientId, String redirectUri, String scope) {
        return "https://accounts.google.com/o/oauth2/v2/auth?" +
               "client_id=" + clientId +
               "&redirect_uri=" + redirectUri +
               "&response_type=code" +
               "&scope=" + scope +
               "&access_type=online";
    }

    public static Map<String, String> exchangeCodeForTokens(String code, String clientId, String clientSecret, String redirectUri) {
        try {
            URL url = new URL("https://oauth2.googleapis.com/token");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            String params = "code=" + URLEncoder.encode(code, StandardCharsets.UTF_8) +
                            "&client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8) +
                            "&client_secret=" + URLEncoder.encode(clientSecret, StandardCharsets.UTF_8) +
                            "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8) +
                            "&grant_type=authorization_code";

            try (OutputStream os = conn.getOutputStream()) {
                os.write(params.getBytes(StandardCharsets.UTF_8));
            }

            if (conn.getResponseCode() == 200) {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    StringBuilder responseBuilder = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        responseBuilder.append(line);
                    }
                    String responseStr = responseBuilder.toString();
                    
                    Map<String, String> result = new HashMap<>();
                    // Manual JSON parsing to avoid Gson dependency
                    String accessToken = extractJsonValue(responseStr, "access_token");
                    if (accessToken != null) {
                        result.put("access_token", accessToken);
                    }
                    String idToken = extractJsonValue(responseStr, "id_token");
                    if (idToken != null) {
                        result.put("id_token", idToken);
                    }
                    return result;
                }
            } else {
                logger.error("Token exchange failed with code: {}", conn.getResponseCode());
            }
        } catch (Exception e) {
            logger.error("Error exchanging code for tokens", e);
        }
        return null;
    }

    public static Map<String, String> getUserInfo(String accessToken) {
        try {
            URL url = new URL("https://www.googleapis.com/oauth2/v3/userinfo");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + accessToken);

            if (conn.getResponseCode() == 200) {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    StringBuilder responseBuilder = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        responseBuilder.append(line);
                    }
                    String responseStr = responseBuilder.toString();
                    
                    Map<String, String> result = new HashMap<>();
                    result.put("id", extractJsonValue(responseStr, "sub"));
                    result.put("email", extractJsonValue(responseStr, "email"));
                    result.put("name", extractJsonValue(responseStr, "name"));
                    result.put("picture", extractJsonValue(responseStr, "picture"));
                    return result;
                }
            } else {
                logger.error("Failed to get user info: {}", conn.getResponseCode());
            }
        } catch (Exception e) {
            logger.error("Error getting user info", e);
        }
        return null;
    }

    private static String extractJsonValue(String json, String key) {
        String searchKey = "\"" + key + "\"";
        int keyIdx = json.indexOf(searchKey);
        if (keyIdx == -1) return null;
        
        int colonIdx = json.indexOf(":", keyIdx);
        if (colonIdx == -1) return null;
        
        int startQuote = json.indexOf("\"", colonIdx);
        if (startQuote == -1) return null;
        
        int endQuote = json.indexOf("\"", startQuote + 1);
        if (endQuote == -1) return null;
        
        return json.substring(startQuote + 1, endQuote);
    }
}
