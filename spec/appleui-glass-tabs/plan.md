# Implementation Plan: AppleUI 社区液态玻璃导航接入

**Input**: Feature specification from `/Users/pangyude/AiCode/wx/harmonyos-api/harmonyos-api-lab/spec/appleui-glass-tabs/spec.md`

## Summary

在现有 `apps/mf_liquid_glass_tabs` 中新增第三个导航方案：`com.hm.appleui.hw` 2.1.0 单透镜液态玻璃。普通方案继续使用 `PlainShoppingTabs`，官方方案继续使用 `OfficialShoppingTabs`，社区方案新增一个轻量包装组件，复用四个业务页面和同一个 `CartStore`。

社区方案的结构固定为“实时内容层 → 单个 AppleUI 透镜 → 独立导航点击层”三层。AppleUI 只覆盖底部导航胶囊，采样目标为其紧邻下方的 `Tabs` 内容；导航图标、文字、选中态、购物袋角标和点击区在透镜上方独立渲染，不放进 AppleUI 的媒体插槽，也不改变商品列表的业务结构。

## Technical Context

**Language/Version**: ArkTS / ArkUI，Stage 模型；现有工程 HarmonyOS SDK API 24 编译，设备 API 26  
**Primary Dependencies**: `com.hm.appleui.hw` 2.1.0（源码 HAR，含 arm64-v8a `libliquidglass.so`、`libc++_shared.so`）；现有 `@kit.UIDesignKit`、ArkUI、`@kit.PerformanceAnalysisKit`、`@kit.BasicServicesKit`  
**State Management**: 沿用现有 V2（`@ComponentV2` / `@Local` / `@Param` / `@Event` / `@ObservedV2` / `@Trace`）；不引入 V1，不做 MVVM 迁移  
**Storage**: 购物袋仍在内存 `CartStore`；不新增持久化、不写入数据库  
**Testing**: `arkts_check`、`devecocli build`、真机 Pura X 安装与 UI 操作/截图、hilog 日志核对  
**Target Platform**: HarmonyOS 手机；验证设备 HUAWEI Pura X `VDE-AL00`，API 26，`arm64-v8a`；模拟器可作为辅助，但社区原生库只支持 arm64-v8a  
**Project Type**: HarmonyOS 移动应用（现有单 HAP 工程）  
**Performance Goals**: 不新增可量化的帧率或耗电目标；目标是导航和业务交互不阻塞、玻璃随实时内容更新、单实例运行；不写未经测量的性能结论  
**Constraints**: 固定 AppleUI 2.1.0；不申请振动权限；`ProUI=false`、`Vibrate=false`；首轮 `Blur=0`；只允许一个社区透镜；不得把商品列表整体玻璃化；不修改 `mf_api`；不提交/推送  
**Scale/Scope**: 1 个应用、3 个导航方案、1 个社区透镜、4 个业务页面、8 件本地商品；不新增页面和业务数据源

## Project Structure

### Documentation (this feature)

```text
/Users/pangyude/AiCode/wx/harmonyos-api/harmonyos-api-lab/spec/appleui-glass-tabs/
├── spec.md
├── plan.md
└── tasks.md              # Phase 3 生成
```

### Source Code (repository root)

```text
/Users/pangyude/AiCode/wx/harmonyos-api/harmonyos-api-lab/apps/mf_liquid_glass_tabs/
├── oh-package.json5                         # 工程级依赖（不在此处重复添加 AppleUI）
├── oh-package-lock.json5                    # 安装后锁定 2.1.0
├── entry/
│   ├── oh-package.json5                     # 新增 com.hm.appleui.hw: 2.1.0
│   ├── oh-package-lock.json5                # 模块安装锁（若 ohpm 生成）
│   └── src/main/
│       ├── module.json5                     # 不新增权限
│       └── ets/
│           ├── pages/
│           │   ├── Index.ets                # 增加 community 分支、能力状态、日志
│           │   ├── ProfilePage.ets          # 社区方案状态与说明
│           │   ├── RecommendedPage.ets      # 业务页面不改结构
│           │   ├── CategoryPage.ets         # 业务页面不改结构
│           │   └── BagPage.ets              # 业务页面不改结构
│           ├── components/
│           │   ├── PlainShoppingTabs.ets    # 普通方案，保持现有结构
│           │   ├── OfficialShoppingTabs.ets # 官方方案，保持现有结构
│           │   ├── BottomNavBar.ets         # 增加透明点击层模式，默认保持白胶囊
│           │   └── CommunityShoppingTabs.ets# 新增社区三层结构
│           ├── constants/
│           │   └── ShopData.ets             # 社区方案描述与启用信息
│           ├── model/
│           │   └── Product.ets              # SchemeOption / 能力状态模型
│           ├── service/
│           │   ├── CartStore.ets            # 不改业务状态
│           │   └── CapabilityService.ets    # 新增 ABI/API/库版本检查
│           └── utils/
│               └── PriceUtil.ets            # 不改
└── README.md                                # 最终版本、参数、验证、调试记录
```

