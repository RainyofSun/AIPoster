//
//  LRBannerADManager.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/12/1.
//
/*
 Banner广告：
 1.文本翻译页顶部，跟随页面滑动。(b1)
 2.设置页底部，不跟随页面滑动。(b2)
 */

import UIKit
import GoogleMobileAds

// MARK: banner 轮播广告管理
class LRBannerADManager: NSObject {
    
    // 弱存储轮播广告
    private var bannerHashTab: NSHashTable = NSHashTable<UIImageView>.weakObjects()
    // 广告高度
    private(set) var ADBannerHeight: CGFloat = 50
    
    public static let shared = LRBannerADManager()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(subscribeNotification(notification:)), name: LRIAPStoreManager.shared.IAPSubscribeSuccessNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscribeNotification(notification:)), name: LRIAPStoreManager.shared.IAPSubscribeRestoreNotification, object: nil)
    }
    
    // MARK: Notification
    @objc private func subscribeNotification(notification: Notification) {
        guard bannerHashTab.count > 0 else {
            return
        }
        bannerHashTab.allObjects.forEach { _bannerView in
            removeBannerView(_bannerView, remove: false)
        }
        bannerHashTab.removeAllObjects()
    }
    
    // MARK: - Banner广告
    func showBannerWithKey(vc: UIViewController, keyID: String) -> UIImageView? {
        let isExpired = LRIAPStoreManager.shared.localVerificationSubscriptionExpirationTime()
        if !isExpired {
            return nil
        }
        let imageView = UIImageView.init(frame: CGRect.zero)
        imageView.image = UIImage.init(named: "adLoading")
        imageView.isUserInteractionEnabled = true
        let bannerView = GAMBannerView(adSize: GADAdSizeFullWidthPortraitWithHeight(ADBannerHeight))
        bannerView.adUnitID = keyID
        bannerView.rootViewController = vc
        bannerView.load(GADRequest())
        imageView.addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.bannerHashTab.add(imageView)
        return imageView
    }
    
    // 移除广告
    func removeBannerView(_ bannerView: UIImageView, remove: Bool = true) {
        bannerView.subviews.forEach { item in
            if let _adView = item as? GAMBannerView {
                _adView.adUnitID = ""
                _adView.rootViewController = nil
                _adView.load(GADRequest());
                _adView.removeFromSuperview()
            }
        }
        bannerView.removeFromSuperview()
        if remove {
            self.bannerHashTab.remove(bannerView)
        }
    }
}
