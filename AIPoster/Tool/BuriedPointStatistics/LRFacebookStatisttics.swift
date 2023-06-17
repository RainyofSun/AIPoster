//
//  LRFacebookStatisttics.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/9/22.
//

import UIKit
import FBSDKCoreKit

class LRFacebookStatisttics: NSObject {

    public static let shared = LRFacebookStatisttics()
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
    public func iapPurchaseInfo() {
        FBSDKCoreKit.AppEvents.shared.logPurchase(amount: 1.0, currency: "USD")
    }
}
