//
//  LRAPPStoreReviewTool.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/3/28.
//

import UIKit
import StoreKit

class LRAPPStoreReviewTool: NSObject {

    /// 弹出系统评分
    static func showSystemReview() {
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.currentScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }
    }
    
    /// 跳转到 App Store评分页面
    static func goAppStoreRatePage() {
        guard let rateUrl: URL = URL.init(string: "itms-apps://itunes.apple.com/app/id" + APPStoreAPPID + "?action=write-review") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(rateUrl) {
            UIApplication.shared.open(rateUrl)
        }
    }
    
    /// APP 内部打开评分
    static func innerAPPStoreScore(controller: UIViewController) {
        let activityView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)
        activityView.hidesWhenStopped = true
        activityView.color = WhiteColor
        controller.view.addSubview(activityView)
        activityView.center = controller.view.center
        activityView.startAnimating()
        let storeCtrlr = SKStoreProductViewController()
        
        if controller.conforms(to: SKStoreProductViewControllerDelegate.self) {
            storeCtrlr.delegate = controller as? SKStoreProductViewControllerDelegate
        }
        
        storeCtrlr.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: APPStoreAPPID]) { (isSuccess, error) in
            if isSuccess {
                controller.present(storeCtrlr, animated: true, completion: {
                    activityView.stopAnimating()
                })
            } else {
                activityView.stopAnimating()
                print("error:\(String(describing: error))")
            }
        }
    }
}
