package com.dermathologyai.util;

public class PageUtil {
    public static int getOffset(int page, int pageSize) {
        if (page < 1) page = 1;
        return (page - 1) * pageSize;
    }

    public static int getTotalPages(int totalItems, int pageSize) {
        return (int) Math.ceil((double) totalItems / pageSize);
    }
}
