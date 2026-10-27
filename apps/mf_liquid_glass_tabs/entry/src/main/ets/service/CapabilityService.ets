import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 社区液态玻璃能力结果。
 * 只描述可验证的前置条件（设备 ABI、系统 API、库版本），不代表原生渲染已经出图。
 */
export interface AppleUICapability {
  /** 设备是否满足社区库的加载条件（arm64-v8a + API 20 以上） */
  available: boolean;
  /** 当前固定的社区库版本 */
  libraryVersion: string;
  /** 设备 ABI 是否包含 arm64-v8a */
  abiSupported: boolean;
  /** 系统 API 是否不低于库要求 */
  apiSupported: boolean;
  /** 设置页展示的简短结论 */
  statusText: string;
  /** 不可用时的具体原因，可用时为空字符串 */
  reasonText: string;
}

/**
 * 社区库能力检查：
 * com.hm.appleui.hw 2.1.0 只带 arm64-v8a 原生库（libliquidglass.so / libc++_shared.so），
 * 且 compatibleSdkVersion 为 API 20，因此这里只做 ABI 与 API 两项检查。
 * 不访问网络、不申请权限；渲染是否真正出图由真机运行和日志判断。
 */
export class CapabilityService {
  /** 固定的社区库版本，升级前必须重新核对该版本的 README */
  static readonly LIBRARY_VERSION: string = '2.1.0';
  /** 社区库声明的最低系统 API */
  static readonly MIN_API_VERSION: number = 20;
  /** 社区库唯一提供的原生 ABI */
  static readonly REQUIRED_ABI: string = 'arm64-v8a';

  /**
   * 检查当前设备的社区玻璃可用性。
   * @returns 能力结果，任何异常都按不可用处理并带出原因
   */
  static check(): AppleUICapability {
    try {
      const abiList: string = deviceInfo.abiList;
      const abiSupported: boolean = CapabilityService.hasAbi(abiList);
      const apiVersion: number = deviceInfo.sdkApiVersion;
      const apiSupported: boolean = apiVersion >= CapabilityService.MIN_API_VERSION;
      const available: boolean = abiSupported && apiSupported;
      const statusText: string = available
        ? `AppleUI ${CapabilityService.LIBRARY_VERSION} · arm64-v8a · API ${apiVersion}`
        : CapabilityService.buildReason(abiSupported, apiSupported, abiList, apiVersion);

      if (available) {
        hilog.info(0x0000, 'MfShop', `🟢 社区玻璃能力检查通过：${statusText}`);
      } else {
        hilog.error(0x0000, 'MfShop', `🔴 社区玻璃能力检查未通过：${statusText}`);
      }

      return {
        available: available,
        libraryVersion: CapabilityService.LIBRARY_VERSION,
        abiSupported: abiSupported,
        apiSupported: apiSupported,
        statusText: available ? statusText : `不可用：${statusText}`,
        reasonText: available ? '' : statusText
      };
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'MfShop', `🔴 社区玻璃能力检查异常 code=${err.code} message=${err.message}`);
      return {
        available: false,
        libraryVersion: CapabilityService.LIBRARY_VERSION,
        abiSupported: false,
        apiSupported: false,
        statusText: '不可用：能力检查异常',
        reasonText: `能力检查异常 code=${err.code}`
      };
    }
  }

  /**
   * 判断 ABI 列表是否包含 arm64-v8a。
   * deviceInfo.abiList 是以逗号分隔的字符串，逐项比对避免误命中子串。
   */
  private static hasAbi(abiList: string): boolean {
    const items: string[] = abiList.split(',');
    for (const item of items) {
      if (item.trim() === CapabilityService.REQUIRED_ABI) {
        return true;
      }
    }
    return false;
  }

  /**
   * 生成不可用原因，优先说明 ABI 不匹配，其次说明 API 过低。
   */
  private static buildReason(abiSupported: boolean, apiSupported: boolean,
    abiList: string, apiVersion: number): string {
    if (!abiSupported) {
      const shown: string = abiList.length > 0 ? abiList : '未知';
      return `当前设备 ABI 不含 ${CapabilityService.REQUIRED_ABI}（${shown}）`;
    }
    if (!apiSupported) {
      return `系统 API ${apiVersion} 低于社区库要求的 API ${CapabilityService.MIN_API_VERSION}`;
    }
    return '未知原因';
  }
}
