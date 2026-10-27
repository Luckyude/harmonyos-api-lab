import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppIcon } from '../components/AppIcon';
import { ProductGrid } from '../components/ProductGrid';
import { CATEGORY_ITEMS, PRODUCTS } from '../constants/ShopData';
import { CategoryItem, Product } from '../model/Product';
import { CartStore } from '../service/CartStore';

/**
 * 推荐页：品牌、搜索、主题推荐、分类筛选和双列商品列表。
 * 页面只保留业务内容，方案切换和材质诊断都移到“我的 → 演示设置”。
 */
@ComponentV2
export struct RecommendedPage {
  @Require @Param cart: CartStore;

  @Local query: string = '';
  @Local selectedCategory: string = '全部';

  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    hilog.info(0x0000, 'MfShop', '🛍️ 推荐页打开');
  }

  /**
   * 按关键词与分类同时过滤，保持本地搜索有真实行为。
   */
  private visibleProducts(): Product[] {
    const keyword: string = this.query.trim();
    return PRODUCTS.filter((product: Product) => {
      const categoryMatch: boolean = this.selectedCategory === '全部' || product.category === this.selectedCategory;
      const queryMatch: boolean = keyword.length === 0
        || product.name.includes(keyword)
        || product.spec.includes(keyword)
        || product.category.includes(keyword);
      return categoryMatch && queryMatch;
    });
  }

  /**
   * 切换分类；再次点击当前分类时恢复全部商品。
   */
  private toggleCategory(category: string): void {
    this.selectedCategory = this.selectedCategory === category ? '全部' : category;
    hilog.info(0x0000, 'MfShop', `🏷️ 推荐页分类: ${this.selectedCategory}`);
  }

  /**
   * 清空搜索与分类筛选。
   */
  private clearFilter(): void {
    this.query = '';
    this.selectedCategory = '全部';
    hilog.info(0x0000, 'MfShop', '🧹 推荐页清除搜索与分类筛选');
  }

  /**
   * 加入购物袋并给出短暂反馈。
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
    hilog.info(0x0000, 'MfShop', `🛒 加入购物袋: ${product.name}，总件数=${this.cart.count}`);
  }

  @Builder
  brandHeader() {
    Row() {
      Column({ space: 3 }) {
        Text('米饭好物')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#252A28')
        Text('把日常过得舒服一点')
          .fontSize(12)
          .fontColor('#737B77')
      }
      Blank()
      Text('生活选物')
        .fontSize(10)
        .fontColor('#2F7D53')
        .padding({ left: 9, right: 9, top: 4, bottom: 4 })
        .backgroundColor('#EDF6F0')
        .borderRadius(10)
    }
    .width('100%')
    .padding({ top: 4, bottom: 8 })
  }

  @Builder
  searchBar() {
    Row({ space: 8 }) {
      AppIcon({ type: 'search', color: '#7C8580', iconSize: 20 })
      TextInput({
        text: this.query,
        placeholder: '搜索你想要的生活好物'
      })
        .layoutWeight(1)
        .height(44)
        .padding(0)
        .backgroundColor(Color.Transparent)
        .fontSize(13)
        .fontColor('#252A28')
        .placeholderColor('#9AA29C')
        .caretColor('#48B378')
        .onChange((value: string) => {
          this.query = value;
        })
        .onSubmit((enterKey: EnterKeyType) => {
          hilog.info(0x0000, 'MfShop',
            `🔎 推荐页搜索: ${this.query}，结果=${this.visibleProducts().length} 件`);
        })
      if (this.query.length > 0) {
        Stack({ alignContent: Alignment.Center }) {
          AppIcon({ type: 'close', color: '#7C8580', iconSize: 18 })
        }
        .width(28)
        .height(28)
        .onClick(() => {
          this.query = '';
        })
      }
    }
    .width('100%')
    .height(44)
    .padding({ left: 14, right: 10 })
    .backgroundColor('#FFFFFF')
    .border({
      width: 1,
      color: '#E8EDE9'
    })
    .borderRadius(16)
  }

  @Builder
  themeBanner() {
    Stack({ alignContent: Alignment.Start }) {
      Image($r('app.media.product_banner'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 90,
          colors: [
            ['#F2F7F8FA', 0.0],
            ['#00F7F8FA', 0.78]
          ]
        })
      Column({ space: 4 }) {
        Text('给日常一点新鲜感')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#252A28')
        Text('好用的小物，也可以很好看')
          .fontSize(12)
          .fontColor('#3F3F3F')
      }
      .padding({ left: 18, right: 120 })
    }
    .width('100%')
    .height(78)
    .borderRadius(18)
    .clip(true)
    .margin({ top: 12 })
  }

  @Builder
  categoryRow() {
    Row({ space: 6 }) {
      ForEach(CATEGORY_ITEMS, (item: CategoryItem) => {
        Row({ space: 6 }) {
          AppIcon({
            type: item.icon,
            color: this.selectedCategory === item.key ? '#2F7D53' : '#5F6B64',
            iconSize: 36
          })
          Text(item.label)
            .fontSize(13)
            .fontWeight(this.selectedCategory === item.key ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.selectedCategory === item.key ? '#2F7D53' : '#4F5853')
        }
        .layoutWeight(1)
        .height(68)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.selectedCategory === item.key ? '#EDF6F0' : '#F5F7F5')
        .borderRadius(12)
        .onClick(() => {
          this.toggleCategory(item.key);
        })
      }, (item: CategoryItem) => item.key)
    }
    .width('100%')
    .padding(3)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 10 })
  }

  @Builder
  emptyState() {
    Column({ space: 8 }) {
      Stack({ alignContent: Alignment.Center }) {
        AppIcon({ type: 'search', color: '#A6AEA8', iconSize: 28 })
      }
      .width(52)
      .height(52)
      .borderRadius(26)
      .backgroundColor('#F1F3F1')

      Text('没有找到相关商品')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#252A28')
      Text('换个关键词，或清空筛选后再看看')
        .fontSize(12)
        .fontColor('#737B77')
      Button('清空搜索')
        .height(32)
        .padding({ left: 16, right: 16 })
        .fontSize(12)
        .fontColor('#2F7D53')
        .backgroundColor('#EDF6F0')
        .borderRadius(16)
        .margin({ top: 4 })
        .onClick(() => {
          this.clearFilter();
        })
    }
    .width('100%')
    .padding({ top: 36, bottom: 36 })
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        this.brandHeader()
        this.searchBar()
        this.themeBanner()
        this.categoryRow()

        if (this.selectedCategory !== '全部') {
          Row({ space: 6 }) {
            Text(`当前分类：${this.selectedCategory}`)
              .fontSize(11)
              .fontColor('#2F7D53')
              .padding({ left: 9, right: 9, top: 4, bottom: 4 })
              .backgroundColor('#EDF6F0')
              .borderRadius(9)
            Blank()
            Text('清除')
              .fontSize(11)
              .fontColor('#737B77')
              .onClick(() => {
                this.selectedCategory = '全部';
              })
          }
          .width('100%')
          .margin({ top: 10 })
        }

        Row() {
          Text(this.selectedCategory === '全部' ? '今日好物' : `${this.selectedCategory}好物`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#252A28')
          Blank()
          Text(`${this.visibleProducts().length} 件`)
            .fontSize(11)
            .fontColor('#737B77')
        }
        .width('100%')
        .margin({ top: 14, bottom: 2 })

        if (this.visibleProducts().length === 0) {
          this.emptyState()
        } else {
          ProductGrid({
            products: this.visibleProducts(),
            onAdd: (product: Product) => {
              this.addToBag(product);
            }
          })
        }

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
