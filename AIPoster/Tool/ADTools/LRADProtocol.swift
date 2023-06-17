//
//  LRADProtocol.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/12/1.
//

import UIKit

// MARK: 广告点击代理
protocol HSADFullScreenContentDelegate: AnyObject {
    /// 广告关闭的代理
    func hs_adDidDismissFullScreenContent(adType: GoogleADType)
    /// 原生广告加载完毕
    func hs_nativeAdLoadComplete(adType: GoogleADType, nativeADView: UIView)
}

extension HSADFullScreenContentDelegate {
    /// 广告关闭的代理
    func hs_adDidDismissFullScreenContent(adType: GoogleADType) {
        Log.debug("广告关闭的代理 ------- 默认实现")
    }
    
    /// 原生广告加载完毕
    func hs_nativeAdLoadComplete(adType: GoogleADType, nativeADView: UIView) {
        Log.debug("原生广告的代理 ------- 默认实现")
    }
}
