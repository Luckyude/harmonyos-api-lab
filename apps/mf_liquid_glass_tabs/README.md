# mf_liquid_glass_tabs

## 做什么

一个浅色的本地购物界面示例“米饭好物”，用同一批商品和同一个购物袋对比三种底部导航：

| 方案 | 导航做法 |
|---|---|
| 普通导航 | 自绘白色悬浮胶囊，不使用系统材质 |
| 官方沉浸光感 | 官方 UI Design Kit 的 `HdsTabs` 悬浮页签 + `systemMaterialEffect` |
| 社区液态玻璃 | `com.hm.appleui.hw` 2.1.0 的单个 `AppleUI` 透镜，只做底部导航胶囊的材质层 |

界面包含推荐、分类、购物袋、我的四个页面；支持本地搜索、分类筛选、加入购物袋、数量增减、删除和金额汇总。三套方案统一在“我的 → 演示设置”里切换，首页不出现技术调试文案。

社区方案的结构是“实时内容层 → 单个透镜 → 透明点击层”：透镜采样紧邻下层的真实商品内容，商品列表、商品卡和页面背景都不做玻璃化；导航图标、文字、选中态、购物袋角标和点击都由透镜上方的透明 `BottomNavBar` 负责。

## 用的能力

| Kit / 模块 | 用途 |
|---|---|
| `com.hm.appleui.hw` 2.1.0 的 `AppleUI` | 社区方案的单个液态玻璃透镜（GPU 实时渲染、自动采样紧邻下层） |
| `@kit.UIDesignKit` 的 `HdsTabs`、`HdsTabsController`、`hdsMaterial` | 官方悬浮页签、系统材质参数、材质能力查询 |
| ArkUI `Tabs` / `Scroller` / `Stack` / `TextInput` | 普通与社区导航的页面容器、滚动、叠放、本地搜索输入 |
| `@kit.ArkUI` 的 `window`、`display` | 全屏布局、状态栏/导航条透明、读取系统安全区与屏幕宽度 |
| `@kit.BasicServicesKit` 的 `deviceInfo`、`BusinessError` | 读取设备 ABI 与系统 API（社区能力检查）、记录真实错误码 |
| `@kit.PerformanceAnalysisKit` 的 `hilog` | 统一 tag `MfShop` 记录启动、搜索、加购、数量变化、方案切换和能力检查 |

只引入 AppleUI 一个第三方依赖（仅 `entry` 模块使用），未接后端，未申请任何权限（含 `ohos.permission.VIBRATE`）。

## 环境

| 项 | 版本 / 值 |
|---|---|
| DevEco Studio | 6.1.1（`DS-243.24978.46.36.611300`） |
| HarmonyOS SDK | API 24（HarmonyOS 6.1.1） |
| compile / target / compatible | `6.1.1.125` / `6.1.1(24)` / `6.1.0(23)` |
| 社区库 | `com.hm.appleui.hw` 2.1.0（`compatibleSdkVersion` = API 20） |
| 社区库原生 ABI | 只有 `arm64-v8a`（`libliquidglass.so`、`libc++_shared.so`） |
| 设备 | 真机 HUAWEI Pura X（VDE-AL00，HarmonyOS 7.0.0.109，API 26，arm64-v8a）；Mate 80 RS 模拟器（API 24，arm64-v8a） |
| 是否需签名 | 真机需要；模拟器可直接安装 debug HAP |

社区方案的实际前置条件：设备 ABI 含 `arm64-v8a`，且系统 API ≥ 20，并具备 OpenGL ES 3.0 渲染条件；不满足时设置页显示原因、社区方案不可选。

> 工程内不提交签名证书和密码。本次真机部署使用本机 `default_mf_liquid_glass_tabs` 签名材料，bundle 保持 `com.mf.liquidglasstabs`；签名配置只用于本次验证，未提交。验证完成后已移除工程内的 `signingConfigs`，真机运行前请在 DevEco Studio 中配置自己的签名。

## 怎么跑

