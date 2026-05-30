package com.skinai.dal;

import com.skinai.model.Article;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ArticleDAO {
    private static final Logger logger = LoggerFactory.getLogger(ArticleDAO.class);

    public Article findById(String id) {
        String sql = "SELECT a.id, a.title, a.slug, a.thumbnail_url, a.content, a.author_user_id, a.status, a.created_at, a.updated_at, " +
                     "u.full_name as author_name " +
                     "FROM articles a " +
                     "LEFT JOIN users u ON a.author_user_id = u.id " +
                     "WHERE a.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding article by id: {}", id, e);
        }
        return null;
    }

    public Article findBySlug(String slug) {
        String sql = "SELECT a.id, a.title, a.slug, a.thumbnail_url, a.content, a.author_user_id, a.status, a.created_at, a.updated_at, " +
                     "u.full_name as author_name " +
                     "FROM articles a " +
                     "LEFT JOIN users u ON a.author_user_id = u.id " +
                     "WHERE a.slug = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, slug);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding article by slug: {}", slug, e);
        }
        return null;
    }

    public List<Article> findPublished(int page, int pageSize) {
        List<Article> list = new ArrayList<>();
        String sql = "SELECT a.id, a.title, a.slug, a.thumbnail_url, a.content, a.author_user_id, a.status, a.created_at, a.updated_at, " +
                     "u.full_name as author_name " +
                     "FROM articles a " +
                     "LEFT JOIN users u ON a.author_user_id = u.id " +
                     "WHERE a.status = 'PUBLISHED' " +
                     "ORDER BY a.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, (page - 1) * pageSize);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding published articles", e);
        }
        return list;
    }

    public int countPublished() {
        String sql = "SELECT COUNT(*) FROM articles WHERE status = 'PUBLISHED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error counting published articles", e);
        }
        return 0;
    }

    public List<Article> findAll(int page, int pageSize) {
        List<Article> list = new ArrayList<>();
        String sql = "SELECT a.id, a.title, a.slug, a.thumbnail_url, a.content, a.author_user_id, a.status, a.created_at, a.updated_at, " +
                     "u.full_name as author_name " +
                     "FROM articles a " +
                     "LEFT JOIN users u ON a.author_user_id = u.id " +
                     "ORDER BY a.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, (page - 1) * pageSize);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding all articles", e);
        }
        return list;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM articles";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error counting all articles", e);
        }
        return 0;
    }

    public String create(Article article) {
        String sql = "INSERT INTO articles (id, title, slug, thumbnail_url, content, author_user_id, status) " +
                     "OUTPUT INSERTED.id " +
                     "VALUES (NEWID(), ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, article.getTitle());
            ps.setString(2, article.getSlug());
            ps.setString(3, article.getThumbnailUrl());
            ps.setString(4, article.getContent());
            ps.setString(5, article.getAuthorUserId());
            ps.setString(6, article.getStatus() != null ? article.getStatus() : "DRAFT");
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Error creating article", e);
        }
        return null;
    }

    public boolean update(Article article) {
        String sql = "UPDATE articles SET title = ?, slug = ?, thumbnail_url = ?, content = ?, status = ?, updated_at = GETDATE() " +
                     "WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, article.getTitle());
            ps.setString(2, article.getSlug());
            ps.setString(3, article.getThumbnailUrl());
            ps.setString(4, article.getContent());
            ps.setString(5, article.getStatus());
            ps.setString(6, article.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating article: {}", article.getId(), e);
        }
        return false;
    }

    public boolean delete(String id) {
        String sql = "DELETE FROM articles WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error deleting article: {}", id, e);
        }
        return false;
    }

    private Article mapRow(ResultSet rs) throws SQLException {
        Article a = new Article();
        a.setId(rs.getString("id"));
        a.setTitle(rs.getString("title"));
        a.setSlug(rs.getString("slug"));
        a.setThumbnailUrl(rs.getString("thumbnail_url"));
        a.setContent(rs.getString("content"));
        a.setAuthorUserId(rs.getString("author_user_id"));
        a.setStatus(rs.getString("status"));
        if (rs.getTimestamp("created_at") != null) {
            a.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        if (rs.getTimestamp("updated_at") != null) {
            a.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        }
        
        // Transient field
        a.setAuthorName(rs.getString("author_name"));
        
        return a;
    }
}
