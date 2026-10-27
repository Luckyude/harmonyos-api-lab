import { CategoryItem, Product, SchemeOption } from '../model/Product';

/**
 * 底部导航顺序与图标类型，四个页面共用。
 */
export interface NavItem {
  label: string;
  icon: string;
}

export const NAV_ITEMS: NavItem[] = [
  { label: '推荐', icon: 'home' },
  { label: '分类', icon: 'category' },
  { label: '购物袋', icon: 'bag' },
  { label: '我的', icon: 'profile' }
];

/**
 * 三套导航统一尺寸：官方 HdsTabs 在 Pura X 上实测为 272vp × 68vp，
 * 底部距屏幕安全区 14vp。普通和社区方案必须复用这组值，避免图标中心
 * 与官方页签错位后出现“点我的却进购物袋”的命中偏移。
 */
export const NAV_BAR_WIDTH: number = 272;
export const NAV_BAR_HEIGHT: number = 68;
export const NAV_BAR_BOTTOM: number = 14;
/** 官方页签内容左右内缩 12vp，4 个 62vp 页签的中心才与 HdsTabs 对齐 */
export const NAV_BAR_SIDE_PADDING: number = 12;

/**
 * 首页分类入口：图标使用统一的线条图标，不用 Emoji 或大色块。
 */
export const CATEGORY_ITEMS: CategoryItem[] = [
  { key: '居家', label: '居家', icon: 'home' },
  { key: '随行', label: '随行', icon: 'commute' },
  { key: '数码', label: '数码', icon: 'digital' },
  { key: '收纳', label: '收纳', icon: 'storage' }
];

/**
 * 8 件本地演示商品。图片为项目内生成的本地资源，离线可见。
 */
export const PRODUCTS: Product[] = [
  {
    id: 'p-tumbler',
    name: '随行保温杯',
    spec: '500ml · 316 不锈钢',
    price: 89,
    category: '随行',
    image: $r('app.media.product_tumbler')
  },
  {
    id: 'p-earbuds',
    name: '轻量无线耳机',
    spec: '入耳式 · 24 小时续航',
    price: 199,
    category: '数码',
    image: $r('app.media.product_earbuds')
  },
  {
    id: 'p-tote',
    name: '帆布托特包',
    spec: '米白 · 大容量',
    price: 69,
    category: '随行',
    image: $r('app.media.product_tote')
  },
  {
    id: 'p-lamp',
    name: '木质桌面灯',
    spec: '暖光 · 三档亮度',
    price: 129,
    category: '居家',
    image: $r('app.media.product_lamp')
  },
  {
    id: 'p-basket',
    name: '藤编收纳篮',
    spec: '中号 · 带提手',
    price: 79,
    category: '收纳',
    image: $r('app.media.product_basket')
  },
  {
    id: 'p-coffee',
    name: '便携咖啡杯',
    spec: '380ml · 防漏杯盖',
    price: 99,
    category: '随行',
    image: $r('app.media.product_coffee_cup')
  },
  {
    id: 'p-stand',
    name: '铝合金桌面支架',
    spec: '可折叠 · 多角度',
    price: 59,
    category: '数码',
    image: $r('app.media.product_stand')
  },
  {
    id: 'p-pouch',
    name: '旅行收纳袋',
    spec: '防泼水 · 多隔层',
    price: 49,
    category: '收纳',
    image: $r('app.media.product_travel_pouch')
  }
];

/**
 * 演示设置中的三套方案。
 * 社区方案固定 com.hm.appleui.hw 2.1.0：单个透镜只做底部导航胶囊材质，
 * 采样紧邻下层的实时商品内容；这里只写库版本与结构，不宣称渲染已经成功。
 * 实际是否可选还要与 CapabilityService 的 ABI/API 检查结果合并。
 */
export const SCHEME_OPTIONS: SchemeOption[] = [
  {
    id: 0,
    title: '普通导航',
    description: '白色悬浮导航，不使用系统材质',
    enabled: true
  },
  {
    id: 1,
    title: '官方沉浸光感',
    description: 'HDS 悬浮页签 + systemMaterialEffect',
    enabled: true
  },
  {
    id: 2,
    title: '社区液态玻璃',
    description: 'AppleUI 2.1.0 · 单透镜材质层',
    enabled: true
  }
];

/**
 * 按分类读取商品，分类页和推荐页共用同一份数据。
 */
export function productsByCategory(category: string): Product[] {
  return PRODUCTS.filter((product: Product) => product.category === category);
}

/**
 * 统计分类商品数量。
 */
export function categoryCount(category: string): number {
  return productsByCategory(category).length;
}
