package com.dermathologyai.model;

import java.time.LocalDateTime;

/**
 * Represents a prescription for an appointment.
 */
public class Prescription {
    private String id;
    private String appointmentId;
    private String drugName;
    private int quantity;
    private String dosage;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Prescription() {
    }

    public Prescription(String id, String appointmentId, String drugName, int quantity, String dosage) {
        this.id = id;
        this.appointmentId = appointmentId;
        this.drugName = drugName;
        this.quantity = quantity;
        this.dosage = dosage;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(String appointmentId) {
        this.appointmentId = appointmentId;
    }

    public String getDrugName() {
        return drugName;
    }

    public void setDrugName(String drugName) {
        this.drugName = drugName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getDosage() {
        return dosage;
    }

    public void setDosage(String dosage) {
        this.dosage = dosage;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
