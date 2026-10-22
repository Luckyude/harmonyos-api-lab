package com.mf.backend.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 设备信息，对应 device 表。
 * 鸿蒙端做接口联调时用来上报与查询设备。
 */
@Data
@TableName("device")
public class Device {

    /** 主键，数据库自增 */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 设备名，如「米饭的 Mate60」 */
    private String deviceName;

    /** 设备型号 */
    private String deviceModel;

    /** 系统版本，如 HarmonyOS 6.0 */
    private String osVersion;

    /** 备注 */
    private String remark;

    /** 创建时间，插入时由 MyMetaObjectHandler 自动填充 */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /** 更新时间，插入与更新时都自动填充 */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /** 逻辑删除标记，不返回给客户端 */
    @TableLogic
    @JsonIgnore
    private Integer deleted;
}