1. 在应用工程根目录（`apps/mf_liquid_glass_tabs`）安装依赖：

   ```bash
   /Applications/DevEco-Studio.app/Contents/tools/ohpm/bin/ohpm install
   ```

   装完确认 `entry/oh_modules/com.hm.appleui.hw` 软链到 `oh_modules/.ohpm/com.hm.appleui.hw@2.1.0/...`，且 `entry/oh-package-lock.json5` 里锁的是 `2.1.0`。
2. 用 DevEco Studio 打开本目录，同步依赖。
3. 模拟器直接运行；真机先在 DevEco Studio 配置签名，再选择设备运行（社区方案需要 arm64-v8a 真机才能看到实际玻璃）。
4. 启动后默认进入“官方沉浸光感”方案和推荐页。
5. 在搜索框输入“杯”“耳机”等关键词，或点击“居家 / 随行 / 数码 / 收纳”筛选商品。
6. 点击商品卡的“加入”，再点底部“购物袋”，验证数量增减、删除和合计。
7. 进入“我的 → 演示设置”，在“普通导航 / 官方沉浸光感 / 社区液态玻璃”之间切换；社区方案在支持的设备上可直接选择，设备不满足时该行变灰并显示“不可用”和具体原因。

## 实现要点

- 商品数据在 `constants/ShopData.ets` 本地维护，8 件商品、4 个分类和导航配置共用一份数据。
- 购物袋状态在 `service/CartStore.ets`，用 `@ObservedV2` + `@Trace` 观察数量变化；三套方案共享 `Index` 持有的同一个实例，不写入 PersistentStorage，退出即清空。
- 推荐页：品牌区、44vp 搜索框、78vp 主题卡、四个分类入口、双列商品网格；首屏能完整看到一排商品卡。
- 分类页：四个分类卡显示真实商品数量，下方复用同一商品卡和 `CartStore`。
- 购物袋：本地行项目、数量步进器、删除、合计；空态提供“去逛逛”回推荐页。
- 我的：访客卡、关于说明、演示设置；官方材质状态和社区玻璃能力只在设置页展示。
- 普通导航：`Tabs` 承载页面，`BottomNavBar` 自绘白色实体悬浮胶囊，不使用模糊或系统材质。
- 官方导航：`HdsTabs` 使用 `.barOverlap(true)`、`.barPosition(BarPosition.End)`、`.barFloatingStyle({ ... systemMaterialEffect ... })`；材质参数为 `ADAPTIVE` / `ADAPTIVE`。
- 图标统一在 `AppIcon` 的 24vp 视口内定义并随 `iconSize` 缩放：底部导航 32vp 布局、推荐页分类 36vp、分类页 40vp；由于 `Path.commands` 单位是 px，`AppIcon` 会按 `vp2px(1) * iconSize / 24` 缩放路径坐标，否则在高密度屏上图标仍会偏小。
- 页面底部固定留 128vp，商品列表滚到底时最后一件能完整露出在导航上方。
- 全屏后读取顶部和底部安全区 px，换算成 vp 作为内容内边距；系统栏内容色改为深色，适配浅色页面。
- 商品图和横幅是本地资源，由阿里云百炼 `qwen-image-3.0` 生成后保存到 `resources/base/media/`，离线可显示，不依赖网络。

### 社区液态玻璃（`components/CommunityShoppingTabs.ets`）

- 依赖：`entry/oh-package.json5` 声明 `"com.hm.appleui.hw": "2.1.0"`，没有放进工程根 `oh-package.json5`；版本固定，不静默升级。
- 结构固定三层，`Stack({ alignContent: Alignment.Bottom })` 自下而上：

  ```text
  Tabs(barHeight 0)                 ← 实时业务内容，也是透镜的紧邻下层采样目标
    RecommendedPage / CategoryPage / BagPage / ProfilePage(currentMode: 2)
  Row(水平居中 / bottom 14)
    AppleUI(Width = 272vp, Height = 68)          ← 唯一一个透镜
  Row(水平居中 / bottom 14)
    BottomNavBar(glassSurface: true)             ← 透明点击层，位于透镜之上
  ```

