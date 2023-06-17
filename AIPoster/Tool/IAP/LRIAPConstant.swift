//
//  LRIAPConstant.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/13.
//

import UIKit

// MARK: IAP内购Key
/// 周(无使用)Key
let AppleWeekNoTrialIdentifier: String = "mtsmartcleanweek_notrial"
/// 周(有试用)Key
let AppleWeekTrialIdentifier: String = "mtsmartcleanweek"
/// 年(无试用)Key
let AppleYearNoTrialIdentifier: String = "mtsmartcleanyear"
/// 年(有试用)Key
let AppleYearTrialIdentifier: String = ""
/// 订阅密钥
let AppleSubscribeSecretKey: String =
    "a5d6c34d65c1403481345cd8356ba53e"
/// 默认周价格
let DefaultAppleWeekPrice: String = "$4.99"
/// 默认年价格
let DefaultAppleYearPrice: String = "$39.99"
/// 默认试用的时间
let DefaultAppleTrialTime: String = "3 days"

// MARK: AF 统计使用
let APPStoreAPPID: String = "6446270462"
let APP_DEV_KEY: String = "UoPPPj9u5i6dvvJerZ5ueR"

/*
 ---------------- 每次移植新工程使用或者修改包名,以下AF统计字段、接口名必须按照接口文档重新修改, 解密Secret 找 建新 要 --------------
 ---------------- 接口文档地址: http://m.goodluck888.pro/selectpkgrandlj.php?sub=1&pkg=(工程bundleID) --------------
 */
/// AF统计接口
let AppsFlyerURL: String =             "http://www.conhor.pro/tooth/storagecleaner/smartclean"
/// 解密值
let kSecretKey: String =               "7hnd28nsa7dm3x7b"
/*
 ---------------- 以下是AF统计接口需要上传的子段 --------------
 */
let af_pkg: String = "droop"
let af_appsflyer_id: String = "token"
let af_original_transaction_id: String = "confinement"
let af_is_trial: String = "discernible"
let af_purchase_price: String = "liaison"
let af_purchase_currency: String = "poise"
let af_device_id_address: String = "disturb"
let af_purchase_order_id: String = "maniacal"
let af_product_name: String = "whip"
let af_product_id: String = "license"
let af_purchase_quantity: String = "coordination"
let af_purchase_type: String = "student"
let af_idfa: String = "industriousness"
let af_att: String = "att"
let af_app_id: String = "tourniquet"

/// 内购订阅信息
struct IAPPurchaseInfo: Codable {
    /// 产品ID
    var productId: String?
    /// 过期时间
    var expireDate: Date?
    /// 订阅是否过期
    var subcributeIsExpire: Bool = true
    /// 指示订阅项目当前是否在给定的试用期内
    var isTrialPeriod: Bool = false
    /// 指示订阅项目当前是否在介绍优惠期内
    var isInIntroOfferPeriod: Bool = false
}
