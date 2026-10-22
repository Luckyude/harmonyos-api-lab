package com.mf.backend.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Data;

/**
 * 分页查询入参。
 * 默认值写在这里，客户端不传也能正常翻页，不用在 Controller 里做空判断。
 */
@Data
public class DeviceQuery {

    /** 页码，从 1 开始 */
    @Min(value = 1, message = "页码不能小于 1")
    private long pageNum = 1;

    /** 每页条数，服务端另有 500 上限兜底 */
    @Min(value = 1, message = "每页条数不能小于 1")
    @Max(value = 500, message = "每页条数不能超过 500")
    private long pageSize = 10;

    /** 可选：按设备名模糊搜索 */
    private String keyword;
}
