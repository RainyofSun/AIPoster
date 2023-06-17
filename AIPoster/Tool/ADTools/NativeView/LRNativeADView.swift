//
//  LRNativeADView.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/4/4.
//

import UIKit
import GoogleMobileAds

class LRNativeADView: GADNativeAdView {

    open var hideIcon: Bool = false
    
    lazy var iconImageView: UIImageView = {
        return UIImageView(frame: CGRect.zero)
    }()
    
    lazy var adLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium)
        label.textColor = UIColor(hexString: "#FEFFFF")
        label.text = "Ad"
        label.backgroundColor = UIColor(hexString: "#FFBD43")
        label.roundCorners([.topRight,.bottomRight], radius: 2)
        label.textAlignment = .center
        return label
    }()
    
    // APP名字
    lazy var headLineLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium)
        label.textColor = TextMainColor
        label.numberOfLines = 2
        return label
    }()
    
    lazy var callButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitleColor(UIColor(hexString: "#FEFFFF"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        button.backgroundColor = UIColor(hexString: "#FFBD43")
        button.cornerRadius = 7
        button.isUserInteractionEnabled = false
        button.isHidden = true
        return button
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        label.textColor = TextMainColor
        label.numberOfLines = 0
        if #available(iOS 14.0, *) {
            label.lineBreakStrategy = []
        } else {
            // Fallback on earlier versions
        }
        return label
    }()
    
    lazy var mView: GADMediaView = {
        return GADMediaView(frame: CGRect.zero)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadADSubviews()
        layoutADSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func showNativeView() {
        UIView.animate(withDuration: APPAnimationDurationTime) {
            self.alpha = 1
        }
    }
    
    /// 更新原生广告的数据
    public func reloadNativeADSource(_ nativeAd: GADNativeAd) {
        self.nativeAd = nativeAd
        if let _image = nativeAd.icon?.image {
            (self.iconView as? UIImageView)?.image = _image
        }
        
        self.hideIcon = (nativeAd.icon?.image == nil)
        
        (self.headlineView as? UILabel)?.text = nativeAd.headline
        if let callAction = nativeAd.callToAction {
            (self.callToActionView as? UIButton)?.setTitle(callAction, for: UIControl.State.normal)
            self.callToActionView?.isHidden = false
        }
        
        if let _rate = nativeAd.starRating?.floatValue {
            (self.starRatingView as? LRStarRateView)?.currentStarCount = _rate
            self.starRatingView?.isHidden = _rate <= Float.zero
        }
        
        (self.bodyView as? UILabel)?.text = nativeAd.body
        self.mediaView?.mediaContent = nativeAd.mediaContent
    }

    // MARK: 子类复写
    public func loadADSubviews() {
        self.alpha = .zero
        self.cornerRadius = 10
        self.backgroundColor = WhiteColor
        
        self.iconView = iconImageView
        self.headlineView = headLineLabel
        self.callToActionView = callButton
        self.bodyView = contentLabel
        self.mediaView = mView
        self.iconView?.cornerRadius = 7
    }
    
    public func layoutADSubviews() {
        
    }
}
