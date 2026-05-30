package com.skinai.model;

import java.time.LocalDateTime;

/**
 * Represents a blog article.
 */
public class Article {
    private String id;
    private String title;
    private String slug;
    private String thumbnailUrl;
    private String content;
    private String authorUserId;
    private String status; // DRAFT, PUBLISHED, ARCHIVED
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Transient field
    private String authorName;

    public Article() {
    }

    public Article(String id, String title, String slug, String thumbnailUrl, String content, String authorUserId, String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.title = title;
        this.slug = slug;
        this.thumbnailUrl = thumbnailUrl;
        this.content = content;
        this.authorUserId = authorUserId;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getAuthorUserId() { return authorUserId; }
    public void setAuthorUserId(String authorUserId) { this.authorUserId = authorUserId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }

    @Override
    public String toString() {
        return "Article{" +
                "id='" + id + '\'' +
                ", title='" + title + '\'' +
                ", slug='" + slug + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}
