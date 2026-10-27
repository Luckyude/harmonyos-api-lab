import { hilog } from '@kit.PerformanceAnalysisKit';
import { HdsTabs, HdsTabsController, hdsMaterial } from '@kit.UIDesignKit';
import { NAV_BAR_BOTTOM, NAV_BAR_HEIGHT, NAV_ITEMS } from '../constants/ShopData';
import { BagPage } from '../pages/BagPage';
import { CategoryPage } from '../pages/CategoryPage';
import { ProfilePage } from '../pages/ProfilePage';
import { RecommendedPage } from '../pages/RecommendedPage';
import { CartStore } from '../service/CartStore';
import { AppIcon } from './AppIcon';

/**
 * 官方方案：HdsTabs 悬浮页签 + 系统材质。
 * 业务页面、商品顺序和购物袋状态与普通方案完全共用。
 */
@ComponentV2
export struct OfficialShoppingTabs {
  @Require @Param cart: CartStore;
  @Require @Param materialStatus: string;
  @Event onSchemeChange: (mode: number) => void = (mode: number) => {};

  @Local currentIndex: number = 0;
  private controller: HdsTabsController = new HdsTabsController();

  build() {
    HdsTabs({ controller: this.controller }) {
      TabContent() {
        RecommendedPage({ cart: this.cart })
      }
      .tabBar(this.navBuilder(0))

      TabContent() {
        CategoryPage({ cart: this.cart })
      }
      .tabBar(this.navBuilder(1))

      TabContent() {
        BagPage({
          cart: this.cart,
          onGoShopping: () => {
            this.currentIndex = 0;
            this.controller.changeIndex(0);
            hilog.info(0x0000, 'MfShop', '🧭 官方导航返回推荐');
          }
        })
      }
      .tabBar(this.navBuilder(2))

      TabContent() {
        ProfilePage({
          currentMode: 1,
          materialStatus: this.materialStatus,
          onSchemeChange: (mode: number) => {
            this.onSchemeChange(mode);
          }
        })
      }
      .tabBar(this.navBuilder(3))
    }
    .barOverlap(true)
    .vertical(false)
    .barPosition(BarPosition.End)
    .barHeight(NAV_BAR_HEIGHT)
    .barFloatingStyle({
      barBottomMargin: NAV_BAR_BOTTOM,
      barSideMargin: 16,
      gradientMask: {
        maskColor: '#00F7F8FA',
        maskHeight: 1
      },
      systemMaterialEffect: {
        materialType: hdsMaterial.MaterialType.ADAPTIVE,
        materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
      }
    })
    .onChange((index: number) => {
      this.currentIndex = index;
      hilog.info(0x0000, 'MfShop', `🧭 官方导航切换到 ${NAV_ITEMS[index].label}`);
    })
    .width('100%')
    .height('100%')
  }

  @Builder
  navBuilder(index: number) {
    Column({ space: 2 }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        AppIcon({
          type: NAV_ITEMS[index].icon,
          color: this.currentIndex === index ? '#2F7D53' : '#7C8580',
          iconSize: 32
        })
        if (index === 2 && this.cart.count > 0) {
          Text(this.cart.count > 99 ? '99+' : this.cart.count.toString())
            .fontSize(8)
            .fontColor('#FFFFFF')
            .backgroundColor('#48B378')
            .borderRadius(8)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
            .margin({ top: -2, right: -8 })
        }
      }
      .width(30)
      .height(30)

      Text(NAV_ITEMS[index].label)
        .fontSize(12)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentIndex === index ? '#2F7D53' : '#7C8580')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
