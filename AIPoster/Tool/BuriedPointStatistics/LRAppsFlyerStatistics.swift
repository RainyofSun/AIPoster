//
//  LRAppsFlyerStatistics.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/9/22.
//
/*
 接入文档: https://dev.appsflyer.com/hc/docs/in-app-events-ios
 */
import UIKit
import AppsFlyerLib
import StoreKit
import SwiftyStoreKit

class LRAppsFlyerStatistics: NSObject {
    
    private let af_receipt_data: String = "receipt-data"
    private let af_password: String = "password"
    private let af_grace_period: String = "grace_period"
    
    public static let shared = LRAppsFlyerStatistics()
    override init() {
        super.init()
        appsFlyerConfigure()
    }
    
    /// 获取AppsFlyer UID
    public func getAppsFlyerUID() -> String {
        return AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    /// 前后台切换激活app
    public func activeApp() {
        AppsFlyerLib.shared().start { (dictionary, error) in
            guard error == nil else {
                Log.debug("AppsFlyer 激活失败 ===== \(error?.localizedDescription ?? "没有原因")")
                return
            }
            Log.debug("AppsFlyer 激活成功 ============= \(dictionary ?? [:])")
        }
    }
    
    /// 延迟等待ATT授权 适配iOS 14.0+
    public func waitForATTUserAuthorization() {
        if #available(iOS 14, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        }
    }
    
    /// 统计远程推送
    public func handlePushNotification(pushPayload : Dictionary<AnyHashable, Any>) {
        AppsFlyerLib.shared().handlePushNotification(pushPayload)
    }
    
    /// 统计 通过 URL 点击进入app
    public func handleOpenUrl(_ url: URL?, options: [UIApplication.OpenURLOptionsKey : Any]) {
        AppsFlyerLib.shared().handleOpen(url, options: options)
    }
    /// 统计 通过 URL 点击进入app iOS 8 以下
    public func handleOpenUrl(_ url: URL, sourceApplication: String?, annotation: Any) {
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
    }
    /// 统计 Univerasal Links 点击进入app
    public func openUniverasalLinks(userActivity: NSUserActivity?) {
        AppsFlyerLib.shared().continue(userActivity)
    }
    
    /// IAP 购买成功之后统计
    /// 调用该方法 回调代理 - AppsFlyerTrackerDelegate
    public func trackEventStartTrial(product: SKProduct?) {
        guard let _p = product else {
            return
        }
        let trackEvent: String = String(format: "%@_%@", AFEventStartTrial,_p.productIdentifier)
        AppsFlyerLib.shared().logEvent(trackEvent, withValues: [AFEventParamPrice: NSNumber.init(value: _p.price.doubleValue),AFEventParamCurrency:_p.priceLocale.currency?.identifier ?? ""])
        Log.debug("AF 上传IAP 内购信息 ---------------- \(trackEvent)")
    }
    
    /// IAP订单验证成功之后统计产品信息
    public func updateOriginalTransactionIdWithObject(_ productReceipt: ReceiptItem?, product: SKProduct?, receipt: String, productIdentifier: String) {
        guard let _receipt = productReceipt else {
            return
        }
        var _p: SKProduct = SKProduct.init()
        if product == nil {
            if product == nil {
                if productIdentifier == AppleWeekTrialIdentifier || productIdentifier == AppleWeekNoTrialIdentifier {
                    _p = productWithIdentifier(productIdentifier, title: "", price: DefaultAppleWeekPrice)
                } else if productIdentifier == AppleYearNoTrialIdentifier {
                    _p = productWithIdentifier(productIdentifier, title: "", price: DefaultAppleYearPrice)
                } else {
                    _p = productWithIdentifier(productIdentifier, title: "", price: DefaultAppleWeekPrice)
                }
            } else {
                _p = product!
            }
        } else {
            _p = product!
        }
        
        let idfaParams: [String: String] = LRDeviceTool.getIDFA()
        var appFlyerParams: [String: Any] = [:]
        // 包名
        if let _bundleID = Bundle.main.bundleIdentifier {
            appFlyerParams[af_pkg] = _bundleID
        }
        // appFlyerId
        appFlyerParams[af_appsflyer_id] = getAppsFlyerUID()
        // 原始订单
        appFlyerParams[af_original_transaction_id] = _receipt.originalTransactionId
        // 是否试用
        appFlyerParams[af_is_trial] = _receipt.isTrialPeriod ? "true" : "false"
        // apple 价格
        appFlyerParams[af_purchase_price] = _p.price.stringValue
        // 货币单位
        appFlyerParams[af_purchase_currency] = _p.priceLocale.currency?.identifier ?? ""
        // 设备ID地址
        appFlyerParams[af_device_id_address] = LRDeviceTool.getOperatorsIP() ?? ""
        // 购买订单ID
        appFlyerParams[af_purchase_order_id] = _receipt.transactionId
        // 产品名字
        appFlyerParams[af_product_name] = _p.localizedTitle
        // 产品ID
        appFlyerParams[af_product_id] = _p.productIdentifier
        // 产品数量
        appFlyerParams[af_purchase_quantity] = _receipt.quantity
        // 购买类型
        appFlyerParams[af_purchase_type] = "auto renewal"
        // IDFA
        appFlyerParams[af_idfa] = idfaParams["idfa"]
        // att
        appFlyerParams[af_att] = idfaParams["trackingStatus"]
        // APPID
        appFlyerParams[af_app_id] = APPStoreAPPID
        // 支付Key
        appFlyerParams[af_password] = AppleSubscribeSecretKey
        // 订阅标识
        appFlyerParams[af_grace_period] = productIdentifier == AppleYearNoTrialIdentifier ? "28" : "6"
        Log.debug("appsflyer 上传数据:\n \(appFlyerParams)")
        // 购买凭证
        appFlyerParams[af_receipt_data] = receipt
        
        if !JSONSerialization.isValidJSONObject(appFlyerParams) {
            return
        }
        guard let _jsonData = try? JSONSerialization.data(withJSONObject: appFlyerParams, options: .prettyPrinted) else {
            return
        }
        guard let url: URL = URL(string: AppsFlyerURL) else {
            return
        }
        let request: NSMutableURLRequest = NSMutableURLRequest.init(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.httpBody = _jsonData
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                return
            }
            guard let _data = data else {
                return
            }
            guard let _contents: String = String.init(data: _data, encoding: String.Encoding.utf8) else {
                return
            }
            guard let _contentData: String = _contents.aesDecryptForIAP(key: kSecretKey) else {
                return
            }
            Log.debug("----------- appsflyer 上传数据成功 \nurl = \(url) \n result = \(_contentData) \n 参数: \(appFlyerParams) \n ---------")
        }.resume()
    }
    
