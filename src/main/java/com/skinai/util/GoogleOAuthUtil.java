package com.skinai.util;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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
                try (InputStreamReader reader = new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8)) {
                    JsonObject jsonObject = JsonParser.parseReader(reader).getAsJsonObject();
                    Map<String, String> result = new HashMap<>();
                    result.put("access_token", jsonObject.get("access_token").getAsString());
                    if (jsonObject.has("id_token")) {
                        result.put("id_token", jsonObject.get("id_token").getAsString());
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
                try (InputStreamReader reader = new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8)) {
                    JsonObject jsonObject = JsonParser.parseReader(reader).getAsJsonObject();
                    Map<String, String> userInfo = new HashMap<>();
                    
                    userInfo.put("id", jsonObject.has("sub") ? jsonObject.get("sub").getAsString() : null);
                    userInfo.put("email", jsonObject.has("email") ? jsonObject.get("email").getAsString() : null);
                    userInfo.put("name", jsonObject.has("name") ? jsonObject.get("name").getAsString() : null);
                    userInfo.put("picture", jsonObject.has("picture") ? jsonObject.get("picture").getAsString() : null);
                    
                    return userInfo;
                }
            } else {
                logger.error("Get user info failed with code: {}", conn.getResponseCode());
            }
        } catch (Exception e) {
            logger.error("Error getting user info", e);
        }
        return null;
    }
}
