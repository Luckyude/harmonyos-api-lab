import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppIcon } from '../components/AppIcon';
import { ProductGrid } from '../components/ProductGrid';
import { CATEGORY_ITEMS, categoryCount, productsByCategory } from '../constants/ShopData';
import { CategoryItem, Product } from '../model/Product';
import { CartStore } from '../service/CartStore';

/**
 * 分类页：四个生活场景入口 + 当前分类商品，复用推荐页的商品卡。
 */
@ComponentV2
export struct CategoryPage {
  @Require @Param cart: CartStore;

  @Local selectedCategory: string = '居家';

  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    hilog.info(0x0000, 'MfShop', '🗂️ 分类页打开');
  }

  /**
   * 切换分类并记录当前分类。
   */
  private selectCategory(category: string): void {
    this.selectedCategory = category;
    hilog.info(0x0000, 'MfShop', `🏷️ 分类页切换: ${category}`);
  }

  /**
   * 加入购物袋，和推荐页共用同一个 CartStore。
   */
  private addToBag(product: Product): void {
    this.cart.add(product);
    try {
      this.getUIContext().getPromptAction().showToast({
        message: `已加入购物袋 · ${product.name}`,
        duration: 1200
      });
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'MfShop', `🔴 购物袋提示失败 code=${err.code} message=${err.message}`);
    }
    hilog.info(0x0000, 'MfShop', `🛒 分类页加入: ${product.name}，总件数=${this.cart.count}`);
  }

  @Builder
  categoryGrid() {
    Grid() {
      ForEach(CATEGORY_ITEMS, (item: CategoryItem) => {
        GridItem() {
          Column({ space: 7 }) {
            Row() {
              Stack({ alignContent: Alignment.Center }) {
                AppIcon({
                  type: item.icon,
                  color: this.selectedCategory === item.key ? '#2F7D53' : '#5F6B64',
                  iconSize: 40
                })
              }
              .width(54)
              .height(54)
              .borderRadius(27)
              .backgroundColor(this.selectedCategory === item.key ? '#FFFFFF' : '#F5F7F5')
                      Blank()
              Text(`${categoryCount(item.key)} 件`)
                .fontSize(10)
                .fontColor('#737B77')
            }
            .width('100%')

            Text(item.label)
              .width('100%')
              .fontSize(14)
              .fontWeight(this.selectedCategory === item.key ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(this.selectedCategory === item.key ? '#2F7D53' : '#252A28')
          }
          .width('100%')
          .height(100)
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .backgroundColor(this.selectedCategory === item.key ? '#EDF6F0' : '#FFFFFF')
          .borderRadius(14)
          .border({
            width: this.selectedCategory === item.key ? 1 : 0,
            color: '#48B378'
          })
          .onClick(() => {
            this.selectCategory(item.key);
          })
        }
      }, (item: CategoryItem) => item.key)
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(10)
    .rowsGap(10)
    .height(210)
    .width('100%')
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Column({ space: 3 }) {
          Text('分类')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#252A28')
          Text('按生活场景逛一逛')
            .fontSize(12)
            .fontColor('#737B77')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 8, bottom: 14 })

        this.categoryGrid()

        Row() {
          Text(`${this.selectedCategory}好物`)
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor('#252A28')
          Blank()
          Text(`${productsByCategory(this.selectedCategory).length} 件`)
            .fontSize(11)
            .fontColor('#737B77')
        }
        .width('100%')
        .margin({ top: 20, bottom: 12 })

        ProductGrid({
          products: productsByCategory(this.selectedCategory),
          onAdd: (product: Product) => {
            this.addToBag(product);
          }
        })

        Blank()
          .height(128)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor('#F7F8FA')
  }
}
