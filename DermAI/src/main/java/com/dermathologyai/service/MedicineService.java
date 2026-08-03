package com.dermathologyai.service;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.model.MedicineDto;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.InputStream;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service responsible for retrieving medicine suggestions from external Medicine APIs.
 * Includes in-memory query caching, external REST API integration, and fallback data recovery.
 */
public class MedicineService {
    private static final Logger logger = LoggerFactory.getLogger(MedicineService.class);
    
    // In-memory cache for search results (Query -> List of MedicineDto)
    private static final Map<String, List<MedicineDto>> SEARCH_CACHE = new ConcurrentHashMap<>();

    // Curated fallback repository of common dermatology and clinical medicines
    private static final List<MedicineDto> FALLBACK_MEDICINES = Arrays.asList(
        new MedicineDto("Amoxicillin 250mg", "Uống 2 lần/ngày, mỗi lần 1 viên sau ăn", "viên", "Uống sau khi ăn sáng và tối. Dùng liên tục 7 ngày.", "Kháng sinh"),
        new MedicineDto("Amoxicillin 500mg", "Uống 2 lần/ngày, mỗi lần 1 viên sau ăn", "viên", "Uống sau ăn 30 phút. Đủ liều theo chỉ định.", "Kháng sinh"),
        new MedicineDto("Amoxicillin + Clavulanate 625mg", "Uống 2 lần/ngày, mỗi lần 1 viên", "viên", "Uống vào đầu bữa ăn để giảm khó chịu dạ dày.", "Kháng sinh"),
        new MedicineDto("Hydrocortisone 1% cream", "Thoa 1-2 lần/ngày lên vùng da tổn thương", "tuýp", "Thoa lớp mỏng. Tránh bôi mắt và vết thương hở.", "Corticoid dùng ngoài"),
        new MedicineDto("Isotretinoin 10mg", "Uống 1-2 lần/ngày trong bữa ăn", "viên", "Uống ngay sau bữa ăn có chất béo.", "Điều trị mụn trứng cá"),
        new MedicineDto("Isotretinoin 20mg", "Uống 1 lần/ngày trong bữa ăn", "viên", "Theo dõi xét nghiệm gan và mỡ máu định kỳ.", "Điều trị mụn trứng cá"),
        new MedicineDto("Clindamycin 1% gel", "Thoa 2 lần/ngày lên vùng da bị mụn", "tuýp", "Rửa sạch và lau khô da trước khi thoa.", "Kháng sinh dùng ngoài"),
        new MedicineDto("Cetirizine 10mg", "Uống 1 viên/ngày vào buổi tối", "viên", "Dùng cho trường hợp dị ứng, mề đay, ngứa da.", "Kháng dị ứng"),
        new MedicineDto("Loratadine 10mg", "Uống 1 viên/ngày", "viên", "Dùng vào buổi sáng hoặc tối sau ăn.", "Kháng dị ứng"),
        new MedicineDto("Doxycycline 100mg", "Uống 1-2 lần/ngày sau ăn", "viên", "Uống với nhiều nước, không nằm ngay sau khi uống.", "Kháng sinh"),
        new MedicineDto("Acyclovir 400mg", "Uống 3-5 lần/ngày theo chỉ định", "viên", "Dùng điều trị Herpes, Zona thần kinh.", "Kháng vi-rút"),
        new MedicineDto("Acyclovir 5% cream", "Thoa 4-5 lần/ngày lên tổn thương", "tuýp", "Thoa ngay khi xuất hiện dấu hiệu đầu tiên.", "Kháng vi-rút dùng ngoài"),
        new MedicineDto("Fucidin (Acid Fusidic 2%)", "Thoa 2-3 lần/ngày lên vùng da nhiễm khuẩn", "tuýp", "Vệ sinh vùng da bệnh trước khi thoa.", "Kháng sinh bôi"),
        new MedicineDto("Ketoconazole 2% cream", "Thoa 1-2 lần/ngày lên vùng nấm da", "tuýp", "Dùng liên tục 2-4 tuần theo chỉ định.", "Kháng nấm dùng ngoài"),
        new MedicineDto("Metronidazole 0.75% gel", "Thoa 2 lần/ngày", "tuýp", "Dùng điều trị chứng viêm da chứng cá đỏ (Rosacea).", "Kháng khuẩn bôi"),
        new MedicineDto("Paracetamol 500mg", "Uống 1-2 viên/lần khi đau hoặc sốt", "viên", "Khoảng cách giữa 2 lần uống tối thiểu 4-6 giờ.", "Giảm đau, hạ sốt")
    );