- 三套导航统一尺寸：`272vp × 68vp`，底部距安全区 `14vp`；4 个页签各 `62vp`，左右内缩 `12vp`，与官方 HdsTabs 的实测外框和图标中心一致。
- 透镜最终参数：`Width = 272vp`、`Height = 68`、`Circle = '100%'`、`Blur = 0`、`NeoStrength = 0.22`、`ProUI = false`、`Vibrate = false`，全应用只创建一个实例。
- 透镜宽度固定为官方页签宽度 `272vp`；`Stack.onAreaChange` 只在容器窄于 304vp 时收紧到 `容器宽度 - 32vp`，避免小屏溢出。透镜、普通导航和点击层共用同一组常量，不再各自按整屏宽度铺开。
- `AppleUI` 2.1.0 会自动取“本层之前、与透镜可见区域重叠的紧邻兄弟层”作为采样目标，因此 `Tabs` 必须排在透镜之前，点击层必须排在透镜之后；透镜外层 `Row` 与点击层都不设背景色，避免采样到白色底板或空层（那会得到黑图）。
- 点击隔离：透镜 `ProUI = false` 不挂手势，`Row` 设 `hitTestBehavior(HitTestMode.Transparent)`；导航点击由上层透明 `BottomNavBar` 处理，不把图标塞进 AppleUI 的尾随媒体插槽（媒体层不参与命中测试）。
- `BottomNavBar` 新增 `glassSurface` 模式：不画白底和边线，只保留布局、图标、文字、角标和点击，并用极轻投影勾出胶囊边界；默认 `false` 时外观与改造前一致。
- 4 个导航入口、选中态、购物袋真实角标（`cart.count`）和“去逛逛 → 第 0 个页签”全部复用普通方案同一套实现，不新建第二个 `CartStore`。
- 生命周期：`Index` 用 `if / else if / else` 条件渲染三套包装组件。离开社区方案时整棵子树销毁，`AppleUI` 随组件释放原生渲染资源；再切回社区时重新创建唯一一个透镜，购物袋数据不受影响。
- 能力检查在 `service/CapabilityService.ets`：读 `deviceInfo.abiList` 是否含 `arm64-v8a`、`deviceInfo.sdkApiVersion` 是否 ≥ 20，并固定库版本 `2.1.0`；不联网、不申请权限。它只证明“满足加载条件”，不代表原生渲染已经出图——渲染结果要真机看，不在设置页写“渲染成功”。

## 实际验证

> 以下结果包含本次在真机 HUAWEI Pura X 上对社区液态玻璃方案的手动 UI 抽查。构建为 unsigned，随后用本机签名配置完成 `SignHap` 并安装；社区方案截图见本次交付记录。未做逐故事 UI 自动化，也不写帧率、耗电或 GPU 性能结论。

