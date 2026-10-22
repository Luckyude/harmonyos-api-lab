package com.mf.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.mf.backend.entity.Device;
import org.apache.ibatis.annotations.Mapper;

/**
 * 设备表数据访问层。
 * 单表增删改查直接用 BaseMapper 提供的方法，复杂 SQL 再写 XML 或注解。
 * 启动类已 @MapperScan，这里的 @Mapper 只是给 IDE 提示用。
 */
@Mapper
public interface DeviceMapper extends BaseMapper<Device> {
}
