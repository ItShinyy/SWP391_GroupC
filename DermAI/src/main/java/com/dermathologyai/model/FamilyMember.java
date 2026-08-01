package com.dermathologyai.model;

import java.time.LocalDate;

/** A person for whom a patient may later make an appointment. */
public class FamilyMember {
    private String id;
    private String ownerUserId;
    private String fullName;
    private LocalDate dateOfBirth;
    private String gender;
    private String relationship;
    private String phone;
    private String email;
    private String province;
    private String ward;
    private String addressDetail;
    private String country;
    private String ethnicity;
    private String occupation;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getOwnerUserId() { return ownerUserId; }
    public void setOwnerUserId(String ownerUserId) { this.ownerUserId = ownerUserId; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getRelationship() { return relationship; }
    public void setRelationship(String relationship) { this.relationship = relationship; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }
    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }
    public String getAddressDetail() { return addressDetail; }
    public void setAddressDetail(String addressDetail) { this.addressDetail = addressDetail; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public String getEthnicity() { return ethnicity; }
    public void setEthnicity(String ethnicity) { this.ethnicity = ethnicity; }
    public String getOccupation() { return occupation; }
    public void setOccupation(String occupation) { this.occupation = occupation; }

    public String getRelationshipLabel() {
        if (relationship == null || relationship.isBlank()) return "Người thân";
        return switch (relationship) {
            case "FATHER" -> "Bố";
            case "MOTHER" -> "Mẹ";
            case "SPOUSE" -> "Vợ/Chồng";
            case "CHILD" -> "Con";
            case "OLDER_BROTHER" -> "Anh";
            case "OLDER_SISTER" -> "Chị";
            case "YOUNGER_BROTHER" -> "Em trai";
            case "YOUNGER_SISTER" -> "Em gái";
            case "GRANDPARENT" -> "Ông/Bà";
            default -> "Người thân";
        };
    }
}
