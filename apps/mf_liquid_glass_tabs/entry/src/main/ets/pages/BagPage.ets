import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppIcon } from '../components/AppIcon';
import { CartLine } from '../model/CartLine';
import { CartStore } from '../service/CartStore';
import { formatPrice } from '../utils/PriceUtil';

/**
 * 购物袋：展示本地加入的商品，支持数量增减、删除和金额汇总。
 * 不接支付、订单或登录，空态提供返回推荐页的入口。
 */
@ComponentV2
export struct BagPage {
  @Require @Param cart: CartStore;
  @Event onGoShopping: () => void = () => {};

  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    hilog.info(0x0000, 'MfShop', `🛒 购物袋打开，当前 ${this.cart.count} 件`);
  }

  /**
   * 增加数量并记录。
   */
  private increase(line: CartLine): void {
    this.cart.increase(line.product.id);
    hilog.info(0x0000, 'MfShop', `➕ 购物袋增加: ${line.product.name}，数量=${this.cart.quantityOf(line.product.id)}`);
  }

  /**
   * 减少数量；减到 0 时自动移除。
   */
  private decrease(line: CartLine): void {
    this.cart.decrease(line.product.id);
    hilog.info(0x0000, 'MfShop', `➖ 购物袋减少: ${line.product.name}，数量=${this.cart.quantityOf(line.product.id)}`);
  }

  /**
   * 删除整行。
   */
  private remove(line: CartLine): void {
    this.cart.remove(line.product.id);
    hilog.info(0x0000, 'MfShop', `🗑️ 购物袋移除: ${line.product.name}`);
  }

  @Builder
  emptyState() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        AppIcon({ type: 'bag', color: '#9AA29C', iconSize: 34 })
      }
      .width(66)
      .height(66)
      .borderRadius(33)
      .backgroundColor('#F1F3F1')

      Text('购物袋还是空的')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#252A28')
      Text('去推荐页挑几件日常好物吧')
        .fontSize(12)
        .fontColor('#737B77')
      Button('去逛逛')
        .height(34)
        .padding({ left: 20, right: 20 })
        .fontSize(12)
        .fontColor('#FFFFFF')
        .backgroundColor('#48B378')
        .borderRadius(17)
        .margin({ top: 6 })
        .onClick(() => {
          this.onGoShopping();
        })
    }
    .width('100%')
    .padding({ top: 72, bottom: 72 })
  }

  @Builder
  bagLine(line: CartLine) {
    Row({ space: 12 }) {
      Image(line.product.image)
        .width(76)
        .height(76)
        .objectFit(ImageFit.Cover)
        .borderRadius(12)
        .backgroundColor('#F1F3F1')

      Column({ space: 5 }) {
        Row() {
          Text(line.product.name)
            .layoutWeight(1)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#252A28')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Stack({ alignContent: Alignment.Center }) {
            AppIcon({ type: 'trash', color: '#9AA29C', iconSize: 18 })
          }
          .width(28)
          .height(28)
          .onClick(() => {
            this.remove(line);
          })
        }
        .width('100%')

        Text(line.product.spec)
          .width('100%')
          .fontSize(10)
          .fontColor('#737B77')
          .maxLines(1)

        Row() {
          Text(formatPrice(line.product.price))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#C75B42')
          Blank()
          Row({ space: 8 }) {
            Stack({ alignContent: Alignment.Center }) {
              AppIcon({ type: 'minus', color: '#2F7D53', iconSize: 14 })
            }
            .width(26)
            .height(26)
            .borderRadius(13)
            .backgroundColor('#EDF6F0')
                  .onClick(() => {
              this.decrease(line);
            })

            Text(line.quantity.toString())
              .width(18)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#252A28')
              .textAlign(TextAlign.Center)

            Stack({ alignContent: Alignment.Center }) {
              AppIcon({ type: 'plus', color: '#2F7D53', iconSize: 14 })
            }
            .width(26)
            .height(26)
            .borderRadius(13)
            .backgroundColor('#EDF6F0')
                  .onClick(() => {
              this.increase(line);
            })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: '#0A000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  summary() {
    Column({ space: 8 }) {
      Row() {
        Text(`共 ${this.cart.count} 件`)
          .fontSize(12)
          .fontColor('#737B77')
        Blank()
        Text('合计')
          .fontSize(12)
          .fontColor('#3F3F3F')
        Text(formatPrice(this.cart.total))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#C75B42')
          .margin({ left: 6 })
      }
      .width('100%')
      Text('本地演示购物袋，不接入支付、订单或登录服务。')
        .width('100%')
        .fontSize(10)
        .fontColor('#9AA29C')
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 6 })
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Row() {
          Column({ space: 3 }) {
            Text('购物袋')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#252A28')
            Text('把喜欢的日常小物放在一起')
              .fontSize(12)
              .fontColor('#737B77')
          }
          Blank()
          Text(`${this.cart.count} 件`)
            .fontSize(12)
            .fontColor('#2F7D53')
            .padding({ left: 9, right: 9, top: 4, bottom: 4 })
            .backgroundColor('#EDF6F0')
            .borderRadius(10)
        }
        .width('100%')
        .padding({ top: 8, bottom: 14 })

        if (this.cart.isEmpty) {
          this.emptyState()
        } else {
          Column({ space: 10 }) {
            ForEach(this.cart.lines, (line: CartLine) => {
              this.bagLine(line)
            }, (line: CartLine) => line.product.id)
          }
          .width('100%')

          this.summary()
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
