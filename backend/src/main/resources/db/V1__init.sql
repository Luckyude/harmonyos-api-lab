-- ============================================================
-- V1 初始表结构
-- 执行：mysql -h127.0.0.1 -P3306 -uroot -p < V1__init.sql
-- 规矩：已发布的脚本不再修改，后续变更另起 V2__xxx.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS `mf_backend`
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE `mf_backend`;

-- 设备信息表：鸿蒙端上报设备信息时用
CREATE TABLE IF NOT EXISTS `device`
(
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `device_name`  VARCHAR(64)  NOT NULL COMMENT '设备名，如 米饭的 Mate60',
    `device_model` VARCHAR(64)  DEFAULT NULL COMMENT '设备型号',
    `os_version`   VARCHAR(32)  DEFAULT NULL COMMENT '系统版本，如 HarmonyOS 6.0',
    `remark`       VARCHAR(255) DEFAULT NULL COMMENT '备注',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`      TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0 未删，1 已删',
    PRIMARY KEY (`id`),
    KEY `idx_device_name` (`device_name`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='设备信息表';

-- 两条测试数据，方便鸿蒙端一接上就有数据可查
INSERT INTO `device` (`device_name`, `device_model`, `os_version`, `remark`)
VALUES ('米饭的真机', 'Mate 60 Pro', 'HarmonyOS 6.0', '本地调试用'),
       ('模拟器', 'Phone Emulator', 'HarmonyOS 6.0', '无相机与定位，仅测接口');
