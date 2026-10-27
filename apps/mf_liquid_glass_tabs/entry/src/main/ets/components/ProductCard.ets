import { Product } from '../model/Product';
import { formatPrice } from '../utils/PriceUtil';

/**
 * 双列商品卡：白底、商品图、两行名称、规格、价格和加入购物袋入口。
 * 卡片本身不嵌套多层边框，保持实体白底的清爽感。
 */
@ComponentV2
export struct ProductCard {
  @Require @Param product: Product;
  @Event onAdd: (product: Product) => void = (product: Product) => {};

  build() {
    Column() {
      Image(this.product.image)
        .width('100%')
        .aspectRatio(1.32)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#F1F3F1')

      Column({ space: 3 }) {
        Text(this.product.name)
          .width('100%')
          .height(38)
          .fontSize(14)
          .lineHeight(19)
          .fontWeight(FontWeight.Medium)
          .fontColor('#252A28')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.product.spec)
          .width('100%')
          .fontSize(11)
          .fontColor('#737B77')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(formatPrice(this.product.price))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#C75B42')
          Blank()
          Button('加入')
            .type(ButtonType.Capsule)
            .width(50)
            .height(26)
            .padding(0)
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor('#48B378')
            .onClick(() => {
              this.onAdd(this.product);
            })
        }
        .width('100%')
        .margin({ top: 0 })
      }
      .width('100%')
      .padding({ left: 9, right: 9, top: 8, bottom: 8 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .clip(true)
    .shadow({
      radius: 10,
      color: '#0D000000',
      offsetX: 0,
      offsetY: 3
    })
  }
}
