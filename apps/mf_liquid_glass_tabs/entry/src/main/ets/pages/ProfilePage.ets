import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppIcon } from '../components/AppIcon';
import { SCHEME_OPTIONS } from '../constants/ShopData';
import { SchemeOption } from '../model/Product';
import { AppleUICapability, CapabilityService } from '../service/CapabilityService';

/**
 * 我的：本地访客信息、关于说明和演示设置。
 * 方案切换与官方材质状态只在这里出现，不占用业务首页。
 */
@ComponentV2
export struct ProfilePage {
  @Require @Param currentMode: number;
  @Require @Param materialStatus: string;
  @Event onSchemeChange: (mode: number) => void = (mode: number) => {};

  @Local panel: number = 0;
  // 社区玻璃能力：ABI / API 决定社区方案是否可选，检查过程本身会打 MfShop 日志
  @Local capability: AppleUICapability = CapabilityService.check();

  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    hilog.info(0x0000, 'MfShop', `👤 我的页打开，当前方案=${this.currentMode}`);
  }

  /**
   * 打开二级说明页并回到顶部。
   */
  private openPanel(panel: number): void {
    this.panel = panel;
    this.scroller.scrollTo({ xOffset: 0, yOffset: 0 });
  }

  /**
   * 当前方案标题，仅用于演示设置展示。
   */
  private currentSchemeTitle(): string {
    const option: SchemeOption | undefined = SCHEME_OPTIONS.find((item: SchemeOption) => item.id === this.currentMode);
    return option !== undefined ? option.title : '未知方案';
  }

  /**
   * 官方材质状态是否明确可用。
   */
  private materialReady(): boolean {
    return this.materialStatus.includes('可用');
  }

  @Builder
  backHeader(title: string) {
    Row({ space: 8 }) {
      Stack({ alignContent: Alignment.Center }) {
        AppIcon({ type: 'chevron', color: '#252A28', iconSize: 22 })
      }
      .width(32)
      .height(32)
      .rotate({ angle: 180 })
      .onClick(() => {
        this.openPanel(0);
      })
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#252A28')
      Blank()
    }
    .width('100%')
    .padding({ top: 8, bottom: 14 })
  }

  @Builder
  mainPanel() {
    Column() {
      Column({ space: 3 }) {
        Text('我的')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#252A28')
        Text('本地演示中的米饭好物')
          .fontSize(12)
          .fontColor('#737B77')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ top: 8, bottom: 14 })

      Row({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          AppIcon({ type: 'profile', color: '#2F7D53', iconSize: 26 })
        }
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor('#EDF6F0')
  
        Column({ space: 4 }) {
          Text('访客')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#252A28')
          Text('本地演示模式 · 购物袋仅保存在本次运行')
            .fontSize(11)
            .fontColor('#737B77')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(18)

      Column({ space: 10 }) {
        Row({ space: 12 }) {
          Stack({ alignContent: Alignment.Center }) {
            AppIcon({ type: 'info', color: '#2F7D53', iconSize: 20 })
          }
          .width(34)
          .height(34)
          .borderRadius(17)
          .backgroundColor('#EDF6F0')
    
          Column({ space: 2 }) {
            Text('关于米饭好物')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#252A28')
            Text('演示数据与图片来源')
              .fontSize(10)
              .fontColor('#737B77')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          AppIcon({ type: 'chevron', color: '#A6AEA8', iconSize: 18 })
        }
        .width('100%')
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
        .onClick(() => {
          this.openPanel(1);
        })

        Divider()
          .width('100%')
          .strokeWidth(0.5)
          .color('#E8EDE9')

        Row({ space: 12 }) {
          Stack({ alignContent: Alignment.Center }) {
            AppIcon({ type: 'settings', color: '#2F7D53', iconSize: 20 })
          }
          .width(34)
          .height(34)
          .borderRadius(17)
          .backgroundColor('#EDF6F0')
    
          Column({ space: 2 }) {
            Text('演示设置')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#252A28')
            Text('普通 / 官方 / 社区')
              .fontSize(10)
              .fontColor('#737B77')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          AppIcon({ type: 'chevron', color: '#A6AEA8', iconSize: 18 })
        }
        .width('100%')
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
        .onClick(() => {
          this.openPanel(2);
        })
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
      .margin({ top: 14 })
    }
    .width('100%')
  }

  @Builder
  aboutPanel() {
    Column() {
      this.backHeader('关于米饭好物')

      Column({ space: 14 }) {
        Text('米饭好物是一个本地购物界面示例，关注日常用品与生活小物。')
          .width('100%')
          .fontSize(13)
          .lineHeight(21)
          .fontColor('#3F3F3F')

        Column({ space: 6 }) {
          Text('商品与价格')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#252A28')
          Text('8 件商品、价格、分类和购物袋均为本地演示数据，不连接真实商品库、登录、支付或订单服务。')
            .width('100%')
            .fontSize(12)
            .lineHeight(19)
            .fontColor('#737B77')
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(14)

        Column({ space: 6 }) {
          Text('商品图片')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#252A28')
          Text('由阿里云百炼 qwen-image-3.0 生成，保存为工程本地资源，离线可显示；仅用于本项目演示。')
            .width('100%')
            .fontSize(12)
            .lineHeight(19)
            .fontColor('#737B77')
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(14)

        Column({ space: 6 }) {
          Text('导航能力')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#252A28')
          Text('已接入普通悬浮导航、官方 HDS 沉浸光感，以及 com.hm.appleui.hw 2.1.0 社区液态玻璃。社区方案只使用一个 AppleUI 透镜作为底部导航胶囊的材质层，采样紧邻下层的实时商品内容，商品列表本身不做玻璃化；设备 ABI 不含 arm64-v8a 或系统 API 低于 20 时，社区方案不可选并显示原因，实际渲染效果以真机运行结果为准。')
            .width('100%')
            .fontSize(12)
            .lineHeight(19)
            .fontColor('#737B77')
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(14)
      }
      .width('100%')
    }
    .width('100%')
  }

  /**
   * 方案是否可选：静态开关 + 社区方案的 ABI/API 实测结论。
   */
  private optionEnabled(option: SchemeOption): boolean {
    if (!option.enabled) {
      return false;
    }
    if (option.id === 2) {
      return this.capability.available;
    }
    return true;
  }

  @Builder
  schemeRow(option: SchemeOption) {
    Row({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        if (this.currentMode === option.id) {
          AppIcon({ type: 'check', color: '#FFFFFF', iconSize: 14 })
        }
      }
      .width(22)
      .height(22)
      .borderRadius(11)
      .backgroundColor(this.currentMode === option.id ? '#48B378' : '#F1F3F1')
      .border({
        width: this.currentMode === option.id ? 0 : 1,
        color: '#DDE4DF'
      })

      Column({ space: 3 }) {
        Row({ space: 6 }) {
          Text(option.title)
            .fontSize(14)
            .fontWeight(this.currentMode === option.id ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.optionEnabled(option) ? '#252A28' : '#A6AEA8')
          if (!this.optionEnabled(option)) {
            Text(option.id === 2 ? '不可用' : '未接入')
              .fontSize(9)
              .fontColor('#9AA29C')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#F1F3F1')
              .borderRadius(7)
          }
        }
        Text(option.description)
          .width('100%')
          .fontSize(10)
          .fontColor(this.optionEnabled(option) ? '#737B77' : '#B0B7B2')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.currentMode === option.id ? '#F3FAF5' : '#FFFFFF')
    .borderRadius(14)
    .border({
      width: this.currentMode === option.id ? 1 : 0,
      color: '#48B378'
    })
    .opacity(this.optionEnabled(option) ? 1 : 0.72)
    .onClick(() => {
      if (this.optionEnabled(option) && option.id !== this.currentMode) {
        hilog.info(0x0000, 'MfShop', `🎛️ 切换演示方案: ${option.title}`);
        this.onSchemeChange(option.id);
      }
    })
  }

  @Builder
  settingsPanel() {
    Column() {
      this.backHeader('演示设置')

      Text(`当前方案：${this.currentSchemeTitle()}`)
        .width('100%')
        .fontSize(12)
        .fontColor('#737B77')
        .margin({ bottom: 4 })

      Text('切换后会回到推荐页，方便在相同商品和滚动条件下对照。')
        .width('100%')
        .fontSize(11)
        .lineHeight(17)
        .fontColor('#9AA29C')
        .margin({ bottom: 12 })

      Column({ space: 8 }) {
        ForEach(SCHEME_OPTIONS, (option: SchemeOption) => {
          this.schemeRow(option)
        }, (option: SchemeOption) => option.id.toString())

        Row() {
          Text('官方材质状态')
            .fontSize(11)
            .fontColor('#737B77')
          Blank()
          Text(this.materialStatus)
            .fontSize(10)
            .fontColor(this.materialReady() ? '#2F7D53' : '#C75B42')
            .maxLines(2)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)

        Row() {
          Text('社区玻璃能力')
            .fontSize(11)
            .fontColor('#737B77')
          Blank()
          Text(this.capability.statusText)
            .fontSize(10)
            .fontColor(this.capability.available ? '#2F7D53' : '#C75B42')
            .maxLines(2)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)

        if (!this.capability.available) {
          Row({ space: 6 }) {
            Text('!')
              .width(16)
              .height(16)
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor('#7A4A12')
              .textAlign(TextAlign.Center)
              .backgroundColor('#F6E7CF')
              .borderRadius(8)
            Text(`社区液态玻璃不可用：${this.capability.reasonText}。普通与官方方案仍然可用，不显示降级玻璃效果。`)
              .layoutWeight(1)
              .fontSize(10)
              .lineHeight(15)
              .fontColor('#A56B2A')
          }
          .width('100%')
          .padding(10)
          .backgroundColor('#FFF8EC')
          .borderRadius(10)
        }

        if (!this.materialReady()) {
          Row({ space: 6 }) {
            Text('!')
              .width(16)
              .height(16)
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor('#7A4A12')
              .textAlign(TextAlign.Center)
              .backgroundColor('#F6E7CF')
              .borderRadius(8)
            Text('当前设备未返回可用的 IMMERSIVE 材质，官方导航会保留组件默认样式，不把降级结果当作沉浸光感成功。')
              .layoutWeight(1)
              .fontSize(10)
              .lineHeight(15)
              .fontColor('#A56B2A')
          }
          .width('100%')
          .padding(10)
          .backgroundColor('#FFF8EC')
          .borderRadius(10)
        }
      }
      .width('100%')
    }
    .width('100%')
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        if (this.panel === 0) {
          this.mainPanel()
        } else if (this.panel === 1) {
          this.aboutPanel()
        } else {
          this.settingsPanel()
        }

        Blank()
          .height(128)
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor('#F7F8FA')
  }
}
