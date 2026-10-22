package com.mf.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 跨域配置。
 * 鸿蒙端在模拟器里访问本机服务时，来源不是标准域名，本地调试直接放开最省事。
 *
 * <p>两个容易踩的点：
 * <ul>
 *   <li>用 {@code allowedOriginPatterns} 而不是 {@code allowedOrigins}，
 *       否则 allowCredentials=true 时启动会直接抛异常。</li>
 *   <li>pathPattern 写 {@code /**}，写在 context-path 之前，
 *       实际生效范围是 {@code /api/**}。</li>
 * </ul>
 */
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Value("${cors.allowed-origins:*}")
    private String allowedOrigins;

    @Value("${cors.allowed-methods:*}")
    private String allowedMethods;

    @Value("${cors.allowed-headers:*}")
    private String allowedHeaders;

    @Value("${cors.allow-credentials:false}")
    private boolean allowCredentials;

    @Value("${cors.max-age:3600}")
    private long maxAge;

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns(allowedOrigins.split(","))
                .allowedMethods(allowedMethods.split(","))
                .allowedHeaders(allowedHeaders.split(","))
                .exposedHeaders("Content-Disposition")
                .allowCredentials(allowCredentials)
                .maxAge(maxAge);
    }
}