    private final HttpClient httpClient;

    public MedicineService() {
        int timeoutMs = AppConfig.getInt("medicine.api.timeout.ms", 4000);
        this.httpClient = HttpClient.newBuilder()
            .version(HttpClient.Version.HTTP_1_1)
            .connectTimeout(Duration.ofMillis(timeoutMs))
            .build();
    }

    /**
     * Search medicines by query string. Checks cache first, calls external API, and falls back gracefully.
     *
     * @param query Search keyword (must be >= 2 characters)
     * @return List of matching MedicineDto objects
     * @throws MedicineException if search fails and no fallback items can be served
     */
    public List<MedicineDto> searchMedicines(String query) throws MedicineException {
        if (query == null || query.trim().length() < 2) {
            return Collections.emptyList();
        }

        String normalizedQuery = query.trim().toLowerCase();

        // 1. Return from in-memory cache if available
        if (SEARCH_CACHE.containsKey(normalizedQuery)) {
            logger.debug("Returning medicine search results from cache for: {}", normalizedQuery);
            return SEARCH_CACHE.get(normalizedQuery);
        }

        List<MedicineDto> results = new ArrayList<>();

        // 2. Attempt call to External Medicine API
        try {
            results = fetchFromExternalApi(normalizedQuery);
        } catch (Exception e) {
            logger.warn("External Medicine API request failed for query '{}': {}. Falling back to internal repository.", normalizedQuery, e.getMessage());
        }

        // 3. Fallback / Augment with curated internal medicines if API returned empty or failed
        if (results == null || results.isEmpty()) {
            results = filterFallbackMedicines(normalizedQuery);
        }

        if (results.isEmpty()) {
            // If still empty after fallback search, check if query matched nothing
            logger.info("No medicine matches found for query: {}", normalizedQuery);
        } else {
            // Cache successful result
            SEARCH_CACHE.put(normalizedQuery, results);
        }

        return results;
    }

    /**
     * Calls configured External Medicine REST API (Default NIH RxNav API or configured endpoint).
     */
    private List<MedicineDto> fetchFromExternalApi(String query) throws Exception {
        String baseUrl = AppConfig.get("medicine.api.base.url", "https://rxnav.nlm.nih.gov/REST");
        String apiKey = AppConfig.get("medicine.api.key", "");

        if (baseUrl == null || baseUrl.isBlank()) {
            return Collections.emptyList();
        }

        // Build target URI. Supporting NIH RxNav / REST APIs or open search endpoints.
        String encodedQuery = URLEncoder.encode(query, StandardCharsets.UTF_8);
        String targetUrl;
        if (baseUrl.contains("rxnav.nlm.nih.gov")) {
            targetUrl = baseUrl.replaceAll("/+$", "") + "/drugs.json?name=" + encodedQuery;
        } else {
            targetUrl = baseUrl.replaceAll("/+$", "") + "/search?q=" + encodedQuery;
        }

        HttpRequest.Builder reqBuilder = HttpRequest.newBuilder(URI.create(targetUrl))
            .timeout(Duration.ofMillis(AppConfig.getInt("medicine.api.timeout.ms", 4000)))
            .header("Accept", "application/json");

        if (apiKey != null && !apiKey.isBlank()) {
            reqBuilder.header("Authorization", "Bearer " + apiKey.trim());
            reqBuilder.header("X-API-Key", apiKey.trim());
        }

        HttpRequest request = reqBuilder.GET().build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            logger.warn("External Medicine API HTTP error: {}", response.statusCode());
            return Collections.emptyList();
        }

