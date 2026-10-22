package com.mf.backend.config;

import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 公共字段自动填充。
 * 配合实体上的 {@code @TableField(fill = ...)} 使用，插入和更新时自动写时间，
 * 业务代码里不用再手动 set。
 */
@Component
public class MyMetaObjectHandler implements MetaObjectHandler {

    private static final String FIELD_CREATED_AT = "createdAt";
    private static final String FIELD_UPDATED_AT = "updatedAt";

    @Override
    public void insertFill(MetaObject metaObject) {
        LocalDateTime now = LocalDateTime.now();
        // strictXxxFill 只在字段为 null 时填充，不会覆盖调用方显式传入的值
        this.strictInsertFill(metaObject, FIELD_CREATED_AT, LocalDateTime.class, now);
        this.strictInsertFill(metaObject, FIELD_UPDATED_AT, LocalDateTime.class, now);
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        this.strictUpdateFill(metaObject, FIELD_UPDATED_AT, LocalDateTime.class, LocalDateTime.now());
    }
}
