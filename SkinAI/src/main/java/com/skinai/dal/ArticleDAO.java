package com.skinai.dal;

import com.skinai.model.Article;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.List;

/**
 * DAO for the articles table.
 * JOINs users for the transient authorName field.
 */
public class ArticleDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(ArticleDAO.class);

    private static final String SELECT_COLS =
        "SELECT a.id, a.title, a.slug, a.thumbnail_url, a.content, a.author_user_id," +
        " a.status, a.created_at, a.updated_at, u.full_name AS author_name" +
        " FROM articles a LEFT JOIN users u ON a.author_user_id = u.id";

    public Article findById(String id) {
        return queryOne(SELECT_COLS + " WHERE a.id = ?", ArticleDAO::mapRow, id);
    }

    public Article findBySlug(String slug) {
        return queryOne(SELECT_COLS + " WHERE a.slug = ?", ArticleDAO::mapRow, slug);
    }

    public List<Article> findPublished(int page, int pageSize) {
        return queryList(
            SELECT_COLS + " WHERE a.status = 'PUBLISHED'" +
            " ORDER BY a.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY",
            ArticleDAO::mapRow, (page - 1) * pageSize, pageSize
        );
    }

    public int countPublished() {
        return queryScalar("SELECT COUNT(*) FROM articles WHERE status = 'PUBLISHED'");
    }

    public List<Article> findAll(int page, int pageSize) {
        return queryList(
            SELECT_COLS + " ORDER BY a.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY",
            ArticleDAO::mapRow, (page - 1) * pageSize, pageSize
        );
    }

    public int countAll() {
        return queryScalar("SELECT COUNT(*) FROM articles");
    }

    public String create(Article a) {
        String sql = "INSERT INTO articles (id, title, slug, thumbnail_url, content, author_user_id, status)" +
                     " OUTPUT INSERTED.id VALUES (NEWID(), ?, ?, ?, ?, ?, ?)";
        return insertReturningId(sql,
            a.getTitle(), a.getSlug(), a.getThumbnailUrl(),
            a.getContent(), a.getAuthorUserId(),
            a.getStatus() != null ? a.getStatus() : "DRAFT"
        );
    }

    public boolean update(Article a) {
        String sql = "UPDATE articles SET title = ?, slug = ?, thumbnail_url = ?, content = ?," +
                     " status = ?, updated_at = GETDATE() WHERE id = ?";
        return executeUpdate(sql,
            a.getTitle(), a.getSlug(), a.getThumbnailUrl(),
            a.getContent(), a.getStatus(), a.getId()
        );
    }

    public boolean delete(String id) {
        return executeUpdate("DELETE FROM articles WHERE id = ?", id);
    }

    private static Article mapRow(ResultSet rs) throws SQLException {
        Article a = new Article();
        a.setId(rs.getString("id"));
        a.setTitle(rs.getString("title"));
        a.setSlug(rs.getString("slug"));
        a.setThumbnailUrl(rs.getString("thumbnail_url"));
        a.setContent(rs.getString("content"));
        a.setAuthorUserId(rs.getString("author_user_id"));
        a.setStatus(rs.getString("status"));
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) a.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at"); if (ua != null) a.setUpdatedAt(ua.toLocalDateTime());
        a.setAuthorName(rs.getString("author_name"));
        return a;
    }
}

