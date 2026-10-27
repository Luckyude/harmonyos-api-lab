import { CartLine } from '../model/CartLine';
import { Product } from '../model/Product';

/**
 * 本地购物袋状态：只保存在当前运行内存中，不接登录、支付或订单。
 */
@ObservedV2
export class CartStore {
  @Trace lines: CartLine[] = [];

  /**
   * 加入商品；已存在时数量加一。
   */
  add(product: Product): void {
    const index: number = this.lines.findIndex((line: CartLine) => line.product.id === product.id);
    if (index >= 0) {
      this.lines[index].quantity += 1;
      return;
    }
    this.lines.push(new CartLine(product, 1));
  }

  /**
   * 增加指定商品数量。
   */
  increase(productId: string): void {
    const index: number = this.lines.findIndex((line: CartLine) => line.product.id === productId);
    if (index >= 0) {
      this.lines[index].quantity += 1;
    }
  }

  /**
   * 减少指定商品数量；减到 0 时从购物袋移除。
   */
  decrease(productId: string): void {
    const index: number = this.lines.findIndex((line: CartLine) => line.product.id === productId);
    if (index < 0) {
      return;
    }
    if (this.lines[index].quantity <= 1) {
      this.remove(productId);
      return;
    }
    this.lines[index].quantity -= 1;
  }

  /**
   * 移除指定商品。
   */
  remove(productId: string): void {
    this.lines = this.lines.filter((line: CartLine) => line.product.id !== productId);
  }

  /**
   * 清空购物袋。
   */
  clear(): void {
    this.lines = [];
  }

  /**
   * 指定商品当前数量。
   */
  quantityOf(productId: string): number {
    const index: number = this.lines.findIndex((line: CartLine) => line.product.id === productId);
    return index >= 0 ? this.lines[index].quantity : 0;
  }

  /**
   * 购物袋内商品总件数，用于底部购物袋角标。
   */
  get count(): number {
    let total: number = 0;
    for (const line of this.lines) {
      total += line.quantity;
    }
    return total;
  }

  /**
   * 购物袋合计金额。
   */
  get total(): number {
    let total: number = 0;
    for (const line of this.lines) {
      total += line.subtotal;
    }
    return total;
  }

  /**
   * 购物袋是否为空。
   */
  get isEmpty(): boolean {
    return this.lines.length === 0;
  }
}
