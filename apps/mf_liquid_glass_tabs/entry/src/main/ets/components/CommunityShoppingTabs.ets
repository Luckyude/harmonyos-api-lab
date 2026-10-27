import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppleUI } from 'com.hm.appleui.hw';
import { NAV_BAR_BOTTOM, NAV_BAR_HEIGHT, NAV_BAR_WIDTH, NAV_ITEMS } from '../constants/ShopData';
import { BagPage } from '../pages/BagPage';
import { CategoryPage } from '../pages/CategoryPage';
import { ProfilePage } from '../pages/ProfilePage';
import { RecommendedPage } from '../pages/RecommendedPage';
import { CartStore } from '../service/CartStore';
import { BottomNavBar } from './BottomNavBar';

/**
 * 社区方案：com.hm.appleui.hw 2.1.0 单透镜液态玻璃底部导航。
 *
 * 三层结构（自下而上，全部由 Stack 底部对齐叠放）：
 *   1. Tabs：四个实时业务页面，同时是 AppleUI 的紧邻下层采样目标；
 *   2. 一个 AppleUI 透镜：只占底部导航胶囊槽位，不承载商品列表、不承担点击；
 *   3. 透明 BottomNavBar：独立点击层，导航事件由它处理，玻璃不参与命中测试。
 *
 * 采样规则（2.1.0 实测语义）：AppleUI 自动取「本层之前、与透镜可见区域重叠的紧邻兄弟层」。
 * 因此 Tabs 必须排在透镜之前，点击层必须排在透镜之后；玻璃外层与点击层都不能设不透明底板，
 * 否则透镜会采到白底/空层，出现黑块或错误背景。
 */
@ComponentV2
export struct CommunityShoppingTabs {
  @Require @Param cart: CartStore;
  @Require @Param materialStatus: string;
  @Event onSchemeChange: (mode: number) => void = (mode: number) => {};

  @Local currentIndex: number = 0;
  /** 透镜宽度（vp）与官方 HdsTabs 页签一致，不再铺满整屏 */
  @Local lensWidth: number = NAV_BAR_WIDTH;
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    // 先按官方页签宽度初始化，容器真实宽度随后由 onAreaChange 校正。
    this.lensWidth = NAV_BAR_WIDTH;
    hilog.info(0x0000, 'MfShop', `🫧 社区液态玻璃导航已创建：单透镜，宽度=${this.lensWidth}vp`);
  }

  aboutToDisappear(): void {
    // 条件渲染会销毁整个社区包装组件，AppleUI 随之释放 native 渲染线程与 GL 资源；
    // 重新进入社区方案时会重新创建一个透镜，不会残留旧实例继续截帧。
    hilog.info(0x0000, 'MfShop', '🧹 社区液态玻璃导航已销毁：AppleUI 随组件释放，购物袋状态保留');
  }

  /**
   * 统一处理底部导航点击，与普通方案共用同一套选中态逻辑。
   */
  private selectTab(index: number): void {
    this.currentIndex = index;
    this.controller.changeIndex(index);
    hilog.info(0x0000, 'MfShop', `🧭 社区导航切换到 ${NAV_ITEMS[index].label}`);
  }

  /**
   * Area 的宽度可能是 vp 数字，也可能是带单位的字符串，这里统一转成 vp 数字。
   */
  private areaWidthVp(value: Length): number {
    if (typeof value === 'number') {
      return value;
    }
    if (typeof value === 'string') {
      const parsed: number = parseFloat(value);
      return Number.isNaN(parsed) ? 0 : parsed;
    }
    return 0;
  }

  /**
   * 按容器实际宽度重算透镜宽度，始终不超过官方页签宽度；
   * 变化小于 0.5vp 时不触发更新，避免重复布局。
   */
  private updateLensWidth(containerWidth: Length): void {
    const nextWidth: number = Math.min(NAV_BAR_WIDTH, this.areaWidthVp(containerWidth) - 32);
    if (nextWidth > 0 && Math.abs(nextWidth - this.lensWidth) > 0.5) {
      this.lensWidth = nextWidth;
      hilog.info(0x0000, 'MfShop', `📐 社区导航透镜宽度更新为 ${nextWidth}vp`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 第一层：实时业务内容。透镜之前必须有这一层，AppleUI 才会采样到真实商品。
      Tabs({
        barPosition: BarPosition.End,
        index: this.currentIndex,
        controller: this.controller
      }) {
        TabContent() {
          RecommendedPage({ cart: this.cart })
        }

        TabContent() {
          CategoryPage({ cart: this.cart })
        }

        TabContent() {
          BagPage({
            cart: this.cart,
            onGoShopping: () => {
              this.selectTab(0);
            }
          })
        }

        TabContent() {
          ProfilePage({
            currentMode: 2,
            materialStatus: this.materialStatus,
            onSchemeChange: (mode: number) => {
              this.onSchemeChange(mode);
            }
          })
        }
      }
      .barHeight(0)
      .barBackgroundColor(Color.Transparent)
      .barBackgroundBlurStyle(BlurStyle.NONE)
      .onChange((index: number) => {
        this.currentIndex = index;
        hilog.info(0x0000, 'MfShop', `🧭 社区导航滑动到 ${NAV_ITEMS[index].label}`);
      })
      .width('100%')
      .height('100%')

      // 第二层：单个 AppleUI 透镜，只覆盖底部导航胶囊的尺寸槽位。
      // 本层只做视觉，不挂手势、不处理点击；hitTestBehavior 设为 Transparent，
      // 保证即使布局留白变化也不会挡住下方商品列表的滑动。
      Row() {
        AppleUI({
          Width: this.lensWidth,
          Height: NAV_BAR_HEIGHT,
          Circle: '100%',
          Blur: 0,
          NeoStrength: 0.22,
          ProUI: false,
          Vibrate: false
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: NAV_BAR_BOTTOM })
      .hitTestBehavior(HitTestMode.Transparent)

      // 第三层：透明导航点击层，位于透镜之上，导航事件不会被玻璃吞掉。
      Row() {
        BottomNavBar({
          selectedIndex: this.currentIndex,
          cartCount: this.cart.count,
          glassSurface: true,
          onSelect: (index: number) => {
            this.selectTab(index);
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: NAV_BAR_BOTTOM })
    }
    .width('100%')
    .height('100%')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.updateLensWidth(newValue.width);
    })
  }
}
