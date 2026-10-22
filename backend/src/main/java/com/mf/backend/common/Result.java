package com.mf.backend.common;

import lombok.Data;

import java.io.Serializable;

/**
 * 统一响应体。所有接口都返回这个结构，鸿蒙端解析时只需处理一种格式。
 *
 * <pre>
 * { "code": 0, "message": "成功", "data": {...}, "timestamp": 1761100000000 }
 * </pre>
 *
 * @param <T> 业务数据类型
 */
@Data
public class Result<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 状态码，0 表示成功 */
    private int code;

    /** 提示信息 */
    private String message;

    /** 业务数据，失败时为 null */
    private T data;

    /** 服务端时间戳，客户端可用来校时或做耗时统计 */
    private long timestamp;

    private Result(int code, String message, T data) {
        this.code = code;
        this.message = message;
        this.data = data;
        this.timestamp = System.currentTimeMillis();
    }

    public static <T> Result<T> ok(T data) {
        return new Result<>(ResultCode.SUCCESS.getCode(), ResultCode.SUCCESS.getMessage(), data);
    }

    public static <T> Result<T> ok() {
        return ok(null);
    }

    public static <T> Result<T> fail(ResultCode resultCode) {
        return new Result<>(resultCode.getCode(), resultCode.getMessage(), null);
    }

    public static <T> Result<T> fail(int code, String message) {
        return new Result<>(code, message, null);
    }
}
