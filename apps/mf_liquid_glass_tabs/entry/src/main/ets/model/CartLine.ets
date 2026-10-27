import { Product } from './Product';

/**
 * 购物袋中的一行：数量变化需要被 V2 状态观察到，因此单独标记 @Trace。
 */
@ObservedV2
export class CartLine {
  product: Product;
  @Trace quantity: number;

  constructor(product: Product, quantity: number) {
    this.product = product;
    this.quantity = quantity;
  }

  /**
   * 当前行小计。
   */
  get subtotal(): number {
    return this.product.price * this.quantity;
  }
}
