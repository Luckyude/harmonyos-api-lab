import { NAV_BAR_HEIGHT, NAV_BAR_SIDE_PADDING, NAV_BAR_WIDTH, NAV_ITEMS, NavItem } from '../constants/ShopData';
import { AppIcon } from './AppIcon';

/**
 * 底部导航胶囊：普通方案用白色实体外观，社区方案复用同一套图标/文字/角标/点击。
 * 社区方案的材质由下层 AppleUI 透镜负责，因此新增 glassSurface 透明模式：
 * 不画白底、不画边线，避免透镜采样到白色底板；只保留极轻投影，
 * 让纯白页面也能看出胶囊边界。
 */
@ComponentV2
export struct BottomNavBar {
  @Param selectedIndex: number = 0;
  @Param cartCount: number = 0;
  /** true = 只保留布局与点击，材质交给下层玻璃；默认 false 时外观与改造前完全一致 */
  @Param glassSurface: boolean = false;
  @Event onSelect: (index: number) => void = (index: number) => {};

  /**
   * 图标与文字颜色。
   * 玻璃模式下未选中项用更深的灰绿，保证在浅色商品图上仍然清晰；
   * 普通模式沿用原来的 #7C8580，不改动既有视觉。
   */
  private navColor(index: number): string {
    if (this.selectedIndex === index) {
      return '#2F7D53';
    }
    return this.glassSurface ? '#45514A' : '#7C8580';
  }

  /**
   * 胶囊阴影：透明模式下不绘制阴影，避免在真实内容上留下灰色投影。
   */
  private navShadow(): ShadowOptions {
    if (this.glassSurface) {
      // 白底页面没有可折射的商品内容，透明透镜只剩薄边；
      // 用极轻的投影勾出胶囊，保证分类/购物袋/我的页面也能看出导航范围。
      return { radius: 18, color: '#0D000000', offsetX: 0, offsetY: 6 };
    }
    return { radius: 22, color: '#16000000', offsetX: 0, offsetY: 8 };
  }

  build() {
    Row() {
      ForEach(NAV_ITEMS, (item: NavItem, index: number) => {
        Column({ space: 2 }) {
          Stack({ alignContent: Alignment.TopEnd }) {
            AppIcon({
              type: item.icon,
              color: this.navColor(index),
              iconSize: 32
            })
            if (index === 2 && this.cartCount > 0) {
              Text(this.cartCount > 99 ? '99+' : this.cartCount.toString())
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

          Text(item.label)
            .fontSize(12)
            .fontWeight(this.selectedIndex === index ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.navColor(index))
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.onSelect(index);
        })
      }, (item: NavItem) => item.label)
    }
    .width(NAV_BAR_WIDTH)
    .height(NAV_BAR_HEIGHT)
    .padding({ left: NAV_BAR_SIDE_PADDING, right: NAV_BAR_SIDE_PADDING })
    .backgroundColor(this.glassSurface ? Color.Transparent : '#FFFFFF')
    .border({
      width: this.glassSurface ? 0 : 1,
      color: this.glassSurface ? Color.Transparent : '#E8EDE9'
    })
    .borderRadius(34)
    .shadow(this.navShadow())
  }
}
