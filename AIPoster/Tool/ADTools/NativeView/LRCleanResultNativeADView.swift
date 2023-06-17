//
//  LRCleanResultNativeADView.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/4/3.
//

import UIKit
import GoogleMobileAds

class LRCleanResultNativeADView: LRNativeADView {

    override var hideIcon: Bool {
        didSet {
            if hideIcon {
                adLabel.snp.remakeConstraints { make in
                    make.left.top.equalTo(iconImageView)
                    make.size.equalTo(CGSize(width: 23, height: 15))
                }
            } else {
                if adLabel.x > 30 {
                    Log.debug("不需要重新约束 -----")
                    return
                }
                adLabel.snp.remakeConstraints { make in
                    make.left.equalTo(iconImageView.snp.right).offset(8)
                    make.top.equalTo(iconImageView)
                    make.size.equalTo(CGSize(width: 23, height: 15))
                }
            }
        }
    }
    
    private lazy var freeLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.backgroundColor = UIColor(hexString: "#61C55B")
        lab.roundCorners([.topLeft, .bottomLeft], radius: 2)
        lab.text = "Free"
        lab.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lab.textColor = UIColor(hexString: "#FEFFFF")
        lab.textAlignment = .center
        return lab
    }()
    
    private lazy var grayContainerView: UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor(white: .zero, alpha: 0.3)
        return view
    }()
    
    override func reloadNativeADSource(_ nativeAd: GADNativeAd) {
        super.reloadNativeADSource(nativeAd)
        self.mView.bringSubviewToFront(self.grayContainerView)
        self.mView.bringSubviewToFront(self.freeLab)
    }

    override func loadADSubviews() {
        super.loadADSubviews()
    
        self.headLineLabel.textColor = WhiteColor
        self.contentLabel.textColor = WhiteColor
        self.contentLabel.font = UIFont.systemFont(ofSize: 10)
        
        self.callButton.backgroundColor = UIColor(hexString: "#036CEC")
        self.callButton.cornerRadius = 25
        
        self.addSubview(mView)
        
        mView.addSubview(freeLab)
        mView.addSubview(grayContainerView)
    
        grayContainerView.addSubview(iconImageView)
        grayContainerView.addSubview(contentLabel)
        grayContainerView.addSubview(headLineLabel)
        grayContainerView.addSubview(adLabel)

        self.addSubview(callButton)
    }
    
    override func layoutADSubviews() {
        super.layoutADSubviews()
        
        mView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.height.equalTo(147)
        }
        
        freeLab.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.size.equalTo(CGSize(width: 35, height: 15))
        }
        
        grayContainerView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(60)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.size.equalTo(45)
        }
        
        adLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.top.equalTo(iconImageView)
            make.size.equalTo(CGSize(width: 23, height: 15))
        }
        
        headLineLabel.snp.makeConstraints { make in
            make.top.equalTo(adLabel)
            make.left.equalTo(adLabel.snp.right).offset(3)
            make.right.equalToSuperview().offset(-8)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(headLineLabel.snp.bottom)
            make.left.equalTo(adLabel)
            make.right.equalTo(headLineLabel)
            make.bottom.greaterThanOrEqualTo(iconImageView)
        }
        
        callButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(grayContainerView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}
