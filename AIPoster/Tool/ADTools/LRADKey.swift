//
//  LRADKey.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/12/1.
//
/*
 开屏广告：
 Storage Cleaner-k1  ca-mb-app-pub-6392341289773148/bhy78l/12we45
 Storage Cleaner-k2  ca-mb-app-pub-6392341289773148/bhy78l/yu78on

 插屏广告：
 Storage Cleaner-i1  ca-mb-app-pub-6392341289773148/bhy78l/tyu8j3
 Storage Cleaner-i2  ca-mb-app-pub-6392341289773148/bhy78l/awd45t


 激励视频：
 Storage Cleaner-j1  ca-mb-app-pub-6392341289773148/bhy78l/uio87b


 原生广告：
 Storage Cleaner-y1  ca-mb-app-pub-6392341289773148/bhy78l/fr56ty
 Storage Cleaner-y2  ca-mb-app-pub-6392341289773148/bhy78l/v56yum
 */
import UIKit

// MARK: 广告Key

enum GoogleADType: CaseIterable {
    // 插屏
    case GoogleInterstitialAD1
    case GoogleInterstitialAD2
    case GoogleInterstitialAD3
    // 开屏
    case GoogleOpenAD1
    case GoogleOpenAD2
    // banner
    case GoogleBannerAD1
    case GoogleBannerAD2
    // 激励
    case GoogleRewardAD1
    case GoogleRewardAD2
    // 原生AD
    case GoogleNativeAD1
    case GoogleNativeAD2
    
    func ADKEY() -> String {
#if DEBUG
        switch self {
        case .GoogleInterstitialAD1:
            return "ca-app-pub-3940256099942544/4411468910"
        case .GoogleInterstitialAD2:
            return "ca-app-pub-3940256099942544/4411468910"
        case .GoogleInterstitialAD3:
            return "ca-app-pub-3940256099942544/4411468910"
        case .GoogleOpenAD1:
            return "ca-app-pub-3940256099942544/5662855259"
        case .GoogleOpenAD2:
            return "ca-app-pub-3940256099942544/5662855259"
        case .GoogleBannerAD1:
            return "ca-app-pub-3940256099942544/2934735716"
        case .GoogleBannerAD2:
            return "ca-app-pub-3940256099942544/2934735716"
        case .GoogleRewardAD1:
            return "ca-app-pub-3940256099942544/1712485313"
        case .GoogleRewardAD2:
            return "ca-app-pub-3940256099942544/1712485313"
        case .GoogleNativeAD1:
            return "ca-app-pub-3940256099942544/3986624511"
        case .GoogleNativeAD2:
            return "ca-app-pub-3940256099942544/3986624511"
        }
#else
        switch self {
        case .GoogleInterstitialAD1:
            return "ca-mb-app-pub-6392341289773148/bhy78l/tyu8j3"
        case .GoogleInterstitialAD2:
            return "ca-mb-app-pub-6392341289773148/bhy78l/awd45t"
        case .GoogleInterstitialAD3:
            return "ca-mb-app-pub-6392341289773148/bhy78l/awd45t"
        case .GoogleOpenAD1:
            return "ca-mb-app-pub-6392341289773148/bhy78l/12we45"
        case .GoogleOpenAD2:
            return "ca-mb-app-pub-6392341289773148/bhy78l/yu78on"
        case .GoogleBannerAD1:
            return ""
        case .GoogleBannerAD2:
            return ""
        case .GoogleRewardAD1:
            return "ca-mb-app-pub-6392341289773148/bhy78l/uio87b"
        case .GoogleRewardAD2:
            return ""
        case .GoogleNativeAD1:
            return "ca-mb-app-pub-6392341289773148/bhy78l/fr56ty"
        case .GoogleNativeAD2:
            return "ca-mb-app-pub-6392341289773148/bhy78l/v56yum"
        }
#endif
    }
}

// MARK: 广告常量位
// 发起缓存激励广告请求时需要延迟的时间
let ADRewardRequestDelayTime: TimeInterval = 15
// 发起缓存插页广告请求时需要延迟的时间
let ADInterstitialRequestDelayTime: TimeInterval = 5
