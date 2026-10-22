package com.mf.backend.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.mf.backend.common.BusinessException;
import com.mf.backend.common.ResultCode;
import com.mf.backend.dto.DeviceQuery;
import com.mf.backend.dto.DeviceSaveDTO;
import com.mf.backend.entity.Device;
import com.mf.backend.mapper.DeviceMapper;
import com.mf.backend.service.DeviceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 设备业务实现。
 * 业务规则（存在性校验、参数组合）都在这一层，Controller 不做判断，Mapper 只管 SQL。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceServiceImpl implements DeviceService {

    private final DeviceMapper deviceMapper;

    @Override
    public Page<Device> page(DeviceQuery query) {
        Page<Device> page = new Page<>(query.getPageNum(), query.getPageSize());

        LambdaQueryWrapper<Device> wrapper = new LambdaQueryWrapper<>();
        // 有关键字才拼 like 条件，避免生成 name like '%%' 这种拖慢全表的 SQL
        if (StrUtil.isNotBlank(query.getKeyword())) {
            wrapper.like(Device::getDeviceName, query.getKeyword().trim());
        }
        wrapper.orderByDesc(Device::getId);

        return deviceMapper.selectPage(page, wrapper);
    }

    @Override
    public Device getById(Long id) {
        Device device = deviceMapper.selectById(id);
        if (device == null) {
            throw new BusinessException(ResultCode.NOT_FOUND);
        }
        return device;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long create(DeviceSaveDTO dto) {
        Device device = BeanUtil.copyProperties(dto, Device.class);
        deviceMapper.insert(device);
        log.debug("新增设备成功，id={}", device.getId());
        return device.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void update(Long id, DeviceSaveDTO dto) {
        // 先确认记录存在，否则 updateById 会静默返回 0，调用方以为成功了
        getById(id);

        Device device = BeanUtil.copyProperties(dto, Device.class);
        device.setId(id);
        // 用 updateById 而不是 update 全字段，避免把没传的字段覆盖成 null
        deviceMapper.updateById(device);
        log.debug("更新设备成功，id={}", id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void remove(Long id) {
        getById(id);
        // deleted 字段配置了 @TableLogic，这里执行的是 update 而不是 delete
        deviceMapper.deleteById(id);
        log.debug("删除设备成功，id={}", id);
    }
}
