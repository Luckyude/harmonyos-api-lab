# 数据库脚本

所有表结构变更都先写这里，再执行，不靠手工在客户端点。

## 命名

```
V{序号}__{描述}.sql
```

例：`V1__init.sql`、`V2__add_upload_file.sql`

双下划线是 Flyway 的约定，即使现在没接 Flyway，将来接上也能直接用。

## 三条规矩

1. **脚本可重复执行**。建表用 `CREATE TABLE IF NOT EXISTS`，建库用 `CREATE DATABASE IF NOT EXISTS`，别人重复跑不报错。
2. **已发布的脚本不再修改**。需要改结构就新增 `V2__xxx.sql`，不要回头改 `V1`。别人按顺序执行时，改过的 `V1` 会让你俩的库不一致。
3. **一个脚本只干一件事**。加一张表、加一个字段各写一个文件，出问题好定位。

## 当前脚本

| 脚本 | 内容 |
|---|---|
| `V1__init.sql` | 建 `mf_backend` 库，建 `device` 表，插入两条测试数据 |

## 执行

```bash
# 整库初始化
mysql -h127.0.0.1 -P3306 -uroot -p < V1__init.sql

# 只执行某次变更
mysql -h127.0.0.1 -P3306 -uroot -p mf_backend < V2__add_upload_file.sql
```

连接信息见 `backend/.env.local`（本地文件，不进 Git）。

## 约定

- 字符集统一 `utf8mb4`，别用 `utf8`（那是 utf8mb3，存不了 emoji）。
- 每张表带 `deleted` 字段做逻辑删除（0 未删 / 1 已删），MyBatis-Plus 自动加条件。
- 每张表带 `created_at` / `updated_at`，由 `MyMetaObjectHandler` 自动填充，不用业务代码写。
- 表和字段必须写 `COMMENT`，开源出去别人看得懂。
