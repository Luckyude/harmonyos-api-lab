package com.mf.backend.common;

import lombok.Getter;

/**
 * 业务异常。Service 层发现业务规则不满足时抛这个，
 * 由 GlobalExceptionHandler 统一转成 Result，不要把异常直接抛到 Controller。
 */
@Getter
public class BusinessException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    private final int code;

    public BusinessException(String message) {
        this(ResultCode.BAD_REQUEST.getCode(), message);
    }

    public BusinessException(ResultCode resultCode) {
        this(resultCode.getCode(), resultCode.getMessage());
    }

    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }
}
