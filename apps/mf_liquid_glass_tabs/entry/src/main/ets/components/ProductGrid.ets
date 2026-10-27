import { Product } from '../model/Product';
import { ProductCard } from './ProductCard';

/**
 * 双列商品网格：用成对 Row 排布，避免 Grid 在 Scroll 中需要固定高度。
 */
@ComponentV2
export struct ProductGrid {
  @Require @Param products: Product[];
  @Event onAdd: (product: Product) => void = (product: Product) => {};

  /**
   * 计算行数，最后一行不足两件时用 Blank 补齐。
   */
  private rowIndexes(): number[] {
    const rows: number[] = [];
    const count: number = Math.ceil(this.products.length / 2);
    for (let index: number = 0; index < count; index += 1) {
      rows.push(index);
    }
    return rows;
  }

  /**
   * 安全读取指定位置的商品。
   */
  private productAt(index: number): Product | undefined {
    return index < this.products.length ? this.products[index] : undefined;
  }

  build() {
    Column({ space: 12 }) {
      ForEach(this.rowIndexes(), (rowIndex: number) => {
        Row({ space: 12 }) {
          if (this.productAt(rowIndex * 2) !== undefined) {
            Column() {
              ProductCard({
                product: this.productAt(rowIndex * 2) as Product,
                onAdd: (product: Product) => {
                  this.onAdd(product);
                }
              })
            }
            .layoutWeight(1)
          }
          if (this.productAt(rowIndex * 2 + 1) !== undefined) {
            Column() {
              ProductCard({
                product: this.productAt(rowIndex * 2 + 1) as Product,
                onAdd: (product: Product) => {
                  this.onAdd(product);
                }
              })
            }
            .layoutWeight(1)
          } else {
            Blank()
              .layoutWeight(1)
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }, (rowIndex: number) => rowIndex.toString())
    }
    .width('100%')
  }
}
