/**
 * 接口自检：选择请求方式、填地址和请求体，发请求后看状态码和响应。
 * 支持 GET / POST / PUT / DELETE，保留最近 5 次记录。
 */

import { HistoryList } from '../components/HistoryList';
import { ResultCard } from '../components/ResultCard';
import { DEFAULT_URL, HISTORY_LIMIT } from '../constants/apiConstants';
import {
  COLOR_BG,
  COLOR_BORDER,
  COLOR_CARD,
  COLOR_CARD_SHADOW,
  COLOR_HERO_BG,
  COLOR_HERO_CHIP_BG,
  COLOR_HERO_DECOR,
  COLOR_HERO_SHADOW,
  COLOR_HERO_SUBTITLE,
  COLOR_HERO_TITLE,
  COLOR_INPUT_BG,
  COLOR_ON_PRIMARY,
  COLOR_PRIMARY,
  COLOR_PRIMARY_SOFT,
  COLOR_PRIMARY_STRONG,
  COLOR_PRIMARY_TEXT,
  COLOR_TEXT,
  COLOR_TEXT_SECONDARY,
  COLOR_TEXT_TERTIARY
} from '../constants/theme';
import { CheckResult } from '../model/checkTypes';
import { HttpService } from '../service/httpService';

@Entry
@ComponentV2
struct Index {
  /** 请求方式 */
  @Local method: string = 'GET';
  /** 请求地址，默认先填一个 HTTPS 地址 */
  @Local url: string = DEFAULT_URL;
  /** 请求体，GET 时不用 */
  @Local body: string = '';
  /** 最近一次点击对应的结果 */
  @Local result: CheckResult | null = null;
  /** 最近 5 次记录，新的在前 */
  @Local history: CheckResult[] = [];
  /** 进行中的请求数，连点时会大于 1 */
  @Local pending: number = 0;
  /** 请求序号，保证只有最后一次点击能改写结果区 */
  private seq: number = 0;
  /** 可选请求方式 */
  private methods: string[] = ['GET', 'POST', 'PUT', 'DELETE'];

  /**
   * 发一次请求。允许并发，每次结果独立进历史，最后点击的那次决定结果区。
   * @param method 请求方式
   * @param url 用户输入或重发带入的地址
   * @param body 请求体
   */
  private async send(method: string, url: string, body: string): Promise<void> {
    this.seq += 1;
    const currentSeq: number = this.seq;
    const target: string = url.trim();
    this.pending += 1;
    try {
      const outcome: CheckResult = await HttpService.request(target, method, body, currentSeq);
      this.appendHistory(outcome);
      if (currentSeq === this.seq) {
        this.result = outcome;
      }
    } finally {
      this.pending -= 1;
    }
  }

  /**
   * 把新记录插到最前面，只留 5 条
   * @param record 刚完成的请求结果
   */
  private appendHistory(record: CheckResult): void {
    const next: CheckResult[] = [record];
    for (let i = 0; i < this.history.length && next.length < HISTORY_LIMIT; i++) {
      next.push(this.history[i]);
    }
    this.history = next;
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          this.hero()
          this.requestCard()
          if (this.result === null) {
            this.emptyCard()
          } else {
            ResultCard({
              result: this.result,
              onResend: () => {
                const current: CheckResult | null = this.result;
                if (current !== null) {
                  this.send(current.method, current.url, current.body);
                }
              }
            })
          }
          HistoryList({ records: this.history })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .width('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG)
  }

  /** 顶部标题卡，纯色暖调，无渐变 */
  @Builder
  hero() {
    Row() {
      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Text('接口自检')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLOR_HERO_TITLE)
          Text('HTTP')
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLOR_PRIMARY_TEXT)
            .padding({ left: 7, right: 7, top: 3, bottom: 3 })
            .backgroundColor(COLOR_HERO_CHIP_BG)
            .borderRadius(6)
        }
        .alignItems(VerticalAlign.Center)