        return parseApiResponse(response.body(), query);
    }

    /**
     * Parses JSON response from External API into List of MedicineDto.
     */
    private List<MedicineDto> parseApiResponse(String responseJson, String query) {
        List<MedicineDto> list = new ArrayList<>();
        if (responseJson == null || responseJson.isBlank()) return list;

        try {
            JsonObject root = JsonParser.parseString(responseJson).getAsJsonObject();

            // Handle NIH RxNav structure: drugGroup -> conceptGroup -> conceptProperties
            if (root.has("drugGroup") && root.getAsJsonObject("drugGroup").has("conceptGroup")) {
                JsonArray groups = root.getAsJsonObject("drugGroup").getAsJsonArray("conceptGroup");
                for (JsonElement groupElem : groups) {
                    JsonObject group = groupElem.getAsJsonObject();
                    if (group.has("conceptProperties")) {
                        JsonArray concepts = group.getAsJsonArray("conceptProperties");
                        for (JsonElement conceptElem : concepts) {
                            JsonObject prop = conceptElem.getAsJsonObject();
                            String name = prop.has("name") ? prop.get("name").getAsString() : "";
                            String synonym = prop.has("synonym") ? prop.get("synonym").getAsString() : "";
                            String displayName = synonym != null && !synonym.isBlank() ? synonym : name;

                            if (!displayName.isBlank()) {
                                list.add(new MedicineDto(
                                    displayName,
                                    extractDosage(displayName),
                                    "viên",
                                    "Uống theo chỉ định của bác sĩ.",
                                    "Dược phẩm"
                                ));
                            }
                            if (list.size() >= 10) break;
                        }
                    }
                    if (list.size() >= 10) break;
                }
            } else if (root.has("items") && root.get("items").isJsonArray()) {
                // Handle generic REST JSON structure: { "items": [ { "name": "...", "dosage": "..." } ] }
                JsonArray items = root.getAsJsonArray("items");
                for (JsonElement itemElem : items) {
                    JsonObject item = itemElem.getAsJsonObject();
                    String name = item.has("name") ? item.get("name").getAsString() : "";
                    String dosage = item.has("dosage") ? item.get("dosage").getAsString() : "";
                    String unit = item.has("unit") ? item.get("unit").getAsString() : "viên";
                    String usage = item.has("usage") ? item.get("usage").getAsString() : "Sử dụng theo chỉ định.";
                    String category = item.has("category") ? item.get("category").getAsString() : "Thuốc";

                    if (!name.isBlank()) {
                        list.add(new MedicineDto(name, dosage, unit, usage, category));
                    }
                }
            }
        } catch (Exception e) {
            logger.warn("Failed to parse external medicine API JSON response: {}", e.getMessage());
        }

        return list;
    }

    private List<MedicineDto> filterFallbackMedicines(String query) {
        List<MedicineDto> matches = new ArrayList<>();
        String q = query.toLowerCase();

        for (MedicineDto med : FALLBACK_MEDICINES) {
            if (med.getName().toLowerCase().contains(q) ||
                (med.getCategory() != null && med.getCategory().toLowerCase().contains(q))) {
                matches.add(med);
            }
        }

        return matches;
    }

    private static String extractDosage(String name) {
        if (name == null) return "Theo chỉ định";
        // Simple regex extraction for mg, ml, %, etc.
        java.util.regex.Matcher matcher = java.util.regex.Pattern.compile("\\d+\\s*(mg|g|ml|%)", java.util.regex.Pattern.CASE_INSENSITIVE).matcher(name);
        if (matcher.find()) {
            return "Liều lượng: " + matcher.group(0);
        }
        return "Theo hướng dẫn của bác sĩ.";
    }

    public static class MedicineException extends Exception {
        public MedicineException(String message) {
            super(message);
        }

        public MedicineException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
