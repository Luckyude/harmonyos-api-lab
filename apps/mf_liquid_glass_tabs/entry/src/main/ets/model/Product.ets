/**
 * 本地演示商品模型：图片、名称、规格、价格和分类都来自本地数据。
 */
export interface Product {
  id: string;
  name: string;
  spec: string;
  price: number;
  category: string;
  image: Resource;
}

/**
 * 分类入口模型。
 */
export interface CategoryItem {
  key: string;
  label: string;
  icon: string;
}

/**
 * 演示方案配置。
 * enabled 只是静态开关；社区方案（id=2）还要与 CapabilityService 的 ABI/API 结果合并，
 * 设备不满足条件时在设置页显示不可用原因。
 */
export interface SchemeOption {
  id: number;
  title: string;
  description: string;
  enabled: boolean;
}
