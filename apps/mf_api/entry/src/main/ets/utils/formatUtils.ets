/**
 * 结果展示用的小工具，避免结果区和历史列表各写一套格式。
 */

import { CheckResult } from '../model/checkTypes';

/**
 * 状态码文案：有 HTTP 响应就显示码，纯网络失败显示「失败」
 * @param result 自检结果
 * @returns 展示文案
 */
export function formatStatus(result: CheckResult): string {
  return result.statusCode > 0 ? `${result.statusCode}` : '失败';
}

/**
 * 把时间戳格式化成 HH:mm:ss，历史列表只关心当天时刻
 * @param timestamp 毫秒时间戳
 * @returns 时分秒
 */
export function formatTime(timestamp: number): string {
  const date = new Date(timestamp);
  return `${pad2(date.getHours())}:${pad2(date.getMinutes())}:${pad2(date.getSeconds())}`;
}

/**
 * 个位数补零
 * @param value 0-59
 * @returns 两位字符串
 */
function pad2(value: number): string {
  return value < 10 ? `0${value}` : `${value}`;
}
