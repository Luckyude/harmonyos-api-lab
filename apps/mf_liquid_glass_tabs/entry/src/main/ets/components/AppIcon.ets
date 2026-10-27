/**
 * 统一线条图标：底部导航、分类入口和购物袋操作共用同一套路径。
 * 不使用 Emoji 或系统默认应用图标，避免正式业务界面出现演示感。
 */
@ComponentV2
export struct AppIcon {
  @Param type: string = 'home';
  @Param color: string = '#737B77';
  @Param iconSize: number = 24;

  /**
   * 分类图标用填充方块，其余图标用描边。
   */
  private isFilled(): boolean {
    return this.type === 'category';
  }

  /**
   * Path.commands 的单位是 px，直接使用 24 单位路径会在高密度屏上偏小。
   * 按屏幕密度和 iconSize 缩放路径坐标，保证绘制结果按 vp 尺寸显示。
   */
  private scaledCommands(): string {
    const factor: number = this.getUIContext().vp2px(1) * this.iconSize / 24;
    return this.pathData().replace(/-?\d+(?:\.\d+)?/g, (token: string) => {
      return (Number(token) * factor).toFixed(2);
    });
  }

  /**
   * 图标路径统一在 24 × 24 坐标系内定义。
   */
  private pathData(): string {
    switch (this.type) {
      case 'home':
        return 'M4 10.5 L12 4 L20 10.5 V20 H14 V14 H10 V20 H4 Z';
      case 'category':
        return 'M3 3 H10 V10 H3 Z M14 3 H21 V10 H14 Z M3 14 H10 V21 H3 Z M14 14 H21 V21 H14 Z';
      case 'bag':
        return 'M5 8 H19 L20 20 H4 Z M8 8 V6 C8 3.79 9.79 2 12 2 C14.21 2 16 3.79 16 6 V8';
      case 'profile':
        return 'M12 12 C14.21 12 16 10.21 16 8 C16 5.79 14.21 4 12 4 C9.79 4 8 5.79 8 8 C8 10.21 9.79 12 12 12 Z M4 21 C4 17 7.5 15 12 15 C16.5 15 20 17 20 21';
      case 'search':
        return 'M11 4 C14.86 4 18 7.14 18 11 C18 14.86 14.86 18 11 18 C7.14 18 4 14.86 4 11 C4 7.14 7.14 4 11 4 Z M16 16 L21 21';
      case 'close':
        return 'M6 6 L18 18 M18 6 L6 18';
      case 'plus':
        return 'M12 5 V19 M5 12 H19';
      case 'minus':
        return 'M5 12 H19';
      case 'trash':
        return 'M5 7 H19 M9 7 V4 H15 V7 M7 7 L8 21 H16 L17 7';
      case 'chevron':
        return 'M9 5 L16 12 L9 19';
      case 'check':
        return 'M5 12 L10 17 L19 7';
      case 'info':
        return 'M12 3 C16.97 3 21 7.03 21 12 C21 16.97 16.97 21 12 21 C7.03 21 3 16.97 3 12 C3 7.03 7.03 3 12 3 Z M12 10 V17 M12 7 V7.5';
      case 'settings':
        return 'M4 7 H20 M4 12 H20 M4 17 H20 M8 5 V9 M16 10 V14 M10 15 V19';
      case 'commute':
        return 'M8 4 H16 V7 H18 V20 H6 V7 H8 Z M8 11 H16';
      case 'digital':
        return 'M7 4 H17 V20 H7 Z M10 17 H14';
      case 'storage':
        return 'M4 8 L12 4 L20 8 V16 L12 20 L4 16 Z M4 8 L12 12 L20 8 M12 12 V20';
      default:
        return 'M4 12 H20';
    }
  }

  build() {
    Path({
      width: this.iconSize,
      height: this.iconSize,
      commands: this.scaledCommands()
    })
      .fill(this.isFilled() ? this.color : Color.Transparent)
      .stroke(this.isFilled() ? Color.Transparent : this.color)
      .strokeWidth(this.isFilled() ? 0 : 2.4)
      .strokeLineCap(LineCapStyle.Round)
      .strokeLineJoin(LineJoinStyle.Round)
  }
}
