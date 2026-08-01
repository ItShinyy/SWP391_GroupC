package com.dermathologyai.service;

public class CooldownException extends Exception {
    public CooldownException(long secondsLeft) {
        super("Vui lòng đợi thêm " + secondsLeft + " giây trước khi yêu cầu lại.");
    }
}
