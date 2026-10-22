/**
 * 一次请求的结果。结果区和历史列表共用这一份结构。
 */
export interface CheckResult {
  /** 请求序号，页面用它给列表做 key 并判断哪次是最新请求 */
  id: number;
  /** 请求方式：GET / POST / PUT / DELETE */
  method: string;
  /** 请求地址 */
  url: string;
  /** 请求体，GET 时为空串；重发时按原样带回 */
  body: string;
  /** HTTP 2xx 且没有网络异常时为 true */
  ok: boolean;
  /** HTTP 状态码，网络异常时为 0 */
  statusCode: number;
  /** 从发起到结束的耗时 */
  elapsedMs: number;
  /** 响应内容前 300 个字 */
  snippet: string;
  /** 网络异常原因，成功时为空串 */
  errorMessage: string;
  /** 完成时间，用于历史列表显示 */
  finishedAt: number;
}
