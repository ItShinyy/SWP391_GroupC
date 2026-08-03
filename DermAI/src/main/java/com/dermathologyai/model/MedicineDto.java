package com.dermathologyai.model;

import java.io.Serializable;

/**
 * Data Transfer Object for Medicine Search API results.
 */
public class MedicineDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private String name;
    private String dosage;
    private String unit;
    private String usageInstructions;
    private String category;

    public MedicineDto() {
    }

    public MedicineDto(String name, String dosage, String unit, String usageInstructions, String category) {
        this.name = name;
        this.dosage = dosage;
        this.unit = unit;
        this.usageInstructions = usageInstructions;
        this.category = category;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDosage() {
        return dosage;
    }

    public void setDosage(String dosage) {
        this.dosage = dosage;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getUsageInstructions() {
        return usageInstructions;
    }

    public void setUsageInstructions(String usageInstructions) {
        this.usageInstructions = usageInstructions;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }
}
