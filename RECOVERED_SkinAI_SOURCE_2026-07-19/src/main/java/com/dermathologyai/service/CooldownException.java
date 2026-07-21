package com.dermathologyai.service;

public class CooldownException extends Exception {
    private final long secondsLeft;

    public CooldownException(long secondsLeft) {
        super("Vui lòng đợi thêm " + secondsLeft + " giây trước khi yêu cầu lại.");
        this.secondsLeft = secondsLeft;
    }

    public long getSecondsLeft() {
        return secondsLeft;
    }
}
