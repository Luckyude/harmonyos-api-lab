package com.mf.backend.controller;

import cn.hutool.core.date.DateUtil;
import com.mf.backend.common.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 健康检查。
 * 鸿蒙端第一次连本地服务时先打这个接口，确认网络通路和跨域都正常，再调业务接口。
 */
@RestController
@RequestMapping("/health")
public class HealthController {

    @Value("${spring.application.name:mf-server}")
    private String appName;

    @GetMapping
    public Result<Map<String, Object>> health() {
        Map<String, Object> data = new HashMap<>(4);
        data.put("app", appName);
        data.put("status", "UP");
        data.put("time", DateUtil.now());
        data.put("java", System.getProperty("java.version"));
        return Result.ok(data);
    }
}