**Structure Decision**: 遵循现有单 HAP、V2 状态管理和 `pages/components/model/service/constants/utils` 目录约定，不引入 MVVM 目录或新状态体系。新增文件限定为 `CommunityShoppingTabs.ets` 和 `CapabilityService.ets`；其余为现有文件的小范围扩展，避免重做业务页面。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 新增社区包装组件 | 需要在不改动四个业务页面的前提下组合 Tabs、AppleUI 透镜和独立点击层 | 直接在 `PlainShoppingTabs` 内叠加会让普通方案也携带 AppleUI 分支，并增加回归风险 |
| 新增能力检查服务 | 社区库仅 arm64-v8a，若在其它 ABI 上直接加载会失败或黑屏 | 只在 README 说明无法阻止用户在应用内选择不可用方案，不能准确展示能力状态 |

## Research & Decisions

### 版本与环境

- **Decision**: 固定 `com.hm.appleui.hw` 2.1.0，不升级或降级。
- **Rationale**: ohpm 当前 `latest` 为 2.1.0；README/REMIND 明确 `compatibleSdkVersion` 为 API 20、仅提供 arm64-v8a；当前设备 API 26、arm64-v8a，工程 target API 24，满足要求。2.1.0 已包含“紧邻下层采样”和空层黑图判定修复，直接对应本特性的黑块风险。
- **Alternatives considered**: 2.0.2 已有紧邻层语义和多实例隔离，但缺少 2.1.0 的空层黑图判定与 `updateSnapshot`/`clearSnapshot` 稳定性加固；旧版本只会增加黑块风险，因此不采用。

### 依赖放置

- **Decision**: 在 `entry/oh-package.json5` 声明 `com.hm.appleui.hw: 2.1.0`，在应用工程根目录执行 ohpm 安装，保留生成的 lock 文件。
- **Rationale**: 只有 `entry` 使用 AppleUI；模块级依赖边界清晰，避免把原生库依赖扩散到工程级。
- **Alternatives considered**: 放在根 `oh-package.json5`；也能解析，但会让依赖作用域大于实际使用范围，且不利于后续拆分 HAR/HSP。

### 社区导航结构

- **Decision**: 使用 `Stack({ alignContent: Alignment.Bottom })`，子层顺序为：`Tabs` 实时内容层 → 单 AppleUI 透镜 → 透明导航点击层。AppleUI 只放在底部导航胶囊的尺寸槽位内。
- **Rationale**: AppleUI 2.1.0 自动选取“本层之前、与透镜可见区域重叠的紧邻兄弟层”作为采样目标；`Tabs` 是透镜之前唯一有实际内容的层，透镜自身和上方点击层不会被采样。点击层在透镜之后，保证导航事件不被玻璃吞掉。
- **Alternatives considered**: 把图标放进 AppleUI 尾随媒体插槽；媒体层不参与命中测试，会导致导航无法点击，因此拒绝。把普通 `BottomNavBar` 的白底保留在玻璃下方；会采样到白色底板而不是商品内容，因此拒绝。

### 透镜尺寸与参数

- **Decision**: 透镜宽度按导航胶囊内容宽度计算（内容宽度减左右各 16vp），高度 68vp，底部距安全区/容器底部 14vp，`Circle='100%'`；`Blur=0`、`NeoStrength=0.22`、`ProUI=false`、`Vibrate=false`。
- **Rationale**: 与现有普通/官方导航的胶囊外框接近；`Circle='100%'` 在 68vp 高时得到半径 34vp 的胶囊；首轮不模糊中心，保证“看穿”真实商品；温和折射保留玻璃边缘特征；关闭弹性交互避免整条导航被拖走。
- **Alternatives considered**: 使用 `Blur=8~20` 的磨砂效果；中心不再透明，不符合首轮要求。开启 ProUI；会产生拖动/放大并可能移动导航，明确拒绝。使用固定百分比宽度；AppleUI `Width` 是 number/vp，不能直接传百分比字符串。

### 采样与黑块防护

