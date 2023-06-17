//
//  LRUserDefaultADCache.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/3/9.
//

import UIKit

// MARK: 广告存储类
class LRUserDefaultADCache: LRUserDefaultCacheBase {
    
    /// 存储切换页面的次数
    public class func saveSwitchPageCount(_ count: Int) {
        standardCache(value: count, key: CleanSwitchADPageKey)
    }
    
    /// 获取切换页面的次数
    public class func getSwitchPageCount() -> Int {
        if let _count = standardRead(key: CleanSwitchADPageKey) as? Int {
            return _count
        }
        return 0
    }
    
    /// 重置切换页面的次数
    public class func resetSwitchPageCount() {
        standardDelete(key: CleanSwitchADPageKey)
    }
    
    /// 存储当次展示插屏广告的时间
    public class func saveShowInterstitialTime(_ timestamp: TimeInterval) {
        standardCache(value: timestamp, key: CleanSwitchADPageTimeKey)
    }

    /// 判断是否要展示插屏广告
    public class func showInterstitialADTime() -> TimeInterval? {
        if let _value = standardRead(key: CleanSwitchADPageTimeKey) as? TimeInterval {
            return _value
        }
        return nil
    }
    
    /// 重置广告展示的时间
    public class func resetShowInterstitialTime() {
        standardDelete(key: CleanSwitchADPageTimeKey)
    }
}
