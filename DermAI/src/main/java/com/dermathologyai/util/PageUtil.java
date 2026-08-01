package com.dermathologyai.util;

import jakarta.servlet.http.HttpServletRequest;

public final class PageUtil {
    /** Standard page size for all admin list tables. */
    public static final int ADMIN_PAGE_SIZE = 10;

    private PageUtil() {}

    public static int getOffset(int page, int pageSize) {
        if (page < 1) page = 1;
        return (page - 1) * pageSize;
    }

    public static int getTotalPages(int totalItems, int pageSize) {
        if (pageSize < 1) pageSize = ADMIN_PAGE_SIZE;
        if (totalItems <= 0) return 0;
        return (int) Math.ceil((double) totalItems / pageSize);
    }

    public static int parsePage(String pageParam) {
        if (pageParam == null || pageParam.isBlank()) return 1;
        try {
            int page = Integer.parseInt(pageParam.trim());
            return page < 1 ? 1 : page;
        } catch (NumberFormatException e) {
            return 1;
        }
    }

    public static int normalizePage(int page, int totalPages) {
        if (totalPages < 1) return 1;
        if (page < 1) return 1;
        return Math.min(page, totalPages);
    }

    /** Expose paging attrs used by admin/common/_pagination.jsp */
    public static void setPagingAttributes(HttpServletRequest req, int page, int totalItems) {
        int totalPages = getTotalPages(totalItems, ADMIN_PAGE_SIZE);
        int safePage = normalizePage(page, Math.max(totalPages, 1));
        req.setAttribute("currentPage", safePage);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("pageSize", ADMIN_PAGE_SIZE);
        req.setAttribute("totalItems", totalItems);
    }
}
