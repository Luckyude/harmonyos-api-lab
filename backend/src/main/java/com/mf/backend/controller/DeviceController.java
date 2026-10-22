package com.mf.backend.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.mf.backend.common.Result;
import com.mf.backend.dto.DeviceQuery;
import com.mf.backend.dto.DeviceSaveDTO;
import com.mf.backend.entity.Device;
import com.mf.backend.service.DeviceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 设备接口。只做三件事：接参、调 Service、包 Result。
 * 业务校验和异常处理都不写在这里。
 *
 * <p>实际访问路径带网关前缀，例如 {@code GET /api/device/page}。
 */
@RestController
@RequestMapping("/device")
@RequiredArgsConstructor
public class DeviceController {

    private final DeviceService deviceService;

    /** 分页查询：/api/device/page?pageNum=1&pageSize=10&keyword=Mate */
    @GetMapping("/page")
    public Result<Page<Device>> page(@Valid DeviceQuery query) {
        return Result.ok(deviceService.page(query));
    }

    /** 详情：/api/device/1 */
    @GetMapping("/{id}")
    public Result<Device> detail(@PathVariable Long id) {
        return Result.ok(deviceService.getById(id));
    }

    /** 新增 */
    @PostMapping
    public Result<Long> create(@Valid @RequestBody DeviceSaveDTO dto) {
        return Result.ok(deviceService.create(dto));
    }

    /** 修改：只更新传了的字段 */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody DeviceSaveDTO dto) {
        deviceService.update(id, dto);
        return Result.ok();
    }

    /** 删除：逻辑删除，数据仍在库里 */
    @DeleteMapping("/{id}")
    public Result<Void> remove(@PathVariable Long id) {
        deviceService.remove(id);
        return Result.ok();
    }
}
