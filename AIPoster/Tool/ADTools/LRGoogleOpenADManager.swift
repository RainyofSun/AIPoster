//
//  LRGoogleOpenADManager.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/3/26.
//

import UIKit
import GoogleMobileAds

class LRGoogleOpenADManager: NSObject {
    
    // 代理
    weak open var adDelegate: HSADFullScreenContentDelegate?
    // 开屏缓存
    private var openADCache: [GoogleADType: GADAppOpenAd] = [GoogleADType:GADAppOpenAd]()
    // 开屏广告加载时间
    private var ADloadTime : Date?
    // 是否缓存开屏失败
    private var _cacheADFail: [GoogleADType: Bool] = [:]
    // 当前是否正在缓存广告
    private var _cacheADStatus: [GoogleADType: Bool] = [:]
    // 是否触发了重试机制
    private var trigger_retry_mechanism: [GoogleADType: Bool] = [:]
    // 开屏广告ADKeys
    private let OPEN_AD_KEYS: [GoogleADType] = [GoogleADType.GoogleOpenAD1, GoogleADType.GoogleOpenAD2]
    // 冷启动开屏广告最大等待时长
    private var MAX_TIME_COLD_START_SPLASH_AD: Int = 5
    
    public static let shared = LRGoogleOpenADManager()
    override init() {
        super.init()
        cacheAppOpenAd(adType: GoogleADType.GoogleOpenAD1)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground(notification: )), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    // MARK: Public Methods
    public func cacheADAgain() {
        // 不再重新缓存冷启动开屏,仅重新缓存热启动开屏
        if openADCache[GoogleADType.GoogleOpenAD2] == nil {
            cacheAppOpenAd(adType: GoogleADType.GoogleOpenAD2)
        }
    }
    
    /// 展示开屏
    func tryToPresentAd(adType: GoogleADType) {
        Log.debug("尝试展开开屏广告 -------------------")
        // 如果付费，则不展示广告
        if LRIAPStoreManager.shared.localVerificationSubscriptionExpirationTime() == false {
            // 条件不满足,直接回调外部操作
            self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
            return
        }
        
        // 根控制器是否不为空
        guard let rootController = getCleanHostWindow().rootViewController else {
            // 条件不满足,直接回调外部操作
            self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
            return
        }
        
        Log.debug("当前开屏广告缓存 === \(openADCache)")
        // 查看缓存中是否已经缓存了对应类型的广告
        if let _cacheADForADType = openADCache[adType] {
            // 缓存中有对应类型的广告,直接展示
            showOpenAD(rootController, ad: (adType,_cacheADForADType))
            Log.debug("缓存中已缓存对应类型 \(adType) 的广告,直接展示开屏广告 --------------")
        } else {
            // 查找缓存中是否有其他Key的广告缓存
            let _tempKeys: [GoogleADType] = OPEN_AD_KEYS.filter({$0 != adType})
            var _tempGoogleAD: GADAppOpenAd?
            var _tempADType: GoogleADType?
            for key in _tempKeys {
                if let _tempAD = openADCache[key] {
                    _tempGoogleAD = _tempAD
                    _tempADType = key
                    break
                }
            }
            if let _temp = _tempGoogleAD, let _t = _tempADType {
                // 找到了其他类型 Key 广告缓存,直接展示
                showOpenAD(rootController, ad: (_t, _temp))
                Log.debug("缓存中没有缓存对应类型 \(adType) 的广告, 但是找到了其他类型 \(_t) 的缓存广告, 直接展示 --------------")
            } else {
                // 没有找到其他类型 Key 的广告缓存, 查看当前是否正在请求当前类型的广告
                if self._cacheADStatus[adType] ?? false {
                    Log.debug("缓存中没有缓存对应类型 \(adType) 的广告, 也没有找到其他类型的缓存广告, 但是当前类型 \(adType) 的广告正在缓存中,重复等待缓存结果  --------------")
                    // 正在缓存当前类型的广告,需要等待,重复3次尝试,查看是否已经缓存完毕
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                        if self?.MAX_TIME_COLD_START_SPLASH_AD == 0 {
                            // 广告加载超时，则默认展示完毕
                            timer.invalidate()
                            self?.MAX_TIME_COLD_START_SPLASH_AD = adType == .GoogleOpenAD1 ? .zero : 5
                            // 条件不满足,直接回调外部操作
                            self?.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                        } else {
                            // 如果缓存开屏广告失败,直接返回
                            if let _fail = self?._cacheADFail[adType], _fail {
                                // 条件不满足,直接回调外部操作
                                self?.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                                timer.invalidate()
                                self?.MAX_TIME_COLD_START_SPLASH_AD = 5
                            } else {
                                if let _cacheGoogleAD = self?.openADCache[adType] {
                                    self?.showOpenAD(rootController, ad: (adType, _cacheGoogleAD))
                                    self?.MAX_TIME_COLD_START_SPLASH_AD = 5
                                    timer.invalidate()
                                }
                                self?.MAX_TIME_COLD_START_SPLASH_AD -= 1
                            }
                        }
                    }
                } else {
                    Log.debug("缓存中没有缓存对应类型 \(adType) 的广告, 也没有找到其他类型的缓存广告, 当前类型 \(adType) 的广告也没有处于缓存中 --------------")
                    // 当前广告类型没有缓存,开始缓存,并直接返回外部回调
                    if trigger_retry_mechanism[adType] ?? false {
                        Log.debug("当前开屏广告 \(adType) 触发了重试机制 ----- 不再重新发送广告缓存请求 -----------")
                    } else {
                        Log.debug("重新开始当前类型\(adType)的广告  返回外部回调 -----------")
                        self.cacheAppOpenAd(adType: adType)
                    }
                    // 条件不满足,直接回调外部操作
                    self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                }
            }
        }
    }
}

