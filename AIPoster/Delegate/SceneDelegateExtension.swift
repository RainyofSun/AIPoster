//
//  SceneDelegateExtension.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/14.
//

import UIKit
import SwiftyStoreKit

// MARK: Notification
@objc extension SceneDelegate {
    // 订阅成功通知 ---> 发送AF订阅事件
    func statisticsUserSubscribe(notification: Notification) {
//        guard let receiptItem = notification.object as? ReceiptItem else {
//            return
//        }
//        // 统计商品信息
//        // Facebook 统计
//        LRFacebookStatistics.shared.iapPurchaseInfo(receiptItem.productId)
//        // AFIAP内购统计
//        LRAppsFlyerStatistics.shared.trackEventStartTrial(product: LRIAPStoreManager.shared.product)
//        // 获取购买凭证
//        LRIAPStoreManager.shared.fetchProductReceipt { (receipt: String?) in
//            guard let _receipt = receipt else {
//                return
//            }
//            LRAppsFlyerStatistics.shared.updateOriginalTransactionIdWithObject(receiptItem, product: LRIAPStoreManager.shared.product, receipt: _receipt, productIdentifier: receiptItem.productId)
//        }
    }
}

// MARK: Notification
@objc extension AppDelegate {
    // 激活统计
    func activeAF() {
//        // 激活facebook
//        LRFacebookStatistics.shared.activeApp()
//        // 激活AppsFlyer
//        LRAppsFlyerStatistics.shared.activeApp()
    }
}
