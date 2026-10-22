package com.mf.backend.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.mf.backend.dto.DeviceQuery;
import com.mf.backend.dto.DeviceSaveDTO;
import com.mf.backend.entity.Device;

/**
 * 设备业务接口。
 * 只声明业务动作，不关心 HTTP 也不关心 SQL 怎么写。
 */
public interface DeviceService {

    /** 分页查询，支持按设备名模糊搜 */
    Page<Device> page(DeviceQuery query);

    /** 按 id 查单条，不存在时抛业务异常 */
    Device getById(Long id);

    /** 新增，返回新记录 id */
    Long create(DeviceSaveDTO dto);

    /** 按 id 更新，只更新 DTO 里有的字段 */
    void update(Long id, DeviceSaveDTO dto);

    /** 按 id 逻辑删除 */
    void remove(Long id);
}
