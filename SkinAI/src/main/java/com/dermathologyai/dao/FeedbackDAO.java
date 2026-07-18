package com.dermathologyai.dao;

import com.dermathologyai.model.Feedback;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class FeedbackDAO extends DBContext {

    public String create(Feedback feedback) {
        String sql = "INSERT INTO feedbacks (id, patient_id, appointment_id, rating, category, content, created_at, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, GETDATE(), ?)";
        
        String id = UUID.randomUUID().toString();
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, id);
            ps.setString(2, feedback.getPatientId());
            ps.setString(3, feedback.getAppointmentId());
            ps.setInt(4, feedback.getRating());
            ps.setString(5, feedback.getCategory());
            ps.setString(6, feedback.getContent());
            ps.setString(7, feedback.getStatus());
            
            int result = ps.executeUpdate();
            return result > 0 ? id : null;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    public Feedback findById(String id) {
        String sql = "SELECT * FROM feedbacks WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToFeedback(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    public Feedback findByAppointmentId(String appointmentId) {
        String sql = "SELECT * FROM feedbacks WHERE appointment_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToFeedback(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    public List<Feedback> findByPatientId(String patientId, int page, int pageSize) {
        String sql = "SELECT * FROM feedbacks WHERE patient_id = ? " +
                    "ORDER BY created_at DESC " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        List<Feedback> feedbacks = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            System.out.println("DEBUG Patient SQL: " + sql);
            System.out.println("DEBUG Patient Params: [" + patientId + ", " + offset + ", " + pageSize + "]");
            
            ps.setString(1, patientId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Feedback feedback = mapResultSetToFeedback(rs);
                System.out.println("DEBUG Found patient feedback - ID: " + feedback.getId() + 
                                 ", AdminReply: " + feedback.getAdminReply() + 
                                 ", HasAdminReply: " + feedback.hasAdminReply());
                feedbacks.add(feedback);
            }
            
            System.out.println("DEBUG Patient feedbacks count: " + feedbacks.size());
            
        } catch (SQLException e) {
            System.err.println("ERROR in findByPatientId: " + e.getMessage());
            e.printStackTrace();
        }
        
        return feedbacks;
    }

    public List<Feedback> findAll(int page, int pageSize) {
        String sql = "SELECT f.*, u.fullName as patient_name " +
                    "FROM feedbacks f " +
                    "LEFT JOIN patients p ON f.patient_id = p.id " +
                    "LEFT JOIN users u ON p.user_id = u.id " +
                    "ORDER BY f.created_at DESC " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        List<Feedback> feedbacks = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                feedbacks.add(mapResultSetToFeedback(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return feedbacks;
    }

    public boolean update(Feedback feedback) {
        String sql = "UPDATE feedbacks SET rating = ?, category = ?, content = ? WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, feedback.getRating());
            ps.setString(2, feedback.getCategory());
            ps.setString(3, feedback.getContent());
            ps.setString(4, feedback.getId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateStatus(String id, String status) {
        String sql = "UPDATE feedbacks SET status = ? WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setString(2, id);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addAdminReply(String id, String adminReply) {
        String sql = "UPDATE feedbacks SET admin_reply = ?, replied_at = GETDATE() WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, adminReply);
            ps.setString(2, id);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int countByPatientId(String patientId) {
        String sql = "SELECT COUNT(*) FROM feedbacks WHERE patient_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, patientId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM feedbacks";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }

    public double getAverageRating() {
        String sql = "SELECT AVG(CAST(rating AS FLOAT)) FROM feedbacks";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0.0;
    }

    // Admin methods
    public List<Feedback> findAllWithFilters(String status, String category, String searchTerm, int page, int pageSize) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT f.* ")
           .append("FROM feedbacks f ")
           .append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND f.status = ? ");
            params.add(status);
        }
        
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND f.category = ? ");
            params.add(category);
        }
        
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append("AND f.content LIKE ? ");
            params.add("%" + searchTerm + "%");
        }
        
        sql.append("ORDER BY f.created_at DESC ")
           .append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        int offset = (page - 1) * pageSize;
        params.add(offset);
        params.add(pageSize);
        
        List<Feedback> feedbacks = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            System.out.println("DEBUG SQL: " + sql.toString());
            System.out.println("DEBUG Params: " + params);
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                feedbacks.add(mapResultSetToFeedback(rs));
            }
            
            System.out.println("DEBUG Found feedbacks: " + feedbacks.size());
            
        } catch (SQLException e) {
            System.err.println("ERROR in findAllWithFilters: " + e.getMessage());
            e.printStackTrace();
        }
        
        return feedbacks;
    }

    public int countAllWithFilters(String status, String category, String searchTerm) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM feedbacks f ")
           .append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND f.status = ? ");
            params.add(status);
        }
        
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND f.category = ? ");
            params.add(category);
        }
        
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append("AND f.content LIKE ? ");
            params.add("%" + searchTerm + "%");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            System.out.println("DEBUG COUNT SQL: " + sql.toString());
            System.out.println("DEBUG COUNT Params: " + params);
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("DEBUG Total count: " + count);
                return count;
            }
            
        } catch (SQLException e) {
            System.err.println("ERROR in countAllWithFilters: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }

    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM feedbacks WHERE status = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }

    public boolean updateReply(Feedback feedback) {
        String sql = "UPDATE feedbacks SET admin_reply = ?, replied_at = GETDATE(), status = ? WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, feedback.getAdminReply());
            ps.setString(2, feedback.getStatus());
            ps.setString(3, feedback.getId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Feedback mapResultSetToFeedback(ResultSet rs) throws SQLException {
        Feedback feedback = new Feedback();
        
        feedback.setId(rs.getString("id"));
        feedback.setPatientId(rs.getString("patient_id"));
        feedback.setAppointmentId(rs.getString("appointment_id"));
        feedback.setRating(rs.getInt("rating"));
        feedback.setCategory(rs.getString("category"));
        feedback.setContent(rs.getString("content"));
        feedback.setStatus(rs.getString("status"));
        feedback.setAdminReply(rs.getString("admin_reply"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            feedback.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp repliedAt = rs.getTimestamp("replied_at");
        if (repliedAt != null) {
            feedback.setRepliedAt(repliedAt.toLocalDateTime());
        }
        
        return feedback;
    }

    // Test method to check database
    public void debugDatabase() {
        // Check if feedbacks table exists and has data
        String sql1 = "SELECT COUNT(*) FROM feedbacks";
        String sql2 = "SELECT TOP 5 * FROM feedbacks";
        
        try (Connection conn = getConnection()) {
            // Check count
            try (PreparedStatement ps = conn.prepareStatement(sql1)) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("DEBUG: Total feedbacks in table: " + count);
                    
                    // If no feedbacks, create sample data
                    if (count == 0) {
                        createSampleFeedback();
                    }
                }
            }
            
            // Check sample data
            try (PreparedStatement ps = conn.prepareStatement(sql2)) {
                ResultSet rs = ps.executeQuery();
                System.out.println("DEBUG: Sample feedbacks:");
                while (rs.next()) {
                    System.out.println("  ID: " + rs.getString("id") + 
                                     ", Status: " + rs.getString("status") + 
                                     ", Category: " + rs.getString("category") +
                                     ", Content: " + rs.getString("content"));
                }
            }
            
        } catch (SQLException e) {
            System.err.println("DEBUG ERROR: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void createSampleFeedback() {
        System.out.println("DEBUG: Creating sample feedback...");
        
        // First get a patient_id and appointment_id from database
        String getPatientSql = "SELECT TOP 1 p.id, a.id as app_id FROM patients p " +
                              "LEFT JOIN appointments a ON p.id = a.patient_id " +
                              "WHERE a.status = 'COMPLETED'";
        
        String insertSql = "INSERT INTO feedbacks (id, patient_id, appointment_id, rating, category, content, status, created_at) " +
                          "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = getConnection()) {
            String patientId = null;
            String appointmentId = null;
            
            // Get patient and appointment
            try (PreparedStatement ps = conn.prepareStatement(getPatientSql)) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    patientId = rs.getString("id");
                    appointmentId = rs.getString("app_id");
                }
            }
            
            if (patientId != null && appointmentId != null) {
                // Create sample feedbacks
                String[] samples = {
                    "Dịch vụ rất tốt, bác sĩ tận tâm!|Khen|5",
                    "Thời gian chờ hơi lâu, mong cải thiện|Góp ý|3", 
                    "Phòng khám sạch sẽ nhưng cần thêm ghế ngồi|Góp ý|4",
                    "Rất không hài lòng với thái độ nhân viên|Khiếu nại|2"
                };
                
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    for (String sample : samples) {
                        String[] parts = sample.split("\\|");
                        if (parts.length == 3) {
                            ps.setString(1, java.util.UUID.randomUUID().toString());
                            ps.setString(2, patientId);
                            ps.setString(3, appointmentId);
                            ps.setInt(4, Integer.parseInt(parts[2]));
                            ps.setString(5, parts[1]);
                            ps.setString(6, parts[0]);
                            ps.setString(7, "Chưa xử lý");
                            
                            ps.executeUpdate();
                            System.out.println("DEBUG: Created sample feedback: " + parts[0]);
                        }
                    }
                }
            } else {
                System.out.println("DEBUG: No completed appointments found, cannot create sample feedback");
            }
            
        } catch (SQLException e) {
            System.err.println("DEBUG ERROR creating sample: " + e.getMessage());
            e.printStackTrace();
        }
    }
}