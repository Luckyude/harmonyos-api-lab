import { hilog } from '@kit.PerformanceAnalysisKit';
import { NAV_BAR_BOTTOM, NAV_ITEMS } from '../constants/ShopData';
import { BagPage } from '../pages/BagPage';
import { CategoryPage } from '../pages/CategoryPage';
import { ProfilePage } from '../pages/ProfilePage';
import { RecommendedPage } from '../pages/RecommendedPage';
import { CartStore } from '../service/CartStore';
import { BottomNavBar } from './BottomNavBar';

/**
 * 普通方案：Tabs 负责业务页面，白色悬浮导航由 BottomNavBar 自绘。
 */
@ComponentV2
export struct PlainShoppingTabs {
  @Require @Param cart: CartStore;
  @Require @Param materialStatus: string;
  @Event onSchemeChange: (mode: number) => void = (mode: number) => {};

  @Local currentIndex: number = 0;
  private controller: TabsController = new TabsController();

  /**
   * 统一处理底部导航点击。
   */
  private selectTab(index: number): void {
    this.currentIndex = index;
    this.controller.changeIndex(index);
    hilog.info(0x0000, 'MfShop', `🧭 普通导航切换到 ${NAV_ITEMS[index].label}`);
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
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
            currentMode: 0,
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
        hilog.info(0x0000, 'MfShop', `🧭 普通导航滑动到 ${NAV_ITEMS[index].label}`);
      })
      .width('100%')
      .height('100%')

      Row() {
        BottomNavBar({
          selectedIndex: this.currentIndex,
          cartCount: this.cart.count,
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
  }
}
