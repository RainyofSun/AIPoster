//
//  LRInterstitialADManager.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/12/1.
//
/*
 插屏广告：
 1.大于等于3次页面切换触发一次插屏广告展示。(i1)
 */

import UIKit
import GoogleMobileAds

// MARK: 插屏广告管理
class LRInterstitialADManager: NSObject {
    
    // 代理
    weak open var adDelegate: HSADFullScreenContentDelegate?
    
    private var interstitial1: GAMInterstitialAd?
    private var interstitial2: GAMInterstitialAd?
    private var interstitial3: GAMInterstitialAd?
    
    // 插屏最大限制次数
    private let ADMAXLIMIT: Int = 3
    
    public static let shared = LRInterstitialADManager()
    override init() {
        super.init()
        cacheInsertAD(adType: GoogleADType.GoogleInterstitialAD1)
        cacheInsertAD(adType: GoogleADType.GoogleInterstitialAD2)
    }
    
    // MARK: Public Methods
    public func cacheADAgain() {
        if self.interstitial1 == nil {
            cacheInsertAD(adType: GoogleADType.GoogleInterstitialAD1)
        }
        
        if self.interstitial2 == nil {
            cacheInsertAD(adType: GoogleADType.GoogleInterstitialAD2)
        }
    }
    
    /// 展示插屏页广告 forceShow 为True 将无视限制次数,插屏广告若缓存必会立即进行展示 clear 为True 重置记录次数
    func showInsertAD(vc: UIViewController, adType: GoogleADType, ADForceDisplay forceShow: Bool = false, clearRecords clear: Bool = false) {
        // 如果订阅未过期就不再展示广告
        let isExpired = LRIAPStoreManager.shared.localVerificationSubscriptionExpirationTime()
        if !isExpired {
            // 条件不满足,直接回调外部操作
            self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
            return
        }
        
        let _showInsertAD = self.googleADHasCache(adType: adType)
        if !_showInsertAD.showAD {
            // 广告未缓存,条件不满足,直接回调外部操作
            self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
            return
        }
        
        if forceShow {
            // 强制展示插屏,无视次数限制
            _showInsertAD.gooleAD?.present(fromRootViewController: vc)
            Log.debug("强制展示插屏广告 ==== \(adType)")
            if clear {
                // 重置次数记录
                LRUserDefaultADCache.resetSwitchPageCount()
            }
        } else {
            var switchCount = LRUserDefaultADCache.getSwitchPageCount()
            switchCount += 1
            if switchCount >= ADMAXLIMIT {
                // 广告已缓存且符合展示规则
                _showInsertAD.gooleAD?.present(fromRootViewController: vc)
                Log.debug("展示插屏广告 ==== \(adType)")
                // 重置次数记录
                LRUserDefaultADCache.resetSwitchPageCount()
            } else {
                // 存储页面切换的次数
                LRUserDefaultADCache.saveSwitchPageCount(switchCount)
            }
        }
        
        // 回调外部操作
        self.adDelegate?.hs_adDidDismissFullScreenContent(adType: adType)
    }
    
    /// 缓存插屏广告
    public func cacheInsertAD(adType: GoogleADType) {
        if adType == .GoogleInterstitialAD1 {
            self.interstitial1?.fullScreenContentDelegate = nil
            self.interstitial1 = nil
        }
        if adType == .GoogleInterstitialAD2 {
            self.interstitial2?.fullScreenContentDelegate = nil
            self.interstitial2 = nil
        }
        if adType == .GoogleInterstitialAD3 {
            self.interstitial3?.fullScreenContentDelegate = nil
            self.interstitial3 = nil
        }
        
        GAMInterstitialAd.load(withAdManagerAdUnitID: adType.ADKEY(), request: GAMRequest()) { (ad: GAMInterstitialAd?, err: Error?) in
            guard err == nil else {
                Log.debug("插屏广告 \(adType) 缓存失败 --- \(err?.localizedDescription ?? ""), 延迟重新缓存 ----------")
                delay(ADInterstitialRequestDelayTime) {
                    self.cacheInsertAD(adType: adType)
                }
                return
            }
            Log.debug("插屏广告 \(adType) 缓存成功 --------------")
            if adType == .GoogleInterstitialAD1 {
                self.interstitial1 = ad
            }
            if adType == .GoogleInterstitialAD2 {
                self.interstitial2 = ad
            }
            if adType == .GoogleInterstitialAD3 {
                self.interstitial3 = ad
            }
            
            ad?.fullScreenContentDelegate = self
        }
    }
}

// MARK: Private Methods
private extension LRInterstitialADManager {
    // 判断是否要展示缓存广告
    func googleADHasCache(adType: GoogleADType) -> (showAD: Bool, gooleAD: GAMInterstitialAd?) {
        var _showAD: Bool = false
        var _ad: GAMInterstitialAd?
        if adType == GoogleADType.GoogleInterstitialAD1 {
            _showAD = self.interstitial1 != nil
            _ad = self.interstitial1
        }
        if adType == GoogleADType.GoogleInterstitialAD2 {
            _showAD = self.interstitial2 != nil
            _ad = self.interstitial2
        }
        if adType == GoogleADType.GoogleInterstitialAD3 {
            _showAD = self.interstitial3 != nil
            _ad = self.interstitial3
        }
        return (_showAD, _ad)
    }
}

extension LRInterstitialADManager: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Log.debug("插屏广告 弹出失败, 延迟重新缓存 --------------\(error)")
        adDidDismissFullScreenContent(ad)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        var adType: GoogleADType = .GoogleInterstitialAD1
        if let _first = self.interstitial1, _first.sg_equateableAnyObject(object: ad) {
            cacheInsertAD(adType: GoogleADType.GoogleInterstitialAD1)
            adType = .GoogleInterstitialAD1
        }
        
        if let _sec = self.interstitial2, _sec.sg_equateableAnyObject(object: ad) {
            cacheInsertAD(adType: GoogleADType.GoogleInterstitialAD2)
            adType = .GoogleInterstitialAD2
        }
        
        Log.debug("关闭插屏广告 \(adType) 重新缓存 --------------")
    }
}
