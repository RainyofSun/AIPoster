//
//  LRFacebookStatistics.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/9/22.
//

import UIKit
import FBSDKCoreKit

class LRFacebookStatistics: NSObject {

    public static let shared = LRFacebookStatistics()
    override init() {
        super.init()
        
    }
    
    /// 前后台切换激活app
    public func activeApp() {
        FBSDKCoreKit.AppEvents.shared.activateApp()
    }
    
    /// 打开/关闭广告跟踪
    public func advertiserTrackingEnabled(open: Bool) {
        FBSDKCoreKit.Settings.shared.isAdvertiserIDCollectionEnabled = open
    }
    
    /// 购买统计信息
    public func iapPurchaseInfo(_ productId: String) {
        FBSDKCoreKit.AppEvents.shared.logPurchase(amount: 1.0, currency: "USD")
        let params: [AppEvents.ParameterName : Any] = [AppEvents.ParameterName.orderID: productId, AppEvents.ParameterName.currency: "USD"]
        FBSDKCoreKit.AppEvents.shared.logEvent(AppEvents.Name.subscribe, valueToSum: 1.0, parameters: params)
    }
}
