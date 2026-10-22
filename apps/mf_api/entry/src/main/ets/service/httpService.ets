/**
 * 系统网络能力封装：支持 GET / POST / PUT / DELETE。
 * 网络失败不抛出，统一转成 CheckResult，页面永远有东西可展示。
 */

import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { LOG_TAG, REQUEST_TIMEOUT_MS, SNIPPET_LIMIT } from '../constants/apiConstants';
import { CheckResult } from '../model/checkTypes';

export class HttpService {

  /**
   * 发起一次请求
   * @param url 已去空格的完整地址
   * @param method GET / POST / PUT / DELETE
   * @param body 请求体，GET 时传空串
   * @param id 请求序号，由页面生成
   * @returns 请求结果
   */
  static async request(url: string, method: string, body: string, id: number): Promise<CheckResult> {
    if (url.length === 0) {
      return HttpService.failure(id, method, url, body, 0, '地址不能为空', 0);
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return HttpService.failure(id, method, url, body, 0, '地址需以 http:// 或 https:// 开头', 0);
    }

    const startedAt: number = Date.now();
    // 每次请求单独的 HttpRequest，互不影响，连点也不会串结果
    const request = http.createHttp();
    try {
      const response = await request.request(url,
        HttpService.buildOptions(HttpService.toRequestMethod(method), body));
      const elapsedMs: number = Date.now() - startedAt;
      const responseBody: string =
        typeof response.result === 'string' ? response.result : JSON.stringify(response.result);
      const statusCode: number = response.responseCode;
      const ok: boolean = statusCode >= 200 && statusCode < 300;
      hilog.info(0x0000, LOG_TAG, '%{public}s %{public}s -> %{public}d, %{public}dms',
        method, url, statusCode, elapsedMs);
      const result: CheckResult = {
        id: id,
        method: method,
        url: url,
        body: body,
        ok: ok,
        statusCode: statusCode,
        elapsedMs: elapsedMs,
        snippet: HttpService.takeSnippet(responseBody),
        errorMessage: '',
        finishedAt: Date.now()
      };
      return result;
    } catch (error) {
      // 断网、地址写错、服务没起都会走到这里，错误码原样给用户看
      const err = error as BusinessError;
      const elapsedMs: number = Date.now() - startedAt;
      const message: string = `${err.code} ${err.message}`;
      hilog.error(0x0000, LOG_TAG, '%{public}s %{public}s failed: %{public}s',
        method, url, message);
      return HttpService.failure(id, method, url, body, elapsedMs, message, Date.now());
    } finally {
      request.destroy();
    }
  }

  /**
   * 把页面上的方式字符串映射成系统枚举
   * @param method 页面选择的方式
   * @returns 系统请求方式
   */
  private static toRequestMethod(method: string): http.RequestMethod {
    if (method === 'POST') {
      return http.RequestMethod.POST;
    }
    if (method === 'PUT') {
      return http.RequestMethod.PUT;
    }
    if (method === 'DELETE') {
      return http.RequestMethod.DELETE;
    }
    return http.RequestMethod.GET;
  }

  /**
   * 组装请求参数。GET 不带请求体，其他方式有内容时才带 extraData。
   * @param method 系统请求方式
   * @param body 请求体
   * @returns HTTP 请求参数
   */
  private static buildOptions(method: http.RequestMethod, body: string): http.HttpRequestOptions {
    const header: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (body.length > 0 && method !== http.RequestMethod.GET) {
      const optionsWithBody: http.HttpRequestOptions = {
        method: method,
        header: header,
        extraData: body,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: REQUEST_TIMEOUT_MS,
        readTimeout: REQUEST_TIMEOUT_MS,
        usingCache: false
      };
      return optionsWithBody;
    }
    const options: http.HttpRequestOptions = {
      method: method,
      header: header,
      expectDataType: http.HttpDataType.STRING,
      connectTimeout: REQUEST_TIMEOUT_MS,
      readTimeout: REQUEST_TIMEOUT_MS,
      usingCache: false
    };
    return options;
  }

  /**
   * 截取响应内容前 300 个字
   * @param body 完整响应
   * @returns 展示用片段
   */
  private static takeSnippet(body: string): string {
    if (body.length <= SNIPPET_LIMIT) {
      return body;
    }
    return `${body.substring(0, SNIPPET_LIMIT)}…`;
  }

  /**
   * 构造失败结果，保证调用方拿到的结构始终一致
   * @param id 请求序号
   * @param method 请求方式
   * @param url 请求地址
   * @param body 请求体
   * @param elapsedMs 耗时
   * @param message 失败原因
   * @param finishedAt 完成时间
   * @returns 失败结果
   */
  private static failure(id: number, method: string, url: string, body: string, elapsedMs: number,
    message: string, finishedAt: number): CheckResult {
    const result: CheckResult = {
      id: id,
      method: method,
      url: url,
      body: body,
      ok: false,
      statusCode: 0,
      elapsedMs: elapsedMs,
      snippet: '',
      errorMessage: message,
      finishedAt: finishedAt > 0 ? finishedAt : Date.now()
    };
    return result;
  }
}
