//
//  LRGoogleInterstitialADManager.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/3/26.
//

import UIKit
import GoogleMobileAds

class LRGoogleInterstitialADManager: NSObject {
    // 展示插屏的策略
    enum AdDisplayStrategy {
        // 频率限制
        case Frequency
        // 时间限制
        case Time
    }
    // 代理
    weak open var adDelegate: HSADFullScreenContentDelegate?
    // 展示插屏的策略 默认是根据次数限制
    open var interstitialStrategy: AdDisplayStrategy = .Frequency
    // 插屏缓存
    private var InsertADCache: [GoogleADType: GAMInterstitialAd] = [GoogleADType: GAMInterstitialAd]()
    // 当前是否正在缓存广告
    private var _cacheADStatus: [GoogleADType: Bool] = [:]
    // 是否触发了重试机制
    private var trigger_retry_mechanism: [GoogleADType: Bool] = [:]
    // 插屏广告ADKeys
    private let INTERTITIAL_AD_KEYS: [GoogleADType] = [GoogleADType.GoogleInterstitialAD1, GoogleADType.GoogleInterstitialAD2, GoogleADType.GoogleInterstitialAD3]
    // 插屏最大限制次数
    private let AD_MAX_LIMIT: Int = 3
    // 插屏最大时间间隔
    private let AD_MAX_TIME_INTERVAL: CGFloat = 30
    // 插屏缓存时间间隔
    private var AD_CACHE_TIME_INTERVAL: CGFloat = .zero
    // 是否强制展示插屏
    private var _force_show_AD: Bool = false
    // 是否延迟代理回调
    private var _delay_callback: Bool = false
    // 手动延迟回调时间
    private let _delay_callback_time: TimeInterval = 0.5
    
    public static let shared = LRGoogleInterstitialADManager()
    override init() {
        super.init()
        self.AD_CACHE_TIME_INTERVAL = AD_MAX_TIME_INTERVAL - 10
        resetInterstitialRecording()
        cacheADAgain()
    }
    
    // MARK: Public Methods
    public func cacheADAgain() {
        // 缓存一个插屏广告作为备用
        if InsertADCache[GoogleADType.GoogleInterstitialAD1] == nil && LRIAPStoreManager.shared.localVerificationSubscriptionExpirationTime() {
            cacheInsertAD(adType: GoogleADType.GoogleInterstitialAD1)
            Log.debug("VIP过期情况下,启动时先缓存一个插屏 \(GoogleADType.GoogleInterstitialAD1) 作为备用")
        }
    }
    
