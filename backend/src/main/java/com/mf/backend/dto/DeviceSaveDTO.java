package com.mf.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 新增 / 修改设备的入参。
 * 只暴露允许客户端写的字段，id 与时间字段由服务端生成。
 */
@Data
public class DeviceSaveDTO {

    @NotBlank(message = "设备名不能为空")
    @Size(max = 64, message = "设备名不能超过 64 个字符")
    private String deviceName;

    @Size(max = 64, message = "设备型号不能超过 64 个字符")
    private String deviceModel;

    @Size(max = 32, message = "系统版本不能超过 32 个字符")
    private String osVersion;

    @Size(max = 255, message = "备注不能超过 255 个字符")
    private String remark;
}