| 验收项 | 结果 |
|---|---|
| 首屏品牌、搜索、主题卡、分类、商品网格 | 通过，真机首屏完整显示第一排商品卡（图、名称、规格、价格、加入） |
| 导航与分类图标 | 通过，底部导航 32vp 布局（视觉约 21vp）、推荐分类 36vp（约 24vp）、分类页 40vp（约 27vp）；真机图标明显放大，图标与文字保留间距，首排商品仍完整在导航上方 |
| 本地搜索 | 通过，输入“杯”得到 2 件商品 |
| 搜索空态 | 通过，输入“zzz”显示“没有找到相关商品”和“清空搜索”，清空后恢复 8 件 |
| 推荐页分类筛选 | 通过，数码筛选得到 2 件，带当前分类标签和清除入口 |
| 分类页四个分类 | 通过，数量分别为居家 1、随行 3、数码 2、收纳 2 |
| 加入购物袋 | 通过，角标从 0 变 1，购物袋出现对应商品 |
| 购物袋数量与合计 | 通过，同一商品加到 3 件，合计从 ¥89 变 ¥267，角标同步为 3 |
| 购物袋减到空 | 通过，减到 0 后显示空态和“去逛逛” |
| 滚动到列表底部 | 通过，最后一件“旅行收纳袋”和“铝合金桌面支架”完整出现在导航上方 |
| 普通 / 官方切换 | 通过，切换后回到推荐页；普通白色胶囊与官方悬浮页签均可用 |
| 官方案例材质 | 真机通过，`getSystemMaterialTypes()` 返回 `IMMERSIVE`，设置页显示“IMMERSIVE 可用（IMMERSIVE）” |
| 社区方案：单个透镜 + 实时采样 | 通过。真实商品/帆布袋/藤篮内容透过透镜可见；透镜边缘有轻微色散，无黑块、无青/品红自反馈；滚动时采样内容跟手，透镜位置固定 |
| 社区方案：白底页面导航可见性 | 通过。分类、购物袋空态和我的页面没有商品内容可折射，透镜中心保持透明；用 `#0D000000`、18vp 模糊、向下 6vp 的极轻投影勾出胶囊边界，不再像导航消失 |
| 三套导航尺寸对齐 | 通过。官方 HdsTabs 外框 `252..1068 × 1874..2078`（272 × 68vp，底部 14vp）；普通和社区外框与四个页签中心 `381 / 567 / 753 / 940` 对齐，不再出现宽度或点击中心偏移 |
| 社区方案：四栏点击 | 通过。在官方页签中心 `381 / 567 / 753 / 940` 点击，推荐/分类/购物袋/我的均可来回切换，选中态为绿色；购物袋角标为真实数量 |
| 社区方案：购物袋跨方案一致 | 通过。加购 1 件、数量加到 2 件后切官方再切回社区，角标和合计保持 2 件；日志记录 `2 → 1`、`1 → 2` 和购物袋 2 件保持不变 |
| 社区方案：搜索/筛选/滚动/空态/数量/删除 | 通过。搜索“杯”可过滤；数码筛选显示 2 件；滚动到底部最后两件完整露出；购物袋加减、删除到空态均正常 |
| 社区方案：页面重进与生命周期 | 通过。离开社区时 AppleUI 随组件销毁，切回时只创建 1 个透镜；`AppleUI` 日志为 `XComponent onLoad`、`GPU ready 1404 x 384`，切走时出现一次 `updateSnapshot ret=-11`，无可见异常 |
| 社区方案：前后台恢复 | 通过。Home 后再启动，搜索、筛选和购物袋状态保留，玻璃导航仍可用 |
| 社区方案：设置页能力说明 | 通过。真机显示 `AppleUI 2.1.0 · arm64-v8a · API 26`，社区行可选；不满足 ABI/API 时显示原因并禁用 |

## 运行截图

真机 HUAWEI Pura X（`VDE-AL00`，1320 × 2120）截图，均来自本次社区方案重跑：

| 截图 | 内容 |
|---|---|
| [official-aligned.png](screenshots/official-aligned.png) | 官方 HdsTabs 基准：外框 272 × 68vp，页签中心 381 / 567 / 753 / 940 |
| [plain-aligned.png](screenshots/plain-aligned.png) | 普通导航已收窄到同一 272vp 外框 |
| [community-home.png](screenshots/community-home.png) | 社区方案首屏，272vp 单透镜覆盖真实商品图，点击中心与官方一致 |
| [community-scroll.png](screenshots/community-scroll.png) | 列表滚动后透镜继续采样紧邻的藤篮/咖啡杯内容 |
| [community-category.png](screenshots/community-category.png) | 社区方案分类页，透镜在分类卡内容上 |
| [community-bag.png](screenshots/community-bag.png) | 社区方案购物袋，真实角标与数量/删除/合计 |
| [settings-community.png](screenshots/settings-community.png) | 演示设置中的社区方案选中态与能力状态 |
| [official-cart-retained.png](screenshots/official-cart-retained.png) | 切回官方方案后购物袋 2 件仍保留 |

## 已知问题

