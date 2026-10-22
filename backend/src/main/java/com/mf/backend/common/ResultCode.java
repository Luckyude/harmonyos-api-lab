package com.mf.backend.common;

import lombok.Getter;

/**
 * 统一业务状态码。
 * 约定：0 成功，4xx 调用方问题，5xx 服务端问题。
 */
@Getter
public enum ResultCode {

    SUCCESS(0, "成功"),
    BAD_REQUEST(400, "参数不合法"),
    NOT_FOUND(404, "数据不存在"),
    INTERNAL_ERROR(500, "服务器内部错误");

    private final int code;
    private final String message;

    ResultCode(int code, String message) {
        this.code = code;
        this.message = message;
    }
}