    /// 展示插屏页广告
    /// forceShow 为True 将无视限制次数,插屏广告若缓存必会立即进行展示
    /// clear 为True 重置记录次数
    /// delayCallback 在插屏广告已缓存的前提下,是否延迟到插屏广告关闭才给代理回调
    func showInsertAD(vc: UIViewController, adType: GoogleADType, ADForceDisplay forceShow: Bool = false, clearRecords clear: Bool = false, whenCloseCallback delayCallback: Bool = false) {
        // 如果付费，则不展示广告
        if LRIAPStoreManager.shared.localVerificationSubscriptionExpirationTime() == false {
            if delayCallback {
                delay(_delay_callback_time) {
                    // 条件不满足,直接回调外部操作
                    self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                }
            } else {
                // 条件不满足,直接回调外部操作
                self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
            }
            return
        }
        
        // 查看是否达到广告展示的条件
        if self.interstitialStrategy == .Frequency {
            if !canShowshowInterstitialADByFrequency(adType: adType, ADForceDisplay: forceShow, clearRecords: clear) {
                Log.debug("未达到展示插屏的条件 ------------ 直接返回外部调用 -------")
                if delayCallback {
                    delay(_delay_callback_time) {
                        // 条件不满足,直接回调外部操作
                        self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                    }
                } else {
                    // 条件不满足,直接回调外部操作
                    self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                }
                return
            }
        }
        
        if self.interstitialStrategy == .Time {
            if !canShowshowInterstitialADByTime(adType: adType, ADForceDisplay: forceShow, clearRecords: clear) {
                Log.debug("未达到展示插屏的条件 ------------ 直接返回外部调用 -------")
                if delayCallback {
                    delay(_delay_callback_time) {
                        // 条件不满足,直接回调外部操作
                        self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                    }
                } else {
                    // 条件不满足,直接回调外部操作
                    self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                }
                return
            }
        }
        
        self._force_show_AD = forceShow
        self._delay_callback = delayCallback
        
        // Log.debug("当前插屏广告缓存 === \(InsertADCache)")
        // 查看缓存中是否已经缓存了对应类型的广告
        if let _cacheADForADType = InsertADCache[adType] {
            // 缓存中有对应类型的广告,直接展示
            showInterstitialAD(vc, ad: (adType, _cacheADForADType))
            Log.debug("缓存中已缓存对应类型 \(adType) 的广告,直接展示插屏广告 --------------")
        } else {
            // 查找缓存中是否有其他Key的广告缓存
            let _tempKeys: [GoogleADType] = INTERTITIAL_AD_KEYS.filter({$0 != adType})
            var _tempGoogleAD: GADInterstitialAd?
            var _tempADType: GoogleADType?
            for key in _tempKeys {
                if let _tempAD = InsertADCache[key] {
                    _tempGoogleAD = _tempAD
                    _tempADType = key
                    break
                }
            }
            if let _temp = _tempGoogleAD, let _t = _tempADType {
                // 找到了其他类型 Key 广告缓存,直接展示
                showInterstitialAD(vc, ad: (_t, _temp))
                Log.debug("缓存中没有缓存对应类型 \(adType) 的广告, 但是找到了其他类型 \(_t) 的缓存广告, 直接展示 --------------")
            }
            
            // 查看当前类型的广告是否处于缓存中
            if self._cacheADStatus[adType] ?? false {
                Log.debug("缓存中没有缓存对应类型 \(adType) 的广告, 但是当前类型 \(adType) 的广告正在缓存中  --------------")
            } else {
                Log.debug("缓存中没有缓存对应类型 \(adType) 的广告, 当前类型 \(adType) 的广告也没有处于缓存中, 重新开始缓存当前类型\(adType)的广告  返回外部回调 --------------")
                // 当前广告类型没有缓存,开始缓存,并直接返回外部回调
                self.cacheInsertAD(adType: adType)
            }
        }
        
        if delayCallback {
            Log.debug("延迟回调至插屏广告关闭 -------------")
            // 特殊情况: 当需要延迟时,如果当时没有广告缓存,手动延迟1秒进行回调
            if InsertADCache.isEmpty {
                Log.debug("手动延迟回调至插屏广告关闭 -------------")
                delay(_delay_callback_time) {
                    self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                }
            }
            // 特殊情况: 如果当前类型的广告缓存中未存在,且处于正在缓存的状态,且外界指定延迟回调,此时手动延迟1秒回调
            if InsertADCache[adType] == nil && (_cacheADStatus[adType] ?? false) {
                Log.debug("当前插屏广告正在缓存中,手动延迟回调至插屏广告关闭 -------------")
                delay(_delay_callback_time) {
                    self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                }
            }
        } else {
            // 条件满足,展示广告同时回调外部操作
            self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
        }
    }
}

// MARK: Private Methods
private extension LRGoogleInterstitialADManager {
    // 缓存插屏
    func cacheInsertAD(adType: GoogleADType) {
        if trigger_retry_mechanism[adType] ?? false {
            Log.debug("当前插屏广告 \(adType) 触发了重试机制 ----- 不再重新发送广告缓存请求")
            return
        }
        // 标志位 --- 当前广告类型是否正在缓存
        self._cacheADStatus[adType] = true
        GAMInterstitialAd.load(withAdManagerAdUnitID: adType.ADKEY(), request: GAMRequest()) { (ad: GAMInterstitialAd?, err: Error?) in
            // 标志位 --- 当前广告类型是否正在缓存
            self._cacheADStatus[adType] = false
            guard err == nil else {
                Log.debug("插屏广告 \(adType) 缓存失败 --- \(err?.localizedDescription ?? ""), 延迟重新缓存 ----------")
                // 触发超时请求机制
                self.trigger_retry_mechanism[adType] = true
                delay(ADInterstitialRequestDelayTime) {
                    self.cacheInsertAD(adType: adType)
                }
                return
            }
            // 重置超时重试标志位
            self.trigger_retry_mechanism[adType] = false
            Log.debug("缓存插屏广告成功 ------------- \(adType)")
            self.InsertADCache[adType] = ad!
            ad?.fullScreenContentDelegate = self
        }
    }
    