// MARK: Private Methods
private extension LRGoogleOpenADManager {
    // 缓存开屏
    func cacheAppOpenAd(adType: GoogleADType) {
        // 标志位 --- 当前广告类型是否正在缓存
        self._cacheADStatus[adType] = true
        GADAppOpenAd.load(withAdUnitID: adType.ADKEY(), request: GADRequest(), orientation: UIInterfaceOrientation.portrait) { (ad: GADAppOpenAd?, err: Error?) in
            // 标志位 --- 当前广告类型是否正在缓存
            self._cacheADStatus[adType] = false
            guard err == nil else {
                if adType == .GoogleOpenAD1 {
                    if self.MAX_TIME_COLD_START_SPLASH_AD == .zero {
                        Log.debug("冷启动开屏广告最大等待时间结束,停止\(GoogleADType.GoogleOpenAD1)瞬发缓存请求 ----------")
                        return
                    }
#if DEBUG
                    if LRNetStateManager.shared.netState == .NoNet || LRNetStateManager.shared.netState == .LTE {
                        self.MAX_TIME_COLD_START_SPLASH_AD -= 1
                    }
#endif
                    // 冷启动开屏瞬发重新请求
                    self.cacheAppOpenAd(adType: adType)
                    Log.debug("冷启动开屏广告瞬发重新缓存请求 ----------")
                } else {
                    // 标志位 --- 当前广告类型是否请求成功
                    self._cacheADFail[adType] = true
                    // 触发超时请求机制
                    self.trigger_retry_mechanism[adType] = true
                    delay(ADRewardRequestDelayTime) {
                        self.cacheAppOpenAd(adType: adType)
                    }
                }
                return
            }
            // 重置超时重试标志位
            self.trigger_retry_mechanism[adType] = false
            // 标志位 --- 当前广告类型是否请求成功
            self._cacheADFail[adType] = false
            Log.debug("缓存开屏广告成功 ------------- \(adType) -- \(ad!)")
            self.openADCache[adType] = ad!
            ad?.fullScreenContentDelegate = self
            self.ADloadTime = Date()
        }
     }
    
    // 展示开屏
    func showOpenAD(_ rootController: UIViewController, ad: (adType: GoogleADType, gooleAD: GADAppOpenAd?)) {
        guard wasLoadTimeLessThanNHoursAgo(4) else {
            // 条件不满足,直接回调外部操作
            self.adDelegate?.hs_adDidDismissFullScreenContent(adType: ad.adType)
            return
        }
        
        do {
            if let _ = try ad.gooleAD?.canPresent(fromRootViewController: rootController) {
                ad.gooleAD?.present(fromRootViewController: rootController)
            }
        } catch {
            // 条件不满足,直接回调外部操作
            self.adDelegate?.hs_adDidDismissFullScreenContent(adType: ad.adType)
        }
    }
    
    // 判断开屏广告的时效
    func wasLoadTimeLessThanNHoursAgo(_ n: Int) -> Bool {
        let now = Date()
        let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(ADloadTime ?? Date())
        let secondsPerHour = 3600.0
        let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
        return intervalInHours < Double(n)
    }
}

extension LRGoogleOpenADManager: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Log.debug("弹出开屏广告失败 --- \(error.localizedDescription), 重新缓存开屏广告 ------------")
        adDidDismissFullScreenContent(ad)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        var adType: GoogleADType = .GoogleOpenAD1
        openADCache.forEach { (key: GoogleADType, value: GADAppOpenAd) in
            if value.sg_equateableAnyObject(object: ad) {
                adType = key
            }
        }
        
        // 移除掉广告缓存
        openADCache.removeValue(forKey: adType)
        Log.debug("开屏广告 \(adType) 关闭并移除缓存---------------")
        self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
    }
}

// MARK: Notification
private extension LRGoogleOpenADManager {
    @objc func willEnterBackground(notification: Notification) {
        if !openADCache.values.isEmpty {
            return
        }
        // 冷启动开屏只缓存一次,之后都执行热启动广告的缓存
        self.cacheAppOpenAd(adType: GoogleADType.GoogleOpenAD2)
        Log.debug("APP进入后台, 重新缓存开屏广告 \(GoogleADType.GoogleOpenAD2)---------------")
    }
}
