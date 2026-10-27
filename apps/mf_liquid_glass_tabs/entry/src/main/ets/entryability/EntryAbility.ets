/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } catch (err) {
      hilog.error(DOMAIN, 'MfShop', `🔴 设置浅色模式失败: ${JSON.stringify(err)}`);
    }
    hilog.info(DOMAIN, 'MfShop', '🟢 Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'MfShop', '🟢 Ability onDestroy');
  }

  /**
   * 加载首页；全屏和系统栏设置失败时也必须能进入页面。
   */
  private loadIndex(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'MfShop', `🔴 加载购物首页失败 code=${err.code} message=${err.message}`);
        return;
      }
      hilog.info(DOMAIN, 'MfShop', '🟢 购物首页加载完成');
    });
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'MfShop', '🟢 Ability onWindowStageCreate');

    // 让背景铺到状态栏和导航条下面；安全区数值交给 Index 做内容内边距，避免悬浮导航压住系统手势区。
    try {
      const mainWindow: window.Window = windowStage.getMainWindowSync();
      mainWindow.setWindowLayoutFullScreen(true)
        .then(() => {
          const area: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
          AppStorage.setOrCreate('topSafePx', area.topRect.height);
          AppStorage.setOrCreate('bottomSafePx', area.bottomRect.height);
          hilog.info(DOMAIN, 'MfShop',
            `🟢 安全区 px: top=${area.topRect.height} bottom=${area.bottomRect.height}`);
          return mainWindow.setWindowSystemBarProperties({
            statusBarColor: '#00000000',
            statusBarContentColor: '#252A28',
            navigationBarColor: '#00000000',
            navigationBarContentColor: '#252A28'
          });
        })
        .then(() => {
          hilog.info(DOMAIN, 'MfShop', '🟢 全屏与系统栏设置完成');
          this.loadIndex(windowStage);
        })
        .catch((error: BusinessError) => {
          hilog.error(DOMAIN, 'MfShop',
            `🔴 全屏或系统栏设置失败 code=${error.code} message=${error.message}`);
          this.loadIndex(windowStage);
        });
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, 'MfShop', `🔴 获取主窗口失败 code=${err.code} message=${err.message}`);
      this.loadIndex(windowStage);
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'MfShop', '🟢 Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'MfShop', '🟢 Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'MfShop', '🟢 Ability onBackground');
  }
}