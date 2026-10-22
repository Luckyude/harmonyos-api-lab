/**
 * 最近 5 次请求记录，最新的排在最上面。
 */

import {
  COLOR_BORDER,
  COLOR_CARD,
  COLOR_ERROR,
  COLOR_PRIMARY_SOFT,
  COLOR_PRIMARY_STRONG,
  COLOR_PRIMARY_TEXT,
  COLOR_SUCCESS,
  COLOR_TEXT,
  COLOR_TEXT_SECONDARY,
  COLOR_TEXT_TERTIARY
} from '../constants/theme';
import { CheckResult } from '../model/checkTypes';
import { formatStatus, formatTime } from '../utils/formatUtils';

@ComponentV2
export struct HistoryList {
  @Param records: CheckResult[] = [];

  build() {
    Column({ space: 10 }) {
      if (this.records.length > 0) {
        Row({ space: 8 }) {
          Row()
            .width(3)
            .height(14)
            .backgroundColor(COLOR_PRIMARY_STRONG)
            .borderRadius(2)
          Text('最近 5 次')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLOR_TEXT)
          Blank()
          Text(`${this.records.length} 条`)
            .fontSize(11)
            .fontColor(COLOR_TEXT_TERTIARY)
        }
        .width('100%')
        .padding({ left: 2, right: 2 })

        ForEach(this.records, (item: CheckResult) => {
          Row({ space: 10 }) {
            Row()
              .width(3)
              .height(38)
              .backgroundColor(item.ok ? COLOR_SUCCESS : COLOR_ERROR)
              .borderRadius(2)

            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(item.method)
                  .fontSize(10)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(COLOR_PRIMARY_TEXT)
                  .padding({ left: 5, right: 5, top: 1, bottom: 1 })
                  .backgroundColor(COLOR_PRIMARY_SOFT)
                  .borderRadius(4)
                Text(formatStatus(item))
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(item.ok ? COLOR_SUCCESS : COLOR_ERROR)
                Text(`${item.elapsedMs} ms`)
                  .fontSize(11)
                  .fontColor(COLOR_TEXT_SECONDARY)
                Blank()
                Text(formatTime(item.finishedAt))
                  .fontSize(11)
                  .fontColor(COLOR_TEXT_TERTIARY)
              }
              .width('100%')

              Text(item.url)
                .fontSize(13)
                .fontColor(COLOR_TEXT)
                .width('100%')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(COLOR_CARD)
          .borderRadius(12)
          .border({ width: 1, color: COLOR_BORDER })
        }, (item: CheckResult) => item.id.toString())
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
