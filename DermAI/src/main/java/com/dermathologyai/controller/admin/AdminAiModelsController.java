package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.AiModelDAO;
import com.dermathologyai.dao.ClinicalPolicyDAO;
import com.dermathologyai.model.AiModel;
import com.dermathologyai.model.ClinicalPolicyEntry;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AiModelStorage;
import com.dermathologyai.service.AuditService;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.nio.file.Path;

@MultipartConfig(maxFileSize = 500L * 1024 * 1024, maxRequestSize = 510L * 1024 * 1024)
public class AdminAiModelsController extends HttpServlet {
    private final AiModelDAO modelDAO = new AiModelDAO();
    private final ClinicalPolicyDAO policyDAO = new ClinicalPolicyDAO();
    private final AiModelStorage storage = new AiModelStorage();
    private final AuditService auditService = new AuditService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        render(request, response, null);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = user(request);
        String action = request.getParameter("action");
        try {
            if ("upload".equals(action)) {
                Part file = request.getPart("packageZip");
                if (file == null || file.getSize() <= 0) throw new IllegalArgumentException("Choose a model package zip.");
                String id = AiModelDAO.newId();
                String storagePath = storage.installPackage(id, file.getInputStream());
                Path dir = storage.modelDir(storagePath);
                AiModel model = new AiModel();
                model.setId(id);
                model.setName(storage.readName(dir));
                model.setVersion(storage.readVersion(dir));
                model.setStoragePath(storagePath);
                if (!modelDAO.insert(model)) throw new IllegalArgumentException("The model could not be saved.");
                audit(user, "AI_MODEL_UPLOADED", id, request);
            } else if ("activate".equals(action)) {
                String id = required(request, "modelId");
                AiModel model = modelDAO.findById(id);
                if (model == null) throw new IllegalArgumentException("Model not found.");
                storage.activateAtomically(model.getStoragePath());
                if (!modelDAO.activate(id)) throw new IllegalArgumentException("The model could not be activated.");
                audit(user, "AI_MODEL_ACTIVATED", id, request);
            } else if ("deactivate".equals(action)) {
                String id = required(request, "modelId");
                AiModel model = modelDAO.findById(id);
                if (model == null) throw new IllegalArgumentException("Model not found.");
                if (!modelDAO.deactivate(id)) throw new IllegalArgumentException("The model could not be deactivated.");
                if (model.isActive()) storage.clearActive();
                audit(user, "AI_MODEL_DEACTIVATED", id, request);
            } else if ("delete".equals(action)) {
                String id = required(request, "modelId");
                AiModel model = modelDAO.findById(id);
                if (model == null) throw new IllegalArgumentException("Model not found.");
                if (model.isActive()) throw new IllegalArgumentException("Deactivate the model before deleting.");
                if (modelDAO.isReferenced(id)) {
                    throw new IllegalArgumentException("This model was used for screening and cannot be deleted. Deactivate it instead.");
                }
                if (!modelDAO.deleteIfUnused(id)) throw new IllegalArgumentException("The model could not be deleted.");
                storage.deleteStorage(model.getStoragePath());
                audit(user, "AI_MODEL_DELETED", id, request);
            } else if ("savePolicy".equals(action)) {
                ClinicalPolicyEntry entry = new ClinicalPolicyEntry();
                entry.setDiseaseCode(required(request, "diseaseCode").toUpperCase());
                entry.setDisplayName(required(request, "displayName"));
                entry.setRiskLevel(required(request, "riskLevel"));
                entry.setRecommendation(required(request, "recommendation"));
                entry.setDisclaimer(required(request, "disclaimer"));
                if (!policyDAO.upsert(entry)) throw new IllegalArgumentException("Policy could not be saved.");
                audit(user, "AI_CLINICAL_POLICY_SAVED", entry.getDiseaseCode(), request);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/admin/ai-models?updated=1");
        } catch (IllegalArgumentException | IOException e) {
            render(request, response, e.getMessage());
        }
    }

    private void render(HttpServletRequest request, HttpServletResponse response, String error)
        throws ServletException, IOException {
        if (error != null) request.setAttribute("errorMessage", error);
        java.util.List<AiModel> models = modelDAO.findAll();
        java.util.List<ClinicalPolicyEntry> policies = policyDAO.findAll();
        int activeModelCount = 0;
        for (AiModel m : models) {
            if (m.isActive()) activeModelCount++;
        }
        request.setAttribute("models", models);
        request.setAttribute("policies", policies);
        request.setAttribute("modelCount", models.size());
        request.setAttribute("activeModelCount", activeModelCount);
        request.setAttribute("policyCount", policies.size());
        request.setAttribute("canManageModels", true);
        request.setAttribute("canManagePolicy", true);
        request.getRequestDispatcher("/WEB-INF/views/admin/ai-models/index.jsp").forward(request, response);
    }

    private static User user(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute("user");
    }

    private static String required(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null || value.isBlank()) throw new IllegalArgumentException("Missing " + name + ".");
        return value.trim();
    }

    private void audit(User user, String action, String recordId, HttpServletRequest request) {
        auditService.log(user.getId(), action, "ai_models", recordId, null, null, null,
            RequestUtil.getClientIp(request), request.getHeader("User-Agent"));
    }
}
