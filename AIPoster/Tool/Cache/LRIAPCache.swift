//
//  LRIAPCache.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/13.
//

import UIKit

class LRIAPCache: LRUserDefaultCacheBase {
    // MARK: 内购
    /// 存储IAP购买信息
    public class func saveIAPPurchase(iapInfo: IAPPurchaseInfo) {
        do {
            let data = try PropertyListEncoder().encode(iapInfo)
            standardCache(value: data, key: IAPPurchaseCacheKey)
        } catch let error {
            print("IAP内购保存错误: \(error.localizedDescription)")
        }
    }
    
    /// 获取IAP购买信息
    public class func getIAPPurchase() -> IAPPurchaseInfo? {
        if let iapData = standardRead(key: IAPPurchaseCacheKey) as? Data {
            do {
                let iapInfo = try PropertyListDecoder().decode(IAPPurchaseInfo.self, from: iapData)
                return iapInfo
            } catch let error {
                print("IAP内购解析失败: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    /// 移除IAP购买信息
    public class func removeIAPPurchase() {
        standardDelete(key: IAPPurchaseCacheKey)
    }
    
    // MARK: 当天是否已经弹出订阅页面
    /// 当天是否已经弹出订阅页面
    public class func todayShowSubscribePage() -> Bool {
        var isShow: Bool = false
        guard let _date = standardRead(key: HSAPPShowSubscribePageTodayKey) as? Date else {
            standardCache(value: Date().localDate(), key: HSAPPShowSubscribePageTodayKey)
            return isShow
        }
        if _date.isSameDay(Date().localDate()) {
            isShow = true
        } else {
            standardCache(value: Date().localDate(), key: HSAPPShowSubscribePageTodayKey)
        }
        return isShow
    }
}
