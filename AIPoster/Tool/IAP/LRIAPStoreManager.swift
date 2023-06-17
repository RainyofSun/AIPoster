//
//  LRIAPStoreManager.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/8/17.
//
/*
 马涛账号内购沙盒测试账号：
 1.账号：taoma198874q@2980.com
 密码：Mt696haox
 2.账号：matao20110907dp@2980.com
 密码：M96tb0907da
 */
import UIKit
import SwiftyStoreKit
import StoreKit

/*
 21000: 未使用HTTP POST请求方法向App Store发送请求。
 21001: 此状态代码不再由App Store发送。
 21002: receipt-data属性中的数据格式错误，或者服务遇到了临时问题。再试一次。
 21003: 收据无法认证。
 21004: 您提供的共享密钥与您帐户的文件共享密钥不匹配。
 21005: 收据服务器暂时无法提供收据。再试一次。
 21006：该收据有效，但订阅已过期。当此状态码返回到您的服务器时，收据数据也会被解码并作为响应的一部分返回。仅针对自动续订的iOS 6样式的交易收据返回。
 21007: 该收据来自测试环境，但是已发送到生产环境以进行验证。
 21008：该收据来自生产环境，但是已发送到测试环境以进行验证。
 21009：内部数据访问错误。稍后再试。
 21010: 找不到或删除了该用户帐户
 */

/*
 IAP内购测试:
 测试项目       测试时长
 1 week         3 minutes
 1 month        5 minutes
 2 months       10 minutes
 3 months       15 minutes
 6 months       30 minutes
 1 year         1 hour
 自动续订,沙盒状态下每天最多续订6次
 */
enum IAPPurchaseError: Error {
    case SIAPPurchFailed         // 购买失败
    case SIAPPurchCancle         // 取消购买
    case SIAPPurchVerFailed      // 订单校验失败
    case SIAPRestoreFailed       // 恢复失败
    case SIAPPurchNotArrow       // 不允许内购
    case SIAPNetFaile            // 网络不好
    case badStatusCode(_ code: Int, _ msg: String)
}

protocol HSIAPStoreProtocol: AnyObject {
    /// IAP 购买开始
    func hs_iapPurchaseStart()
    /// IAP 购买验证成功的回调
    func hs_iapVerifyReceiptSuccess(receiptItem: ReceiptItem)
    /// IAP 购买失败
    func hs_iapPurchaseFailture(error: IAPPurchaseError)
    /// IAP 恢复购买成功回调
    func hs_iapRestoreSuccess(product: Purchase)
    /// IAP 恢复购买失败
    func hs_iapRestoreFaile(error: IAPPurchaseError)
    /// IAP 恢复订阅-开始
    func hs_iapRestoreStart()
    /// IAP 恢复订阅-结束
    func hs_iapRestoreEnd()

}

// MARK: 单例 --> 内购购买
class LRIAPStoreManager: NSObject {
    
    /// 定义代理回调
    weak open var iapDelegate: HSIAPStoreProtocol?
    /// 订阅成功通知 -> 携带信息 ReceiptItem 实例
    public let IAPSubscribeSuccessNotification = Notification.Name("com.translation.iapPurchaseSuccess")
    /// 恢复购买通知
    public let IAPSubscribeRestoreNotification = Notification.Name("com.translation.iapRestoreSuccess")
    
    /// 当前购买的商品
    private(set) var product: SKProduct?
    
    //单例
    static let shared = LRIAPStoreManager()
    private override init() {}
    
    // 试用ID
    let kAppTrialProductID = ""
    // 商品ID
    private var kAppProductID = ""
    