    // 判断是否达到了展示插屏的条件 --- 频率
    func canShowshowInterstitialADByFrequency(adType: GoogleADType, ADForceDisplay forceShow: Bool = false, clearRecords clear: Bool = false) -> Bool {
        var _showAD: Bool = false
        if forceShow {
            // 强制展示插屏,无视次数限制
            Log.debug("强制展示插屏广告 ==== \(adType)")
            if clear {
                // 重置次数记录
                LRUserDefaultADCache.resetSwitchPageCount()
            }
            _showAD = true
        } else {
            var switchCount = LRUserDefaultADCache.getSwitchPageCount()
            switchCount += 1
            if switchCount >= AD_MAX_LIMIT {
                // 广告已缓存且符合展示规则
                // Log.debug("展示插屏广告 ==== \(adType)")
                // 重置次数记录
                LRUserDefaultADCache.resetSwitchPageCount()
                _showAD = true
            } else {
                // 存储页面切换的次数
                LRUserDefaultADCache.saveSwitchPageCount(switchCount)
                // 当切换次数接近临界值时缓存下一个插屏广告
                if switchCount == (AD_MAX_LIMIT - 1) && InsertADCache[adType] == nil {
                    // 重新缓存当前类型的广告
                    self.cacheInsertAD(adType: adType)
                    // Log.debug("广告展示次数达到临界值, 并且缓存中没有 \(adType) 类型广告, 开始缓存 \(adType) 类型广告")
                }
            }
        }
        
        return _showAD
    }
    
    // 判断是否达到了展示插屏的条件 --- 时间
    func canShowshowInterstitialADByTime(adType: GoogleADType, ADForceDisplay forceShow: Bool = false, clearRecords clear: Bool = false) -> Bool {
        var _showAD: Bool = false
        if forceShow {
            // 强制展示插屏,无视次数限制
            Log.debug("强制展示插屏广告 ==== \(adType)")
            if clear {
                // 重置次数记录
                LRUserDefaultADCache.resetShowInterstitialTime()
            }
            _showAD = true
        } else {
            let currentTimestamp = Date().timeIntervalSince1970
            guard let switchTimestamp = LRUserDefaultADCache.showInterstitialADTime() else {
                // 没有缓存时间,立即展示
                LRUserDefaultADCache.saveShowInterstitialTime(currentTimestamp)
                return true
            }
            
            if (currentTimestamp - switchTimestamp) >= AD_MAX_TIME_INTERVAL {
                // 广告已缓存且符合展示规则
                Log.debug("展示插屏广告 ==== \(adType)")
                // 重置展示时间
                LRUserDefaultADCache.resetShowInterstitialTime()
                _showAD = true
            } else {
                // 当切换次数接近临界值时缓存下一个插屏广告
                if (currentTimestamp - switchTimestamp) >= AD_CACHE_TIME_INTERVAL && InsertADCache[adType] == nil {
                    // 重新缓存当前类型的广告
                    self.cacheInsertAD(adType: adType)
                    // Log.debug("广告展示次数达到临界值, 并且缓存中没有 \(adType) 类型广告, 开始缓存 \(adType) 类型广告")
                }
            }
        }
        
        return _showAD
    }
    
    // 展示插屏
    func showInterstitialAD(_ rootController: UIViewController, ad: (adType: GoogleADType, gooleAD: GADInterstitialAd?)) {
        do {
            if let _ = try ad.gooleAD?.canPresent(fromRootViewController: rootController) {
                ad.gooleAD?.present(fromRootViewController: rootController)
            }
        } catch {
            // 条件不满足,直接回调外部操作
            self.adDelegate?.hs_adDidDismissFullScreenContent(adType: ad.adType)
        }
    }
    
    // 重置插屏记录
    func resetInterstitialRecording() {
        if self.interstitialStrategy == .Frequency {
            // 重置本地广告展示次数至最接近展示的次数
            LRUserDefaultADCache.saveSwitchPageCount((AD_MAX_LIMIT - 1))
        }
        
        if self.interstitialStrategy == .Time {
            // 重置本地广告展示时间
            LRUserDefaultADCache.resetShowInterstitialTime()
        }
    }
}

extension LRGoogleInterstitialADManager: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        // Log.debug("弹出插屏广告失败 --- \(error.localizedDescription), 重新缓存插屏广告 ------------")
        adDidDismissFullScreenContent(ad)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        var adType: GoogleADType = .GoogleInterstitialAD1
        InsertADCache.forEach { (key: GoogleADType, value: GAMInterstitialAd) in
            if value.sg_equateableAnyObject(object: ad) {
                adType = key
            }
        }
        // 移除掉广告缓存
        InsertADCache.removeValue(forKey: adType)
        // Log.debug("插屏广告 \(adType) 关闭并移除缓存 \(adType)---------------")
        if self._force_show_AD {
            self.cacheInsertAD(adType: adType)
            self._force_show_AD = false
            Log.debug("强制展示插屏广告 \(adType) 关闭并移除缓存 \(adType) 重新缓存 \(adType) 广告---------------")
        }
        
        if self._delay_callback {
            // 条件满足,展示广告同时回调外部操作
            self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
            self._delay_callback = false
        }
    }
}
