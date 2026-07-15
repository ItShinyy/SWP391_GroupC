package com.dermathologyai.model;

import java.time.LocalDate;

/**
 * Filter class for appointment queries
 */
public class AppointmentFilter {
    private String keyword;
    private String status;
    private LocalDate startDate;
    private LocalDate endDate;
    
    // Default constructor
    public AppointmentFilter() {}
    
    // Getters and setters
    public String getKeyword() {
        return keyword;
    }
    
    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public LocalDate getStartDate() {
        return startDate;
    }
    
    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }
    
    public LocalDate getEndDate() {
        return endDate;
    }
    
    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }
}