    /// 开启IAP订阅回调
    public func addIAPPurchaseObserver() {
        SwiftyStoreKit.completeTransactions(atomically: false) { (purchases) in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased,.restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed,.purchasing,.deferred:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    /// 检索IAP商品信息
    /// return: 检索到商品、失效的商品ID
    public func retrieveProductsInformation(productIds: Set<String>, complete: @escaping ((Set<SKProduct>, Set<String>) -> Void)) {
        if productIds.isEmpty {
            return
        }
        // 异步检索
        DispatchQueue.init(label: "iap.product.queue").async {
            SwiftyStoreKit.retrieveProductsInfo(productIds) { (products: RetrieveResults) in
                exchangeMainQueue {
                    complete(products.retrievedProducts,products.invalidProductIDs)
                }
            }
        }
    }
    
    /// 获取商品购买凭据
    public func fetchProductReceipt(complete:@escaping ((String?) -> ())) {
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { (result: FetchReceiptResult) in
            switch result {
            case .success(let receiptData):
                let receiptStr: String = receiptData.base64EncodedString(options: [])
                complete(receiptStr)
            case .error(let error):
                Log.error("获取购买凭证失败 \(error)")
                complete(nil)
            }
        }
    }
    
    /// 判断IAP订阅是否过期 --> 返回 即将过期天数: -1 已经过期, -2 用户没有购买, -3 凭证验证失败, =0 当天即将过期, >0 即将过期天数
    public func IAPSubscribeIsExpired(productID: Set<String> = [AppleWeekTrialIdentifier,AppleWeekNoTrialIdentifier,AppleYearNoTrialIdentifier] ,_ complete: ((Int) -> ())? = nil) {
        var type: AppleReceiptValidator.VerifyReceiptURLType = AppleReceiptValidator.VerifyReceiptURLType.production
        #if DEBUG
        type = AppleReceiptValidator.VerifyReceiptURLType.sandbox
        #endif
        
        let appleValidator = AppleReceiptValidator(service: type, sharedSecret: AppleSubscribeSecretKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(ofType: .autoRenewable, productIds: productID, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    // 按照时间顺序倒序排列订单 --> Apple返回的订单列表可能是乱序排列的
                    let tempSource: [ReceiptItem] = items.sorted { m1, m2 in
                        m1.purchaseDate >= m2.purchaseDate
                    }
                    if let receiptItem = tempSource.first {
                        var expiredDays: Int = 0
                        // 存储IAP购买信息
                        if let _expireDate = receiptItem.subscriptionExpirationDate {
                            var hasExpired: Bool = false
                            if  _expireDate.isToday() {
                                // 今天过期
                                // 过期时间(小时)小于当前时间(小时)
                                if _expireDate.lt(Date(), granularity: Calendar.Component.hour) {
                                    // 已经过期了
                                    hasExpired = true
                                } else if _expireDate.eq(Date(), granularity: Calendar.Component.hour) {
                                    // 过期时间(分钟)小于等于当前时间(分钟)
                                    if _expireDate.le(Date(), granularity: Calendar.Component.minute) {
                                        hasExpired = true
                                    } else if _expireDate.eq(Date(), granularity: Calendar.Component.minute) {
                                        // 过期时间(秒)小于等于当前时间(秒)
                                        if _expireDate.le(Date(), granularity: Calendar.Component.second) {
                                            hasExpired = true
                                        }
                                    }
                                }
                            } else {
                                // 还剩余天数
                                let calendar = Calendar.current
                                let components: DateComponents = calendar.dateComponents([.day], from: Date(), to: _expireDate)
                                expiredDays = components.day ?? .zero
                            }
                            LRIAPCache.saveIAPPurchase(iapInfo: IAPPurchaseInfo.init(productId: receiptItem.productId, expireDate: receiptItem.subscriptionExpirationDate, subcributeIsExpire: hasExpired, isTrialPeriod: receiptItem.isTrialPeriod, isInIntroOfferPeriod: receiptItem.isInIntroOfferPeriod))
                            complete?(expiredDays)
                        }
                        Log.debug("+++++ Apple 拉取订单信息校验订阅过期时间 \n\n\(self.kAppProductID) is valid until \(expiryDate)\n\n nowDate: \(Date()) \n +++++++ 未过期 剩余天数 ===== \(expiredDays)")
                    }
                case .expired(let expiryDate, let items):
                    Log.debug("+++++ Apple 拉取订单信息校验订阅过期时间 \n\n\(self.kAppProductID) is expired since \(expiryDate)\n\n nowDate: \(Date()) \n ++++++ 已过期")
                    // 按照时间顺序倒序排列订单 --> Apple返回的订单列表可能是乱序排列的
                    let tempSource: [ReceiptItem] = items.sorted { m1, m2 in
                        m1.purchaseDate >= m2.purchaseDate
                    }
                    if let receiptItem = tempSource.first {
                        // 存储IAP购买信息
                        LRIAPCache.saveIAPPurchase(iapInfo: IAPPurchaseInfo.init(productId: receiptItem.productId, expireDate: receiptItem.subscriptionExpirationDate, subcributeIsExpire: true, isTrialPeriod: receiptItem.isTrialPeriod, isInIntroOfferPeriod: receiptItem.isInIntroOfferPeriod))
                        complete?(-1)
                    }
                case .notPurchased:
                    complete?(-2)
                    Log.error("The user has never purchased \(self.kAppProductID)")
                }
            case .error(let error):
                complete?(-3)
                Log.error("Receipt verification failed: \(error)")
            }
        }
    }
    
    /// 本地校验订阅过期时间
    public func localVerificationSubscriptionExpirationTime() -> Bool {
        /// 判断DEBUG环境下是否不检验VIP过期时间
        if LRDebugSettingCache.verifyVIPTimeConfig() {
            return false
        }
        var hasExpired: Bool = true
        if var iapInfo = LRIAPCache.getIAPPurchase(), let _expireDate = iapInfo.expireDate {
            if  _expireDate.eq(Date(), granularity: Calendar.Component.day) {
                // 过期时间(小时)大于当前时间(小时)
                if _expireDate.gt(Date(), granularity: Calendar.Component.hour) {
                    // 未过期
                    hasExpired = false
                } else if _expireDate.eq(Date(), granularity: Calendar.Component.hour) {
                    // 过期时间(分钟)大于当前时间(分钟)
                    if _expireDate.gt(Date(), granularity: Calendar.Component.minute) {
                        hasExpired = false
                    } else if _expireDate.eq(Date(), granularity: Calendar.Component.minute) {
                        // 过期时间(秒)大于当前时间(秒)
                        if _expireDate.gt(Date(), granularity: Calendar.Component.second) {
                            hasExpired = false
                        }
                    }
                }
            } else if _expireDate.gt(Date(), granularity: Calendar.Component.day) {
                // 过期时间（天）大于当前时间（天）
                hasExpired = false
            } else {}
            if hasExpired {
                Log.debug("+++++ 本地校验订阅到期时间\n\n\(self.kAppProductID) is expired since \(_expireDate)\n\n nowDate: \(Date()) \n +++++++")
            }
            // 更新缓存
            iapInfo.subcributeIsExpire = hasExpired
            LRIAPCache.saveIAPPurchase(iapInfo: iapInfo)
        }
        
        return hasExpired
    }
    
    /// IAP订阅
    public func subscribeTranslateService(productID id: String = "") {
        if !SwiftyStoreKit.canMakePayments {
            self.iapDelegate?.hs_iapPurchaseFailture(error: IAPPurchaseError.SIAPPurchNotArrow)
            return
        }
        self.iapDelegate?.hs_iapPurchaseStart()
        kAppProductID = id
        /*
         参数1: productId，在iTunes Connect中指定的productId；
         参数2: quantity，购买数量；
         参数3: atomically，设置为ture，不管商品有没有验证成功，都会调用finishTransaction
         参数4: applicationUsername,系统上用户帐户的不透明标识符。可以传入用户id，这样就能将该订单充到固定账号上
         参数5: simulatesAskToBuyInSandbox，是否是沙盒模拟支付；默认不填为false
         */
        SwiftyStoreKit.purchaseProduct(kAppProductID, atomically: false) { (result: PurchaseResult) in
            switch result {
            case .success(let purchase):
                print("购买信息 \(purchase)")
                self.product = purchase.product
                // 购买成功验证Apple收据
                #if DEBUG
                self.verifyReceipt(service: AppleReceiptValidator.VerifyReceiptURLType.sandbox, transaction: purchase.transaction)
                #else
                self.verifyReceipt(service: AppleReceiptValidator.VerifyReceiptURLType.production, transaction: purchase.transaction)
                #endif
            case .error(let error):
                switch error.code {
                case .unknown:
                    print("Unknown error. Please contact support")
                case .clientInvalid:
                    print("Not allowed to make the payment")
                case .paymentCancelled:
                    break
                case .paymentInvalid:
                    print("The purchase identifier was invalid")
                case .paymentNotAllowed:
                    print("The device is not allowed to make the payment")
                case .storeProductNotAvailable:
                    print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied:
                    print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed:
                    print("Could not connect to the network")
                case .cloudServiceRevoked:
                    print("User has revoked permission to use this cloud service")
                default :
                    print("其他错误")
                }
                self.iapDelegate?.hs_iapPurchaseFailture(error: IAPPurchaseError.badStatusCode(error.code.rawValue, error.localizedDescription))
            }
        }
    }
    
    /// IAP 恢复购买
    public func restoreIAPPurchase() {
        self.iapDelegate?.hs_iapRestoreStart()
        SwiftyStoreKit.restorePurchases(atomically: false) { (result: RestoreResults) in
            if result.restoreFailedPurchases.count > 0 {
                Log.debug("Restore Failed: \(result.restoreFailedPurchases)")
                self.iapDelegate?.hs_iapRestoreFaile(error: IAPPurchaseError.SIAPRestoreFailed)
            } else if result.restoredPurchases.count > 0 {
                // 按照时间顺序倒序排列订单 --> Apple返回的订单列表可能是乱序排列的
                let tempSource: [Purchase] = result.restoredPurchases.sorted { m1, m2 in
                    m1.transaction.transactionDate ?? Date() >= m2.transaction.transactionDate ?? Date()
                }
                for purchase in tempSource {
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
                if let _purchase = tempSource.first {
                    // 验证是否过期
                    self.IAPSubscribeIsExpired(productID: [_purchase.productId]) { (day) in
                        SwiftyStoreKit.finishTransaction(_purchase.transaction)
                        self.iapDelegate?.hs_iapRestoreSuccess(product: _purchase)
                        DispatchQueue.main.async {
                            // 发送恢复订阅成功通知
                            NotificationCenter.default.post(name: self.IAPSubscribeRestoreNotification, object: nil)
                        }
                    }
                }
                Log.debug("Restore Success: \(result.restoredPurchases)")
            } else {
                Log.debug("Nothing to Restore")
                self.iapDelegate?.hs_iapRestoreEnd()
            }
        }
    }
    
    // 本地校验苹果数据
    private func verifyReceipt(service: AppleReceiptValidator.VerifyReceiptURLType, transaction: PaymentTransaction) {
        let appleVaildtor = AppleReceiptValidator.init(service: service, sharedSecret: AppleSubscribeSecretKey)
        SwiftyStoreKit.verifyReceipt(using: appleVaildtor) { (verifyResult: VerifyReceiptResult) in
            switch verifyResult {
            case .success(let receipt):
                // 验证有效期
                let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: SubscriptionType.autoRenewable, productId: self.kAppProductID, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(_, let items):
                    // 按照时间顺序倒序排列订单 --> Apple返回的订单列表可能是乱序排列的
                    let tempSource: [ReceiptItem] = items.sorted { m1, m2 in
                        m1.purchaseDate >= m2.purchaseDate
                    }
                    guard let receiptItem = tempSource.first else {
                        return
                    }
                    Log.debug("++++ 购买成功 \(self.kAppProductID) is purchased: \(receiptItem) +++++")
                    // 存储IAP购买信息
                    LRIAPCache.saveIAPPurchase(iapInfo: IAPPurchaseInfo.init(productId: receiptItem.productId, expireDate: receiptItem.subscriptionExpirationDate, subcributeIsExpire: false, isTrialPeriod: receiptItem.isTrialPeriod, isInIntroOfferPeriod: receiptItem.isInIntroOfferPeriod))
                    self.iapDelegate?.hs_iapVerifyReceiptSuccess(receiptItem: receiptItem)
                    DispatchQueue.main.async {
                        // 发送订阅成功的通知
                        NotificationCenter.default.post(name: self.IAPSubscribeSuccessNotification, object: receiptItem)
                    }
                case .expired(let expiryDate, _):
                    Log.debug("+++++ The product \(self.kAppProductID) is Expired \(expiryDate) +++++")
                    self.iapDelegate?.hs_iapPurchaseFailture(error: IAPPurchaseError.SIAPPurchFailed)
                case .notPurchased:
                    Log.debug("+++++ The user has never purchased \(self.kAppProductID) +++++")
                    self.iapDelegate?.hs_iapPurchaseFailture(error: IAPPurchaseError.SIAPPurchFailed)
                }
            case .error(let error):
                Log.error("++++++ IAP 购买凭证验证失败: \(error) ++++++")
                self.iapDelegate?.hs_iapPurchaseFailture(error: IAPPurchaseError.SIAPPurchVerFailed)
            }
            SwiftyStoreKit.finishTransaction(transaction)
        }
    }
}

extension SKProduct {
    
