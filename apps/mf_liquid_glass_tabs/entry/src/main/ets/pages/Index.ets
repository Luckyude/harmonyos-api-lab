import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { hdsMaterial } from '@kit.UIDesignKit';
import { CommunityShoppingTabs } from '../components/CommunityShoppingTabs';
import { OfficialShoppingTabs } from '../components/OfficialShoppingTabs';
import { PlainShoppingTabs } from '../components/PlainShoppingTabs';
import { CartStore } from '../service/CartStore';

/**
 * 米饭好物入口：浅色购物应用，默认官方沉浸光感导航。
 * 普通/官方/社区的切换与材质状态全部收进“我的 → 演示设置”。
 */
@Entry
@ComponentV2
struct Index {
  @Local mode: number = 1;
  @Local materialStatus: string = '材质检测中';
  @Local cart: CartStore = new CartStore();
  @Local topInset: number = 0;
  @Local bottomInset: number = 0;

  aboutToAppear(): void {
    const topPx: number = AppStorage.get<number>('topSafePx') ?? 0;
    const bottomPx: number = AppStorage.get<number>('bottomSafePx') ?? 0;
    this.topInset = this.getUIContext().px2vp(topPx);
    this.bottomInset = this.getUIContext().px2vp(bottomPx);
    this.materialStatus = this.queryMaterialStatus();
    hilog.info(0x0000, 'MfShop',
      `🛍️ 米饭好物启动，方案=${this.mode}，安全区 top=${this.topInset}vp bottom=${this.bottomInset}vp`);
  }

  /**
   * 读取官方材质能力，只用于“我的 → 演示设置”和日志，不占业务首页。
   */
  private queryMaterialStatus(): string {
    try {
      const types: hdsMaterial.MaterialType[] = hdsMaterial.getSystemMaterialTypes();
      if (types.length === 0) {
        hilog.info(0x0000, 'MfShop', '🟠 HDS 材质类型为空');
        return '未返回材质类型';
      }
      const names: string[] = types.map((type: hdsMaterial.MaterialType) => this.materialName(type));
      const hasImmersive: boolean = types.includes(hdsMaterial.MaterialType.IMMERSIVE);
      hilog.info(0x0000, 'MfShop', `🟢 HDS 材质类型: ${names.join(' / ')}`);
      return hasImmersive
        ? `IMMERSIVE 可用（${names.join(' / ')}）`
        : `未声明 IMMERSIVE（${names.join(' / ')}）`;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'MfShop', `🔴 HDS 材质查询失败 code=${err.code} message=${err.message}`);
      return `材质查询失败: ${err.code}`;
    }
  }

  /**
   * 材质枚举转可读文本。
   */
  private materialName(type: hdsMaterial.MaterialType): string {
    switch (type) {
      case hdsMaterial.MaterialType.NONE:
        return 'NONE';
      case hdsMaterial.MaterialType.ADAPTIVE:
        return 'ADAPTIVE';
      case hdsMaterial.MaterialType.IMMERSIVE:
        return 'IMMERSIVE';
      default:
        return `${type}`;
    }
  }

  /**
   * 演示设置切换方案：0 普通导航 / 1 官方沉浸光感 / 2 社区液态玻璃。
   * 三套方案共用同一个 CartStore，切换只重建包装组件，不动购物袋数据。
   */
  private changeScheme(mode: number): void {
    if (mode === this.mode || (mode !== 0 && mode !== 1 && mode !== 2)) {
      return;
    }
    const previous: number = this.mode;
    this.mode = mode;
    hilog.info(0x0000, 'MfShop',
      `🎛️ 当前演示方案切换为 ${this.schemeName(mode)}（${previous} → ${mode}），购物袋 ${this.cart.count} 件保持不变`);
  }

  /**
   * 方案编号转可读名称，仅用于日志。
   */
  private schemeName(mode: number): string {
    switch (mode) {
      case 0:
        return '普通导航';
      case 2:
        return '社区液态玻璃';
      default:
        return '官方沉浸光感';
    }
  }

  build() {
    Stack() {
      if (this.mode === 0) {
        PlainShoppingTabs({
          cart: this.cart,
          materialStatus: this.materialStatus,
          onSchemeChange: (mode: number) => {
            this.changeScheme(mode);
          }
        })
      } else if (this.mode === 2) {
        // 条件渲染：离开社区方案时整棵子树销毁，AppleUI 不会继续截帧；
        // 再切回来时才重新创建唯一一个透镜实例。
        CommunityShoppingTabs({
          cart: this.cart,
          materialStatus: this.materialStatus,
          onSchemeChange: (mode: number) => {
            this.changeScheme(mode);
          }
        })
      } else {
        OfficialShoppingTabs({
          cart: this.cart,
          materialStatus: this.materialStatus,
          onSchemeChange: (mode: number) => {
            this.changeScheme(mode);
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.topInset, bottom: this.bottomInset })
    .backgroundColor('#F7F8FA')
  }
}