- **Decision**: 不手写采样目标或截帧 API，依赖 AppleUI 2.1.0 的紧邻下层解析；结构上保证 `Tabs` 是透镜之前的内容层，点击层和玻璃不进入采样。玻璃层、玻璃外层 Row 和点击层都不设置不透明背景。
- **Rationale**: 该库明确要求采样目标为紧邻下层且不含自身；空白特效层/不透明底板会产生黑图或错误背景。2.1.0 已内置黑图判定和跳过逻辑，但结构仍必须正确。
- **Alternatives considered**: 给玻璃外层加白色半透明底板以提升文字可读性；会遮住真实商品内容，违背“采样真实内容”，首轮不采用。给 AppleUI 传入自定义背景；库不支持也不应传入。

### 点击与滚动隔离

- **Decision**: 导航点击层使用透明的 `BottomNavBar` 变体，位于 AppleUI 之后；AppleUI `ProUI=false`，不挂手势；四个入口仍由现有 `AppIcon`、`Text`、角标和 `onClick` 组成。
- **Rationale**: 玻璃只负责视觉；点击层在上方接收导航事件；页面滚动区域不被底部点击层覆盖，产品列表滚动不受影响。AppleUI 在 `ProUI=false` 时透传手势，但本方案仍以独立点击层为准，避免依赖库内部手势实现。
- **Alternatives considered**: 用 AppleUI 的 `Click` 处理导航；单个 `Click` 无法区分四个入口，且会把导航语义塞进材质组件，拒绝。

### 能力状态与失败呈现

- **Decision**: 新增 `CapabilityService`，检查 `deviceInfo.abiList` 是否包含 `arm64-v8a`、`deviceInfo.sdkApiVersion >= 20`，并返回库版本/可用状态；设置页显示社区库版本和 ABI/API 结论。不满足时社区行不可选，说明原因；满足时显示 `AppleUI 2.1.0 · arm64-v8a · 单透镜`，不写“渲染成功”这类未测量结论。
- **Rationale**: AppleUI 没有公开的运行时渲染状态回调；ABI/SDK 是可验证的前置条件。实际材质是否出图由真机截图和 hilog 验证，最终报告如实记录。
- **Alternatives considered**: 仅写死“已接入”；无法区分 ABI 不匹配或原生加载失败，违背不伪造成功的要求。自动回退到普通导航；会掩盖失败，用户明确要求准确说明而不是降级冒充成功。

### 生命周期与方案切换

- **Decision**: `Index` 通过 `mode` 条件渲染三个包装组件；社区模式销毁时 AppleUI 随组件销毁；重新进入社区时重新创建单个实例。购物袋 `CartStore` 由 `Index` 持有并传入三个包装组件。
- **Rationale**: 条件渲染天然避免普通/官方/社区同时存在多个 AppleUI；AppleUI 自身在 `aboutToDisappear` 释放 native 线程和 GL 资源；不改 CartStore 生命周期。
- **Alternatives considered**: 三个方案同时挂载、用显隐切换；会保留 AppleUI 实例并持续截帧，增加重复实例和后台资源风险，拒绝。

### 可读性与视觉

- **Decision**: 玻璃中心保持透明，不加覆盖商品内容的白色渐变或大面积遮罩；导航图标和文字继续使用现有绿色/深灰体系，必要时仅对导航文字增加轻微阴影或提高字重，不改变商品区。首轮在浅色真实商品图上验证可读性。
- **Rationale**: 符合“保留浅色底、真实图片、不要技术卡片/大遮罩”的要求；玻璃边缘折射会形成自然的边界，不应再叠加底板。
- **Alternatives considered**: 在透镜内加白色半透明背景；会破坏中心看穿和真实采样，且用户明确不希望大面积遮罩。

## Data Model

### SchemeOption

- `id`: 0/1/2，分别对应普通、官方、社区。
- `title`: 展示名称。
- `description`: 能力说明，社区包含 AppleUI 版本和单透镜描述。
- `enabled`: 静态可选项；社区的实际可用性还要与 `CapabilityService` 结果合并。

### AppleUICapability

- `available`: 布尔值；ABI 包含 arm64-v8a 且 API 版本满足时 true。
- `libraryVersion`: 固定 `2.1.0`。
- `abiSupported`: `deviceInfo.abiList` 是否包含 `arm64-v8a`。
- `apiSupported`: `deviceInfo.sdkApiVersion` 是否不低于 20。
- `statusText`: 设置页展示的简短结论，如“arm64-v8a · API 26 · AppleUI 2.1.0”或“当前设备 ABI 不支持 arm64-v8a”。

### CommunityNavConfig

- `width`: 导航胶囊内容宽度（vp），由容器宽度减左右各 16vp 得出。
- `height`: 68vp。
- `bottomMargin`: 14vp。
- `circle`: `'100%'`。
- `blur`: 0。
- `neoStrength`: 0.22。
- `proUI`: false。
- `vibrate`: false。
- `instanceCount`: 固定 1。

### CartState