    @available(iOSApplicationExtension 11.2, iOS 11.2, OSX 10.13.2, tvOS 11.2, watchOS 6.2, macCatalyst 13.0, *)
    var localizedIntroductoryPrice: String {
        guard let _introductoryPrice = self.introductoryPrice else { return "" }
        
        let dateComponents: DateComponents
        
        switch _introductoryPrice.subscriptionPeriod.unit {
        case .day: dateComponents = DateComponents(day: _introductoryPrice.subscriptionPeriod.numberOfUnits)
        case .week: dateComponents = DateComponents(weekOfMonth: _introductoryPrice.subscriptionPeriod.numberOfUnits)
        case .month: dateComponents = DateComponents(month: _introductoryPrice.subscriptionPeriod.numberOfUnits)
        case .year: dateComponents = DateComponents(year: _introductoryPrice.subscriptionPeriod.numberOfUnits)
        @unknown default:
            print("WARNING: SwiftyStoreKit localizedSubscriptionPeriod does not handle all SKProduct.PeriodUnit cases.")
            // Default to month units in the unlikely event a different unit type is added to a future OS version
            dateComponents = DateComponents(month: _introductoryPrice.subscriptionPeriod.numberOfUnits)
        }

        return DateComponentsFormatter.localizedString(from: dateComponents, unitsStyle: .short) ?? ""
    }
    
    /// 年价格换算周价格
    var weekPrice: String? {
        let weakCount = NSDecimalNumber.init(string: "52")
        /*
        NSRoundPlain:四舍五入 NSRoundDown:向下取正 NSRoundUp:向上取正 NSRoundBankers:(特殊的四舍五入，碰到保留位数后一位的数字为5时，根据前一位的奇偶性决定。为偶时向下取正，为奇数时向上取正。如：1.25保留1为小数。5之前是2偶数向下取正1.2；1.35保留1位小数时。5之前为3奇数，向上取正1.4）
        scale:精确到几位小数
        raiseOnExactness:发生精确错误时是否抛出异常，一般为NO
        raiseOnOverflow:发生溢出错误时是否抛出异常，一般为NO
        raiseOnUnderflow:发生不足错误时是否抛出异常，一般为NO
        raiseOnDivideByZero:被0除时是否抛出异常，一般为YES
        */
        let behaviors: NSDecimalNumberBehaviors = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.up, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        let weakPrice = self.price.dividing(by: weakCount, withBehavior: behaviors)
        return priceFormatter(locale: priceLocale).string(from: weakPrice)
    }
    
    private func priceFormatter(locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }
}
