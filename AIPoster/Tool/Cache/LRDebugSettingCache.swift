//
//  LRDebugSettingCache.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2023/1/11.
//

import UIKit

class LRDebugSettingCache: LRUserDefaultCacheBase {
 
    /// 存储是否校验VIP过期时间
    public class func saveVerifyVIPTimeConfig(_ isVertify: Bool) {
        standardCache(value: isVertify, key: VerifyVIPExpirationTimeKey)
    }
    
    /// 判断DEBUG环境下是否不检验VIP过期时间
    public class func verifyVIPTimeConfig() -> Bool {
        if let _value = standardRead(key: VerifyVIPExpirationTimeKey) as? Bool {
            return _value
        }
        return false
    }
    
    /// 删除是否校验VIP过期时间
    public class func deleteVerifyVIPTimeConfig() {
        standardDelete(key: VerifyVIPExpirationTimeKey)
    }
    
    // MARK: 首次安装
    /// 是否是首次安装
    public class func installForFirstTime() -> Bool {
        if let _first = standardRead(key: HSInstallForFirstTimeKey) as? Bool {
            return _first
        }
        standardCache(value: false, key: HSInstallForFirstTimeKey)
        return true
    }
    
    // MARK: 当前版本是否展示过评分
    /// 当前版本是否进行评分
    public class func showAppScoreInCurrentVersion() -> Bool {
        if let _show = standardRead(key: ShowAPPScoreKey) as? Bool {
            return _show
        }
#if DEBUG
#else
        standardCache(value: true, key: ShowAPPScoreKey)
#endif
        return false
    }
    
    // MARK: 缓存APP启动时间--->本地推送
    /// APP本地推送时间间隔
    public class func AppLocalPushTimeInterval() -> TimeInterval {
        var _timeInteral: TimeInterval = 60
        if let _t = standardRead(key: AppLocalPushTimeIntervalKey) as? TimeInterval {
            _timeInteral = _t
        }
        return _timeInteral
    }
    
    /// 存储时间间隔
    public class func saveLocalPushTimeInterval(interval: TimeInterval) {
        standardCache(value: interval, key: AppLocalPushTimeIntervalKey)
    }
    
    /// 重置时间间隔
    public class func resetLocalPushTimeInterval() {
        standardDelete(key: AppLocalPushTimeIntervalKey)
    }
    
    /// 是否要修改本地推送的时间
    public class func updateLocalPushTime() -> Bool {
        if let _update = standardRead(key: UpdateAPPLocalPushTimeKey) as? Bool {
            return _update
        }
        return false
    }
    
    /// 存储修改本地推送时间选择
    public class func saveUpdateLocalPushTime(update: Bool) {
        standardCache(value: update, key: UpdateAPPLocalPushTimeKey)
    }
}