- 继续由现有 `CartStore` 持有；本特性不新增字段，不改变数量、价格、合计或删除语义。

## Contracts & Interfaces

### AppleUI 2.1.0 对外契约

- 导出：`AppleUI` 组件，从 `com.hm.appleui.hw` 入口导入。
- `Width`: number，单位 vp，根节点宽度。
- `Height`: number，单位 vp，根节点高度。
- `Circle`: 百分比字符串，圆角半径占短边比例；`'100%'` 为短边一半半径。
- `Blur`: number，单位 vp；`0` 表示中心不模糊。
- `NeoStrength`: number，无单位折射强度；默认 0.20。
- `ProUI`: boolean，默认 false；本特性固定 false。
- `Vibrate`: boolean，默认 false；本特性固定 false，不申请 `ohos.permission.VIBRATE`。
- 尾随媒体插槽：本特性不使用，避免把导航点击区放进不参与命中测试的媒体层。
- 采样目标：组件自动选择紧邻下层；调用方必须保证透镜之前存在有内容、与透镜重叠的兄弟层，且该层不包含透镜自身。

### CommunityShoppingTabs 契约

- 输入：`cart: CartStore`、`materialStatus: string`、`onSchemeChange(mode: number)`。
- 内部状态：当前 Tab 索引、TabsController、导航宽度。
- 输出：四个业务页面、一个 AppleUI 透镜、一个透明导航点击层；不向业务页面注入 AppleUI 相关状态。
- 约束：透镜在 `Tabs` 之后、点击层之前；只创建一个 AppleUI。

### BottomNavBar 扩展契约

- 现有行为默认不变：白底、1vp 边线、圆角 34、阴影。
- 新增透明模式：不绘制背景、不绘制边线、不绘制阴影，仅保留高度、圆角、布局、图标/文字/角标和点击事件。
- 透明模式只由社区包装组件使用；普通方案保持现有外观。

### CapabilityService 契约

- 返回 `AppleUICapability`；不访问网络，不请求权限。
- 以 `deviceInfo.abiList`、`deviceInfo.sdkApiVersion` 和固定库版本 2.1.0 生成状态文本。
- 不把“ABI/API 满足”表述为“渲染成功”；渲染结果由真机验证和日志决定。

### Architecture & Data Flow

```text
Index
├── mode=0 → PlainShoppingTabs
│            └── Tabs + BottomNavBar（白胶囊，现有）
├── mode=1 → OfficialShoppingTabs
│            └── HdsTabs + systemMaterialEffect（现有）
└── mode=2 → CommunityShoppingTabs
             └── Stack(alignContent=Bottom)
                 ├── Tabs(barHeight=0)          ← 实时内容层 / 采样目标
                 │   ├── RecommendedPage
                 │   ├── CategoryPage
                 │   ├── BagPage
                 │   └── ProfilePage(currentMode=2)
                 ├── Row(padding 16 / bottom 14)
                 │   └── AppleUI(Width=contentWidth-32, Height=68)
                 └── Row(padding 16 / bottom 14)
                     └── BottomNavBar(transparent)
                         ├── 推荐
                         ├── 分类
                         ├── 购物袋 + 真实角标
                         └── 我的
```

**关键不变量**

1. AppleUI 只出现一次，且只在社区模式的底部导航槽位。
2. AppleUI 之前是 `Tabs` 内容层，之后是点击层；玻璃不会采样自己或上方点击层。
3. 玻璃外层和点击层均无白色/不透明底板；商品内容能透到玻璃中心。
4. 四个导航入口的点击、选中态、角标和业务回调与普通/官方共享同一套 `NAV_ITEMS`、`CartStore`。
5. 所有页面底部保留 128vp 留白；玻璃不改变列表末尾可见性。
6. 模块不新增权限；`Vibrate` 不开启，`ProUI` 不开启。

### Verification Strategy

1. `arkts_check` 检查新增/修改的 `.ets` 文件。
2. `devecocli build` 构建 HAP；确认 AppleUI 2.1.0 依赖、arm64 原生库和未新增权限。
3. 真机 Pura X 安装；检查启动、四个导航入口、滚动、搜索、分类、加购、数量、删除。
4. 在社区模式滚动商品，截图验证玻璃背景为实时内容；检查黑块、青/品红自反馈、错位、空层。
5. 在普通/官方/社区间切换至少 3 次，核对购物袋；进入后台再回前台，重进页面，确认单个透镜和状态保持。
6. 采集 `hilog` 中 `MfShop` 与 `AppleUI` 的日志；失败时保留完整错误码和复现条件。
7. README 记录实际库版本、运行环境、最终参数、最小接入代码位置、截图路径、验证结果和调试经过；未运行项明确标注，不写帧率/耗电结论。