        Text('内网服务 · 一键确认是否在线')
          .fontSize(12)
          .fontColor(COLOR_HERO_SUBTITLE)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('API')
        .fontSize(64)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLOR_HERO_DECOR)
    }
    .width('100%')
    .height(132)
    .padding({ left: 22, right: 22 })
    .alignItems(VerticalAlign.Center)
    .borderRadius(22)
    .backgroundColor(COLOR_HERO_BG)
    .shadow({ radius: 22, color: COLOR_HERO_SHADOW, offsetX: 0, offsetY: 8 })
  }

  /** 请求方式、地址、请求体与发送入口 */
  @Builder
  requestCard() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Row()
          .width(3)
          .height(14)
          .backgroundColor(COLOR_PRIMARY_STRONG)
          .borderRadius(2)
        Text('请求方式')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_TEXT)
      }
      .width('100%')

      Row({ space: 6 }) {
        ForEach(this.methods, (item: string) => {
          Text(item)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.method === item ? COLOR_ON_PRIMARY : COLOR_TEXT_SECONDARY)
            .padding({ top: 9, bottom: 9 })
            .backgroundColor(this.method === item ? COLOR_PRIMARY : COLOR_INPUT_BG)
            .borderRadius(8)
            .onClick(() => {
              this.method = item;
            })
        }, (item: string) => item)
      }
      .width('100%')

      Row({ space: 8 }) {
        Row()
          .width(3)
          .height(14)
          .backgroundColor(COLOR_PRIMARY_STRONG)
          .borderRadius(2)
        Text('请求地址')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_TEXT)
      }
      .width('100%')

      Row({ space: 10 }) {
        Row() {
          Text('URL')
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLOR_PRIMARY_TEXT)
        }
        .width(38)
        .height(38)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(COLOR_PRIMARY_SOFT)
        .borderRadius(11)

        TextInput({ text: this.url, placeholder: 'https://example.com' })
          .layoutWeight(1)
          .height(50)
          .fontSize(14)
          .fontColor(COLOR_TEXT)
          .backgroundColor(COLOR_INPUT_BG)
          .borderRadius(12)
          .border({ width: 1, color: COLOR_BORDER })
          .caretColor(COLOR_PRIMARY_STRONG)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.url = value;
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (this.method !== 'GET') {
        Column({ space: 6 }) {
          Text('请求体（JSON）')
            .fontSize(12)
            .fontColor(COLOR_TEXT_SECONDARY)
            .width('100%')
          TextArea({ text: this.body, placeholder: '{"key": "value"}' })
            .height(96)
            .fontSize(12)
            .fontColor(COLOR_TEXT)
            .placeholderColor(COLOR_TEXT_TERTIARY)
            .backgroundColor(COLOR_INPUT_BG)
            .borderRadius(10)
            .border({ width: 1, color: COLOR_BORDER })
            .caretColor(COLOR_PRIMARY_STRONG)
            .padding(10)
            .onChange((value: string) => {
              this.body = value;
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      Button() {
        Row({ space: 8 }) {
          Text('发送')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLOR_ON_PRIMARY)
          Text('→')
            .fontSize(16)
            .fontColor(COLOR_PRIMARY_TEXT)
        }
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height(50)
      .type(ButtonType.Normal)
      .borderRadius(12)
      .backgroundColor(COLOR_PRIMARY)
      .shadow({ radius: 14, color: COLOR_CARD_SHADOW, offsetX: 0, offsetY: 5 })
      .onClick(() => {
        this.send(this.method, this.url, this.body);
      })

      if (this.pending > 0) {
        Row({ space: 8 }) {
          LoadingProgress()
            .width(16)
            .height(16)
            .color(COLOR_PRIMARY_STRONG)
          Text('请求中…')
            .fontSize(12)
            .fontColor(COLOR_TEXT_SECONDARY)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(COLOR_CARD)
    .borderRadius(18)
    .shadow({ radius: 20, color: COLOR_CARD_SHADOW, offsetX: 0, offsetY: 8 })
  }

  /** 首次进入，结果区先占位 */
  @Builder
  emptyCard() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(46)
          .height(46)
          .fill(COLOR_PRIMARY_SOFT)
        Text('HTTP')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLOR_PRIMARY_TEXT)
      }

      Text('还没有结果')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLOR_TEXT_SECONDARY)
      Text('选择请求方式、填好地址后点「发送」，这里会显示状态码、耗时和响应内容')
        .fontSize(12)
        .fontColor(COLOR_TEXT_TERTIARY)
        .lineHeight(18)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 22, bottom: 22 })
    .backgroundColor(COLOR_CARD)
    .borderRadius(18)
    .border({ width: 1, color: COLOR_BORDER, style: BorderStyle.Dashed })
    .alignItems(HorizontalAlign.Center)
  }
}
