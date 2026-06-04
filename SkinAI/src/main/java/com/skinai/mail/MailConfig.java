package com.skinai.mail;

import java.io.InputStream;
import java.util.Properties;

public class MailConfig {
    private static final Properties PROPS = new Properties();

    static {
        try (InputStream is = MailConfig.class.getClassLoader()
                .getResourceAsStream("mail.properties")) {
            if (is == null) {
                throw new RuntimeException("Cannot find mail.properties");
            }
            PROPS.load(is);
        } catch (Exception e) {
            throw new RuntimeException("Load mail config failed", e);
        }
    }

    public static String get(String key) {
        return PROPS.getProperty(key);
    }
}
