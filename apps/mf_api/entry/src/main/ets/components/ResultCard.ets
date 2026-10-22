/**
 * 最近一次请求的结果区：状态码、耗时、响应内容前 300 字，以及重发入口。
 */

import {
  COLOR_BORDER,
  COLOR_CARD,
  COLOR_CARD_SHADOW,
  COLOR_CODE_BG,
  COLOR_CODE_MUTED,
  COLOR_CODE_TEXT,
  COLOR_ERROR,
  COLOR_ERROR_SOFT,
  COLOR_PRIMARY_SOFT,
  COLOR_PRIMARY_TEXT,
  COLOR_SUCCESS,
  COLOR_SUCCESS_SOFT,
  COLOR_TEXT,
  COLOR_TEXT_SECONDARY,
  COLOR_TEXT_TERTIARY
} from '../constants/theme';
import { CheckResult } from '../model/checkTypes';
import { formatStatus } from '../utils/formatUtils';

@ComponentV2
export struct ResultCard {
  @Param result: CheckResult = {
    id: 0,
    method: 'GET',
    url: '',
    body: '',
    ok: false,
    statusCode: 0,
    elapsedMs: 0,
    snippet: '',
    errorMessage: '',
    finishedAt: 0
  };
  @Event onResend: () => void = () => {
  };

  build() {
    Column() {
      // 顶部色条：成功绿色，失败红色，让结果一眼可辨
      Row()
        .width('100%')
        .height(4)
        .backgroundColor(this.result.ok ? COLOR_SUCCESS : COLOR_ERROR)

      Column({ space: 12 }) {
        Row({ space: 14 }) {
          Stack({ alignContent: Alignment.Center }) {
            Circle()
              .width(60)
              .height(60)
              .fill(this.result.ok ? COLOR_SUCCESS_SOFT : COLOR_ERROR_SOFT)
            Text(formatStatus(this.result))
              .fontSize(this.result.statusCode > 0 ? 22 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.result.ok ? COLOR_SUCCESS : COLOR_ERROR)
          }

          Column({ space: 4 }) {
            Row({ space: 6 }) {
              Text(this.result.method)
                .fontSize(10)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLOR_PRIMARY_TEXT)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor(COLOR_PRIMARY_SOFT)
                .borderRadius(5)
              Text(this.result.ok ? '请求成功' : '请求失败')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLOR_TEXT)
            }
            .alignItems(VerticalAlign.Center)

            Row({ space: 5 }) {
              Text('耗时')
                .fontSize(11)
                .fontColor(COLOR_TEXT_TERTIARY)
              Text(`${this.result.elapsedMs} ms`)
                .fontSize(12)
                .fontColor(COLOR_TEXT_SECONDARY)
            }
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Button('重发')
            .height(34)
            .fontSize(13)
            .fontColor(COLOR_PRIMARY_TEXT)
            .backgroundColor(COLOR_PRIMARY_SOFT)
            .borderRadius(9)
            .padding({ left: 14, right: 14 })
            .onClick(() => {
              this.onResend();
            })
        }
        .width('100%')

        if (this.result.errorMessage.length > 0) {
          Row({ space: 10 }) {
            Row()
              .width(3)
              .height(34)
              .backgroundColor(COLOR_ERROR)
              .borderRadius(2)

            Column({ space: 3 }) {
              Text('失败原因')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLOR_ERROR)
              Text(this.result.errorMessage)
                .fontSize(13)
                .fontColor(COLOR_ERROR)
                .lineHeight(19)
                .width('100%')
                .wordBreak(WordBreak.BREAK_ALL)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(COLOR_ERROR_SOFT)
          .borderRadius(10)
        }

        if (this.result.statusCode > 0) {
          Column({ space: 8 }) {
            Row() {
              Text('响应内容')
                .fontSize(12)
                .fontColor(COLOR_CODE_MUTED)
              Blank()
              Text('前 300 字')
                .fontSize(11)
                .fontColor(COLOR_CODE_MUTED)
            }
            .width('100%')

            Text(this.result.snippet.length > 0 ? this.result.snippet : '（空响应）')
              .fontSize(12)
              .fontColor(COLOR_CODE_TEXT)
              .lineHeight(19)
              .width('100%')
              .wordBreak(WordBreak.BREAK_ALL)
          }
          .width('100%')
          .padding(13)
          .backgroundColor(COLOR_CODE_BG)
          .borderRadius(12)
          .border({ width: 1, color: COLOR_BORDER })
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .padding(18)
    }
    .width('100%')
    .backgroundColor(COLOR_CARD)
    .borderRadius(18)
    .clip(true)
    .shadow({ radius: 20, color: COLOR_CARD_SHADOW, offsetX: 0, offsetY: 8 })
  }
}
