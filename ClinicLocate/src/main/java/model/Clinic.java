package model;

import java.sql.Timestamp;
import java.util.UUID;

public class Clinic {
    private UUID id;
    private String clinicName;
    private String address;
    private String phone;
    private double latitude;
    private double longitude;
    private String facilityType;
    private String specialty;
    private String province;
    private String website;
    private boolean active;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Clinic() {
    }

    public Clinic(UUID id, String clinicName, String address,
                  String phone, double latitude, double longitude,
                  String facilityType, String specialty, String province, String website,
                  boolean active, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.clinicName = clinicName;
        this.address = address;
        this.phone = phone;
        this.latitude = latitude;
        this.longitude = longitude;
        this.facilityType = facilityType;
        this.specialty = specialty;
        this.province = province;
        this.website = website;
        this.active = active;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getClinicName() {
        return clinicName;
    }

    public void setClinicName(String clinicName) {
        this.clinicName = clinicName;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public void setFacilityType(String facilityType) {
        this.facilityType = facilityType;
    }

    public String getFacilityType() {

        return facilityType;
    }

    public String getSpecialty() {
        return specialty;
    }

    public void setSpecialty(String specialty) {
        this.specialty = specialty;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public String getWebsite() {
        return website;
    }

    public void setWebsite(String website) {

        this.website = website;
    }

    public boolean isActive() {

        return active;
    }

    public void setActive(boolean active) {

        this.active = active;
    }

    public Timestamp getCreatedAt() {

        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {

        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {

        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {

        this.updatedAt = updatedAt;
    }
}
