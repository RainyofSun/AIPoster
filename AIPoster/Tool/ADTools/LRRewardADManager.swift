//
//  LRRewardADManager.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/12/1.
//
/*
 激励视频：
 1.拍照翻译、语音翻译、AR翻译触发付费页面，点击按钮关闭时使用系统弹窗提示，“获得一份权益，观看一个视频解锁当前功能一次”。暂定每次关闭都会触发。(j1)
 */

import UIKit
import GoogleMobileAds

// MARK: 激励视频广告管理类
class LRRewardADManager: NSObject {
    
    // 代理
    weak open var adDelegate: HSADFullScreenContentDelegate?
    // 广告管理
    private(set) var rewardedAd: GADRewardedAd?
    // 是否触发了延迟缓存
    private var trigger_retry_mechanism: Bool = false
    
    public static let shared = LRRewardADManager()
    override init() {super.init()}
    
    // MARK: Public Methods
    public func cacheADAgain() {
        if self.rewardedAd != nil {
            Log.debug("已缓存激励广告 -----------")
            return
        }
        
        if self.trigger_retry_mechanism {
            Log.debug("激励视频广告触发了延迟缓存,不再重新开始缓存 -----------")
            return
        }
        cacheRewardAD()
    }
    
    // MARK: Private Methods
    private func cacheRewardAD() {
        self.rewardedAd = nil
        GADRewardedAd.load(withAdUnitID: GoogleADType.GoogleRewardAD1.ADKEY(), request: GADRequest()) { (ad: GADRewardedAd?, err:Error?) in
            guard err == nil else {
                Log.debug("激励视频广告请求失败 --------------- reason = \(err?.localizedDescription ?? "")")
                delay(ADRewardRequestDelayTime) {
                    self.trigger_retry_mechanism = true
                    self.cacheRewardAD()
                }
                return
            }
            self.trigger_retry_mechanism = false
            Log.debug("激励视频广告请求成功 -----------")
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }
}

extension LRRewardADManager: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Log.debug("激励视频广告关闭,重新缓存广告 ---------------")
        // 重新缓存激励视频
        cacheRewardAD()
        self.adDelegate?.hs_adDidDismissFullScreenContent(adType: GoogleADType.GoogleRewardAD1)
    }
}