| 现象 | 报错原文 | 原因 | 改法 |
|---|---|---|---|
| 模拟器上官方导航是浅色默认样式，没有沉浸材质 | `Get double by name error, resName=sys.float.hms_material_style, errorCode=9001003`；`MaterialConfigFactory::GetConfig config not found in static map` | API 24 模拟器未提供 HDS 系统材质，`getSystemMaterialTypes()` 返回空数组 | 设置页显示“未返回材质类型”，不把默认样式写成成功；真机 Pura X 返回 `IMMERSIVE`，已单独验证 |
| 真机每次安装后弹出“USB 连接方式”系统弹窗 | 无应用侧报错 | 设备安装时 USB 模式重置，属于系统行为 | 选择“仅充电”并确认，再重新打开应用；不影响应用代码 |
| 直接构建提示未签名 | `No signingConfig found for product default` | 工程不提交本机证书和密码 | 在 DevEco Studio 配置自己的签名后再运行真机；模拟器可直接装 debug HAP |
| 切换方案后购物袋可保留，但退出应用即清空 | 无报错 | 演示数据只放内存，按要求不接持久化 | 这是当前演示范围；需要保留时再引入 Preferences 或数据库 |
| 高密度真机上图标比设计的 32/36/40vp 明显偏小 | 无应用报错；实测底部导航图标仅约 38px 高 | `Path.commands` 的坐标单位是 px，不是 vp；把 24 单位路径放进 40vp 组件并不会按 vp 放大 | `AppIcon` 按 `vp2px(1) * iconSize / 24` 重写路径坐标；圆弧改成三次贝塞尔，避免缩放时误改 arc flag |
| 社区库的 HAR 在自身 `module.json` 里声明了 `ohos.permission.VIBRATE` | 无；本工程最终 HAP 的 `module.json` 中 `requestPermissions` 为空 | 库的震动反馈（`Vibrate: true`）需要该权限；本工程传 `Vibrate: false`，应用侧 `module.json5` 也没有任何 `requestPermissions` | 未修改第三方库源码。已核对最终 HAP 未新增 VIBRATE；如果后续升级库或改变合并行为，重新检查最终 HAP 的 `module.json` |
| 社区库只有 `arm64-v8a` 原生库，且要求 API 20+ | 无（已核对） | `libliquidglass.so` 只提供 arm64-v8a，`compatibleSdkVersion` 为 API 20 | `CapabilityService` 在设置页提前判定并禁用社区方案；不支持的设备只用普通/官方方案 |
| 切离社区方案时 AppleUI 打印一次 `updateSnapshot ret=-11` | `AppleUI: updateSnapshot ret=-11` | 组件销毁和原生采样线程释放存在时序差，未观察到黑块、闪退或购物袋状态异常 | 当前作为已知警告记录；重新进入社区方案可正常创建新透镜并出图，未修改原生库 |

## 日志

统一 tag：`MfShop`。

```text
🛍️ 米饭好物启动，方案=1，安全区 top=38.8vp bottom=0vp
🟢 HDS 材质类型: IMMERSIVE
🟢 社区玻璃能力检查通过：AppleUI 2.1.0 · arm64-v8a · API 26
🔴 社区玻璃能力检查未通过：当前设备 ABI 不含 arm64-v8a（x86_64）
🫧 社区液态玻璃导航已创建：单透镜，宽度=272vp
🧭 社区导航切换到 购物袋
🧹 社区液态玻璃导航已销毁：AppleUI 随组件释放，购物袋状态保留
🎛️ 当前演示方案切换为 社区液态玻璃（1 → 2），购物袋 2 件保持不变
🛒 加入购物袋: 随行保温杯，总件数=1
➕ 购物袋增加: 随行保温杯，数量=3
🔴 社区玻璃能力检查异常 code=... message=...
```

## 未做

- 未做逐故事 UI 自动化；本次是手动抽查并保存截图，不写帧率、耗电或 GPU 性能结论。
- 未覆盖平板/折叠屏和模拟器上的社区方案（库只有 arm64-v8a，模拟器通常不满足 ABI；当前 `deviceTypes` 只声明 `phone`）。
- 未接入登录、支付、订单、商品后台和图片 CDN。
- 商品图是 AI 生成的演示资源，不是真实商品实拍。
- 未提交、未推送。
