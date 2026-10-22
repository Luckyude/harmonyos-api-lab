/**
 * 接口自检用到的固定参数。
 * 只保留改地址、调超时、控制展示长度这三类。
 */

/** hilog 统一过滤 tag */
export const LOG_TAG: string = 'MfApi';

/** 默认地址，点开就能发一次，确认 HTTPS 通路 */
export const DEFAULT_URL: string = 'https://www.baidu.com';

/** 自检服务都在内网，10 秒没响应就按失败处理，避免页面一直等 */
export const REQUEST_TIMEOUT_MS: number = 10000;

/** 结果区只展示响应内容前 300 个字 */
export const SNIPPET_LIMIT: number = 300;

/** 历史列表保留最近 5 次 */
export const HISTORY_LIMIT: number = 5;
