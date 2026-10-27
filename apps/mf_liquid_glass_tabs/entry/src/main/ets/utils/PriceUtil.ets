/**
 * 演示价格统一显示为整数元，避免购物界面出现多余小数。
 */
export function formatPrice(value: number): string {
  return `¥${value.toFixed(0)}`;
}
