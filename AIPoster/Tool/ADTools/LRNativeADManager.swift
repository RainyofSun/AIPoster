//
//  LRNativeADManager.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2023/2/8.
//

import UIKit
import GoogleMobileAds

// MARK: 原生视频管理类
class LRNativeADManager: NSObject {

    weak open var adDelegate: HSADFullScreenContentDelegate?
    
    // Ad加载器
    private var _adLoader: GADAdLoader?
    // 广告View
    private var _adView: GADNativeAdView?
    private var _nativeADType: GoogleADType?
    // 广告是否加载失败
    private var _adLoadFail: Bool = false
    
    public static let shared = LRNativeADManager()
    override init() {
        super.init()
        
    }
    
    // MARK: Public Methods
    @discardableResult
    public func refreshNativeAD(viewController: UIViewController, adType: GoogleADType) -> UIView? {
        _nativeADType = adType
        if _adLoader == nil {
            let options = GADNativeAdViewAdOptions.init()
            options.preferredAdChoicesPosition = adType == .GoogleNativeAD1 ? .topRightCorner : .topLeftCorner
            _adLoader = GADAdLoader(adUnitID: adType.ADKEY(), rootViewController: viewController, adTypes: [GADAdLoaderAdType.native], options: [options])
            _adLoader?.delegate = self
        }
        
        if adType == .GoogleNativeAD2, _adView == nil {
            let contatinView = LRCleanResultNativeADView(frame: CGRectZero)
            _adView = contatinView
        }
        
        _adLoader?.load(GADRequest())
        return _adView
    }
    
    public func free() {
        _adLoader?.delegate = nil
        _adLoader = nil
        _adView?.removeFromSuperview()
        _adView = nil
        _nativeADType = nil
    }
}

extension LRNativeADManager: GADAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        Log.debug("原生广告加载失败 ----------- \(error.localizedDescription)")
        _adLoadFail = true
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        if _adLoadFail {
            _adLoadFail = false
            return
        }
        self.adDelegate?.hs_nativeAdLoadComplete(adType: _nativeADType ?? .GoogleNativeAD1, nativeADView: _adView ?? UIView())
    }
}

extension LRNativeADManager: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        Log.debug("原生广告内容:\n body = \(nativeAd.body ?? "") \n callToAction = \(nativeAd.callToAction ?? "") \n starRating = \(nativeAd.starRating ?? 0) \n store = \(nativeAd.store ?? "") \n price = \(nativeAd.price ?? "") \n advertiser = \(nativeAd.advertiser ?? "") \n")
        nativeAd.delegate = self
        
        if _nativeADType == .GoogleNativeAD2, let _native_ad2 = _adView as? LRCleanResultNativeADView {
            _native_ad2.reloadNativeADSource(nativeAd)
        }
        
        if nativeAd.mediaContent.hasVideoContent {
            nativeAd.mediaContent.videoController.delegate = self
        }
    }
}

extension LRNativeADManager: GADNativeAdDelegate {
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdIsMuted(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
}

extension LRNativeADManager: GADVideoControllerDelegate {
    func videoControllerDidMuteVideo(_ videoController: GADVideoController) {
        
    }
    
    func videoControllerDidPlayVideo(_ videoController: GADVideoController) {
        
    }
    
    func videoControllerDidPauseVideo(_ videoController: GADVideoController) {
        
    }
    
    func videoControllerDidUnmuteVideo(_ videoController: GADVideoController) {
        
    }
    
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
        
    }
}
