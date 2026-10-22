# mf_api · 接口自检

## 做什么

给自己用的接口自检工具：选择 `GET / POST / PUT / DELETE`，填地址和 JSON 请求体，发请求后看状态码、耗时和响应内容前 300 字；可以按原方式、原地址、原请求体重发；保留最近 5 次记录。

界面结构：

1. 请求方式切换：`GET / POST / PUT / DELETE`
2. 地址输入框，默认 `https://www.baidu.com`
3. 请求体输入框（非 GET 时显示，JSON）
4. 「发送」按钮
5. 结果区：状态码、耗时、响应前 300 字；失败时显示失败原因
6. 「重发」按钮 + 最近 5 次历史列表（带请求方式）

## 用的能力

| 能力 | 用途 |
|---|---|
| `@kit.NetworkKit` 的 `http.createHttp()` | 发 GET / POST / PUT / DELETE，指定 10 秒超时、关闭缓存 |
| `@kit.BasicServicesKit` 的 `BusinessError` | 取出网络异常的错误码和原因 |
| `@kit.PerformanceAnalysisKit` 的 `hilog` | 统一 tag `MfApi` 记录地址、状态码、耗时 |

未引入第三方库；只申请了 `ohos.permission.INTERNET`。

## 环境

| 项 | 值 |
|---|---|
| DevEco Studio | 6.1.1 |
| HarmonyOS API | 24（HarmonyOS 6.1.1） |
| 设备 | HUAWEI Pura X 实机（API 26）用于界面验证；Mate 80 Pro Max 模拟器（API 22）用于四项验收 |
| 兼容版本 | `compatibleSdkVersion` 已从 24 降到 `6.0.2(22)`，便于在 API 22 模拟器安装；`targetSdkVersion` 仍为 24 |
| 签名 | 已用 DevEco Studio 自动签名生成，材料在本机 `~/.ohos/config`，不随仓库提交 |

## 怎么跑

1. 用 DevEco Studio 打开 `apps/mf_api`；模拟器可直接运行，真机先配置签名。
2. HTTPS 验收：保持默认地址 `https://www.baidu.com`，点「发送」，结果区应显示 `200` 和页面内容前 300 字。
3. HTTP 验收（电脑起服务）：

   ```bash
   cd 你要共享的目录
   python3 -m http.server 8000
   ```

   - 真机：地址填 `http://电脑局域网IP:8000`，手机和电脑连同一个 WiFi。
   - 模拟器：地址填 `http://10.0.2.2:8000`（模拟器访问宿主机的固定地址）。
   - 也可以直接自检仓库自带的 `backend/`：先启动后端，再填 `http://电脑局域网IP:62633/api/health`。
4. 失败验收：把地址改成没人监听的端口，例如 `http://电脑IP:9999`，结果区应显示「失败」和 `2300007 Failed to connect to the server` 一类原因，页面仍可继续操作。
5. 连点验收：快速点「发送」5 次，5 条结果都会进入历史列表，界面不崩。

## 验收结果（模拟器 API 22）

| 验收项 | 结果 |
|---|---|
| HTTPS：`https://www.baidu.com` | 通过，状态码 200，耗时 192 ms，显示响应前 300 字 |
| HTTP：`http://10.0.2.2:8000`（宿主 `python3 -m http.server 8000`） | 通过，状态码 200，耗时 14 ms，返回 `mf-api-ok` |
| 失败：`http://10.0.2.2:9999` | 通过，显示「失败」和 `2300007 Failed to connect to the server`，页面可继续操作 |
| 连点 5 次 | 通过，历史列表 5 条均为 200（10–74 ms），界面无卡死、无崩溃，无 crash 日志 |
| 重发 | 通过，按结果里的地址再发一次，新增一条历史记录 |
| POST JSON | 通过，真机向局域网 echo 服务发 POST，返回 200，响应回显 `method: POST`、`body` 和 `Content-Type: application/json` |

## 界面

浅暖色系：奶油白背景 + 浅杏色主色 + 暖焦糖强调色，纯色块、无大面积渐变；结果区用柔和色条和状态圆环区分成功/失败，响应内容放在浅米色代码块里；历史记录用左侧色条 + 状态色，并标注请求方式。

## 已知问题

| 现象 | 报错原文 | 原因 | 改法 |
|---|---|---|---|
| 仓库目录直接构建失败（已解决） | `00306003 Specification Limit Violation` / `Invalid project path` | hvigor 要求工程路径只含 ASCII 字符，原父目录名为「鸿蒙API合集」 | 父目录已改名为 `harmonyos-api`，当前路径可直接构建 |
| 真机访问 HTTP 失败（待实测补充） | 暂无 | 常见原因是地址仍用 `10.0.2.2`、手机与电脑不同网段、服务未启动或防火墙拦截 | 改成电脑局域网 IP，先用手机浏览器打开 `http://电脑IP:8000` 确认通路 |
