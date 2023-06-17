//
//  LROpenADManager.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/12/1.
//
/*
 开屏广告：
 2.App从后台返回前台，当无外部跳转链接，则展示开屏广告。（k1）
 */

import UIKit
import GoogleMobileAds

// MARK: 开屏广告管理类
class LROpenADManager: NSObject {
    
    // 代理
    weak open var adDelegate: HSADFullScreenContentDelegate?
    
    private var appOpenAd1 : GADAppOpenAd?// 开屏广告
    private var appOpenAd2 : GADAppOpenAd?// 开屏广告
    private var ADloadTime : Date? //开屏广告加载时间
    // 是否缓存开屏失败
    private var _cacheADFail: [GoogleADType: Bool] = [.GoogleOpenAD1: false, .GoogleOpenAD2: false]
    
    public static let shared = LROpenADManager()
    override init() {
        super.init()
        cacheAppOpenAd(adType: GoogleADType.GoogleOpenAD1)
    }
    
    // MARK: Public Methods
    public func cacheADAgain() {
        if self.appOpenAd1 == nil {
            cacheAppOpenAd(adType: GoogleADType.GoogleOpenAD1)
        }
    }
    
    // 展示开屏
    func tryToPresentAd(adType: GoogleADType) {
        // 如果付费，则不展示广告
        if LRIAPStoreManager.shared.localVerificationSubscriptionExpirationTime() == false {
            // 条件不满足,直接回调外部操作
            self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
            return
        }
        
        // 根控制器是否不为空
        guard let rootController = UIWindow.rootViewController() else {
            // 条件不满足,直接回调外部操作
            self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
            return
        }
    
        // 是否缓存有对应类型的Google开屏广告
        var _showADGroup = googleADHasCacheForGoogleADType(adType: adType)
        if _showADGroup.showAD {
            showOpenAD(rootController, ad: (adType, _showADGroup.gooleAD))
        } else {
            // 如果缓存开屏广告失败,直接返回
            if let _fail = _cacheADFail[adType], _fail {
                // 条件不满足,直接回调外部操作
                self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                return
            }
            // 重复回调3次判断广告是否已经完成缓存
            var repeatCount: Int = 3
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                if repeatCount == 0 {
                    // 广告加载超时，则默认展示完毕
                    timer.invalidate()
                    // 条件不满足,直接回调外部操作
                    self?.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                } else {
                    // 如果缓存开屏广告失败,直接返回
                    if let _fail = self?._cacheADFail[adType], _fail {
                        // 条件不满足,直接回调外部操作
                        self?.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
                        timer.invalidate()
                    } else {
                        _showADGroup = (self?.googleADHasCacheForGoogleADType(adType: adType))!
                        if _showADGroup.showAD {
                            self?.showOpenAD(rootController, ad: (adType, _showADGroup.gooleAD))
                            timer.invalidate()
                        }
                        repeatCount -= 1
                    }
                }
            }
        }
    }
    
    // MARK: Private Methods
    // 加载开屏
    private func cacheAppOpenAd(adType: GoogleADType) {
        if adType == .GoogleOpenAD1 {
            appOpenAd1 = nil
        }
        if adType == .GoogleOpenAD2 {
            appOpenAd2 = nil
        }
        GADAppOpenAd.load(withAdUnitID: adType.ADKEY(), request: GADRequest(), orientation: UIInterfaceOrientation.portrait) { (ad: GADAppOpenAd?, err: Error?) in
            guard err == nil else {
                self._cacheADFail[adType] = true
                if adType == .GoogleOpenAD1 {
                    Log.debug("缓存冷启动开屏广告失败, 开始缓存热启动开屏广告 -------------- \(err?.localizedDescription ?? "")")
                    self.cacheAppOpenAd(adType: GoogleADType.GoogleOpenAD2)
                } else {
                    Log.debug("缓存热启动开屏广告失败, 延迟重新缓存 -------------- \(err?.localizedDescription ?? "")")
                    delay(ADRewardRequestDelayTime) {
                        self.cacheAppOpenAd(adType: adType)
                    }
                }
                return
            }
            self._cacheADFail[adType] = false
            Log.debug("缓存开屏广告成功 ------------- \(adType)")
            if adType == .GoogleOpenAD1 {
                self.appOpenAd1 = ad
            }
            if adType == .GoogleOpenAD2 {
                self.appOpenAd2 = ad
            }
            ad?.fullScreenContentDelegate = self
            self.ADloadTime = Date()
        }
     }
    
    // 展示开屏
    private func showOpenAD(_ rootController: UIViewController, ad: (adType: GoogleADType, gooleAD: GADAppOpenAd?)) {
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
    
    // 判断是否缓存有对应展示类型的Google广告
    func googleADHasCacheForGoogleADType(adType: GoogleADType) -> (showAD: Bool, gooleAD: GADAppOpenAd?) {
        var _showAD: Bool = false
        var _ad: GADAppOpenAd?
        if adType == GoogleADType.GoogleOpenAD1 {
            _showAD = self.appOpenAd1 != nil
            _ad = self.appOpenAd1
        }
        if adType == GoogleADType.GoogleOpenAD2 {
            _showAD = self.appOpenAd2 != nil
            _ad = self.appOpenAd2
        }
        return (_showAD, _ad)
    }
    
    // 查看本地是否缓存有其他Key 的Google开屏广告
    func googleADgoogleADHasCache() -> (hasCache: Bool, gooleAD: GADAppOpenAd?) {
        var _cacheAD: Bool = false
        var _ad: GADAppOpenAd?
        if self.appOpenAd1 != nil {
            _cacheAD = true
            _ad =  self.appOpenAd1
        } else {
            if self.appOpenAd2 != nil {
                _cacheAD = true
                _ad = self.appOpenAd2
            }
        }
        return (_cacheAD, _ad)
    }
}

extension LROpenADManager: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Log.debug("弹出开屏广告失败 --- \(error.localizedDescription), 重新缓存开屏广告 ------------")
        adDidDismissFullScreenContent(ad)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        var adType: GoogleADType = .GoogleOpenAD1
        if let _ad1 = self.appOpenAd1, _ad1.sg_equateableAnyObject(object: ad) {
            adType = .GoogleOpenAD1
        }
        
        if let _ad2 = self.appOpenAd2, _ad2.sg_equateableAnyObject(object: ad) {
            adType = .GoogleOpenAD2
        }
        Log.debug("关闭开屏广告 \(adType), 重新缓存开屏广告 \(GoogleADType.GoogleOpenAD2)---------------")
        // 冷启动开屏/热启动关闭之后,直接缓存热启动插屏广告,冷启动开屏广告仅在app冷启动时缓存一次
        self.cacheAppOpenAd(adType: GoogleADType.GoogleOpenAD2)
        self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
    }
}
