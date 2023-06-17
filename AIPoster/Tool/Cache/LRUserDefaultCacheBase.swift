//
//  LRUserDefaultCacheBase.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/13.
//

import UIKit

let GroupID: String = "group.com.smartclean.storagecleaner"

// MARK: UserDefaults 存储基础类
class LRUserDefaultCacheBase: NSObject {
    
    // MARK: Public methods
    public class func standardCache(value: Any, key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public class func standardRead(key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    public class func standardDelete(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    public class func groupCache(value: Any, key: String) {
        guard let customDefaults: UserDefaults = UserDefaults.init(suiteName: GroupID) else {
            return
        }
        customDefaults.set(value, forKey: key)
    }
    
    public class func groupRead(key: String) -> Any? {
        guard let customDefaults: UserDefaults = UserDefaults.init(suiteName: GroupID) else {
            return nil
        }
        return customDefaults.value(forKey: key)
    }
    
    public class func groupDelete(key: String) {
        guard let customDefaults: UserDefaults = UserDefaults.init(suiteName: GroupID) else {
            return
        }
        customDefaults.removeObject(forKey: key)
    }
}
