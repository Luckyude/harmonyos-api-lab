package com.mf.backend;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 本地调试接口服务启动类。
 * 接口统一前缀见 application.yml 的 server.servlet.context-path（默认 /api）。
 */
@SpringBootApplication
@MapperScan("com.mf.backend.mapper")
public class MfBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(MfBackendApplication.class, args);
    }
}