    // MARK: 自定义事件统计
    /// 自定义事件统计
    public func customEventStatistics(_ event: StatisticsEvent, values: Dictionary<String, Any>? = nil) {
        var contents: Dictionary<String,Any>?
        if let _value = values {
            contents = _value
            contents![AFEventParamContent] = event.note
        } else {
            contents = Dictionary<String,Any>.init()
            contents![AFEventParamContent] = event.note
        }
        AppsFlyerLib.shared().logEvent(event.key, withValues: contents)
    }
}

extension LRAppsFlyerStatistics {
    /// 统计配置
    private func appsFlyerConfigure() {
        AppsFlyerLib.shared().appsFlyerDevKey = APP_DEV_KEY
        AppsFlyerLib.shared().appleAppID = APPStoreAPPID
        AppsFlyerLib.shared().delegate = self
        self.waitForATTUserAuthorization()
    }
    
    /// 根据ID、商品名、价格创建商品
    private func productWithIdentifier(_ identifier: String, title: String, price: String) -> SKProduct {
        let product: SKProduct = SKProduct.init()
        let local: Locale = Locale.init(identifier: "us_US")
        let priceNum: NSDecimalNumber = NSDecimalNumber.init(string: price, locale: local)
        product.setValue(priceNum, forKey: "price")
        product.setValue(local, forKey: "priceLocale")
        product.setValue(identifier, forKey: "productIdentifier")
        product.setValue(title, forKey: "localizedTitle")
        return product
    }
}

extension LRAppsFlyerStatistics: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("onConversionDataSuccess data:")
        for (key, value) in conversionInfo {
            print(key, ":", value)
        }
        if let conversionData = conversionInfo as NSDictionary? as! [String:Any]? {
            
            if let status = conversionData["af_status"] as? String {
                if (status == "Non-organic") {
                    if let sourceID = conversionData["media_source"],
                       let campaign = conversionData["campaign"] {
                        print("[AFSDK] This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                    }
                } else {
                    print("[AFSDK] This is an organic install.")
                }
                
                if let is_first_launch = conversionData["is_first_launch"] as? Bool,
                   is_first_launch {
                    print("[AFSDK] First Launch")
                } else {
                    print("[AFSDK] Not First Launch")
                }
            }
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        Log.error(error.localizedDescription)
    }
}

