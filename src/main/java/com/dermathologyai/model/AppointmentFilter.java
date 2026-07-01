package com.dermathologyai.model;

import java.time.LocalDate;

public class AppointmentFilter {
    private String keyword;
    private String status;
    private LocalDate startDate;
    private LocalDate endDate;

    public AppointmentFilter() {
    }

    public AppointmentFilter(String keyword, String status, LocalDate startDate, LocalDate endDate) {
        this.keyword = keyword;
        this.status = status;
        this.startDate = startDate;
        this.endDate = endDate;
    }

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
