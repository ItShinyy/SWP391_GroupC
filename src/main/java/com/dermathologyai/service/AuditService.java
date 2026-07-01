package com.dermathologyai.service;

import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.model.AuditLog;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class AuditService {
    private static final Logger logger = LoggerFactory.getLogger(AuditService.class);
    private final AuditLogDAO auditLogDAO;

    public AuditService() {
        this.auditLogDAO = new AuditLogDAO();
    }

    public void log(String userId, String action, String entityType, String recordId, String oldValues, String newValues, String ipAddress, String userAgent) {
        AuditLog log = new AuditLog();
        log.setUserId(userId);
        log.setAction(action);
        log.setEntityType(entityType);
        log.setRecordId(recordId);
        log.setOldValues(oldValues);
        log.setNewValues(newValues);
        log.setIpAddress(ipAddress);
        log.setUserAgent(userAgent);
        
        auditLogDAO.create(log);
        logger.info("Audit: User {} {} {} {}", userId, action, entityType, recordId);
    }

    public List<AuditLog> getAll(int page, int pageSize) {
        return auditLogDAO.findAll(page, pageSize);
    }

    public int countAll() {
        return auditLogDAO.countAll();
    }

    public AuditLog getById(String id) {
        return auditLogDAO.findById(id);
    }
}
