# mf-backend

本地调试接口服务，给 `apps/` 下的鸿蒙项目联调用。只在本机跑，不对外部署。

## 技术栈

| 组件 | 版本 |
|---|---|
| JDK | 17 |
| Spring Boot | 3.3.5 |
| MyBatis-Plus | 3.5.7（`mybatis-plus-spring-boot3-starter`） |
| MySQL | 8.0 |
| Hutool | 5.8.32 |
| Lombok | 由 Spring Boot 管理 |

端口固定 **62633**（8080 常被本机其他项目占用），接口统一前缀 `/api`。

## 目录结构

按三层组织，另有配置与公共层：

```
src/main/java/com/mf/backend/
├── MfBackendApplication.java    启动类，@MapperScan 在这里
├── controller/                  接口层：接参、调 Service、包 Result
├── service/                     业务接口
│   └── impl/                    业务实现：校验规则、事务都在这里
├── mapper/                      数据访问层：继承 BaseMapper
├── entity/                      数据库实体，与表一一对应
├── dto/                         入参对象，带校验注解
├── common/                      统一响应、状态码、业务异常、全局异常处理
└── config/                      跨域、MyBatis-Plus 插件、字段自动填充

src/main/resources/db/           建库建表 SQL，规范见该目录 README
```

分层规矩：**Controller 不写业务判断，Mapper 不写业务规则，业务规则只在 Service 里**。

## 启动

### 1. 配数据库连接

复制示例文件，填入真实密码：

```bash
cd backend
cp .env.local.example .env.local
```

`.env.local` 已在 `.gitignore` 里，不会被提交。

```bash
export MYSQL_HOST=127.0.0.1
export MYSQL_PORT=3306
export MYSQL_DB=mf_backend
export MYSQL_USER=root
export MYSQL_PASSWORD=你的密码
```

> 本机 3306 通过端口转发指向远程 MySQL 时，`MYSQL_HOST` 仍写 `127.0.0.1`，不用改。

**连内网数据库**：在 `.env.local` 里配一行 `MYSQL_TUNNEL`，`run.sh` 会自动建隧道，脚本退出时自动关闭。

```bash
export MYSQL_TUNNEL=root@服务器IP
```

前提是本机对该服务器配好了 SSH 免密（`ssh root@服务器IP` 不输密码就能进）。`run.sh` 会先探端口，通了就跳过，不通才起隧道。

手动排查：

```bash
ssh -N -L 3306:127.0.0.1:3306 root@服务器IP    # 另开窗口挂着
nc -z -w 3 127.0.0.1 3306 && echo "通了"
```

如果 MySQL 直接对公网开放，把 `MYSQL_HOST` 改成服务器 IP 即可，不用隧道。

### 2. 建库建表

```bash
mysql -h127.0.0.1 -P3306 -uroot -p < src/main/resources/db/V1__init.sql
```

会建 `mf_backend` 库、`device` 表和两条测试数据。脚本可重复执行。

### 3. 起服务

```bash
./run.sh
```

脚本会先加载 `.env.local` 再启动。也可以手动：

```bash
source .env.local && mvn spring-boot:run
```

启动后访问 `http://localhost:62633/api/health` 确认通了。

## 接口清单

所有接口都带统一前缀 `/api`（配置项 `server.servlet.context-path`），Controller 里不重复写。

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/health` | 健康检查，联调前先打这个 |
| GET | `/api/device/page` | 分页查询，支持 `keyword` 模糊搜设备名 |
| GET | `/api/device/{id}` | 详情 |
| POST | `/api/device` | 新增 |
| PUT | `/api/device/{id}` | 修改，只更新传了的字段 |
| DELETE | `/api/device/{id}` | 逻辑删除 |

### 统一响应格式

```json
{ "code": 0, "message": "成功", "data": {}, "timestamp": 1761100000000 }
```

`code` 为 `0` 表示成功，非 `0` 时 `data` 为 null，`message` 是给用户看的原因。

### 调用示例

```bash
curl http://localhost:62633/api/health

curl "http://localhost:62633/api/device/page?pageNum=1&pageSize=10&keyword=Mate"

curl -X POST http://localhost:62633/api/device \
  -H "Content-Type: application/json" \
  -d '{"deviceName":"米饭的 Mate60","deviceModel":"Mate 60 Pro","osVersion":"HarmonyOS 6.0"}'
```

## 跨域与网络

跨域在 `config/CorsConfig.java` 里统一配置，白名单读 `application.yml` 的 `cors.allowed-origins`，本地调试默认 `*`。

鸿蒙端连本机服务时有两点要注意：

1. 模拟器访问宿主机要用 `10.0.2.2`，不是 `localhost`；真机要和电脑在同一局域网，用电脑的局域网 IP。
2. 鸿蒙默认拦截明文 HTTP。真机上访问 `http://` 需要在 `module.json5` 配 `networkSecurityConfig` 放行，这个问题在实测文章里有记录。

## 数据库约定

- **表结构变更一律先写 SQL 脚本**，放 `src/main/resources/db/`，命名 `V{序号}__{描述}.sql`，不改手工建的表。规范见该目录 README。
- 所有表带 `deleted` 字段做逻辑删除（0 未删、1 已删），MyBatis-Plus 自动加条件，业务代码不用管。
- `created_at` / `updated_at` 由 `MyMetaObjectHandler` 自动填充，不手写。
- SQL 日志默认打开（`log-impl: StdOutImpl`），方便看实际执行的语句。

## 注意

- 数据库密码只放 `.env.local`，**绝不写进 `application.yml` 或任何会提交的文件**。
- 上线或对外暴露前必须改：关闭 SQL 日志、收紧跨域白名单、加认证。
