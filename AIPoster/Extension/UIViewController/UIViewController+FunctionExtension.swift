//
//  UIViewController+FunctionExtension.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/26.
//

import UIKit

extension UIViewController {
    /*
    /// 跳转订阅
    @discardableResult
    func goSubscribeControllerPage() -> LRChatBootSubscribeViewController {
        let subscribeVC: LRChatBootSubscribeViewController = LRChatBootSubscribeViewController()
        let subscribeNavVC: LRNavigationViewController = LRNavigationViewController(rootViewController: subscribeVC)
        subscribeNavVC.modalPresentationStyle = .fullScreen
        self.present(subscribeNavVC, animated: true)
        return subscribeVC
    }
    
    /// 展示退出弹窗
    func showExitChatRoomAlert(closeComplete: ((Bool) -> Void)? = nil) {
        let alert: LRChatBootAlertView = LRChatBootAlertView(frame: CGRectZero)
        alert.setAlertTitle(title: LRLocalizableManager.localValue("chatQuitAlertTitle"), alertSubTitle: LRLocalizableManager.localValue("chatQuitAlertContent"), alertImage: "alert_icon_chat", okButtonTitle: LRLocalizableManager.localValue("Quit"))
        getCleanHostWindow().addSubview(alert)
        alert.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        alert.showAlert(completeHandler: closeComplete)
    }
    
    /// 展示评分弹窗
    func showAPPScore(closeComplete: (()-> Void)? = nil) {
        if LRDebugSettingCache.showAppScoreInCurrentVersion() {
            Log.debug("已经展示了评分 ---------")
            closeComplete?()
            return
        }
        
        let alert: LRChatBootRateAlert = LRChatBootRateAlert(frame: CGRectZero)
        alert.setAlertTitle(title: LRLocalizableManager.localValue("settingRate"), alertSubTitle: LRLocalizableManager.localValue("settingRateAlert"), alertImage: "alert_icon_rate", okButtonTitle: LRLocalizableManager.localValue("Rate"))
        getCleanHostWindow().addSubview(alert)
        alert.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        alert.showAlert { [weak self] isOK in
            if isOK {
                let _rate = alert.getRate()
                if _rate >= 3.0 {
                    LRAPPStoreReviewTool.goAppStoreRatePage()
                }
                self?.loadAppInnerScore(score: alert.getRate())
            }
            closeComplete?()
        }
    }
    
    private func loadAppInnerScore(score: Float) {
        // 查看有没有token
        if AuthManager.hasAuth {
            uploadRating(score: score)
        } else {
            AuthRefresh.refreshToken { [weak self] in
                self?.uploadRating(score: score)
            } fail: { error in
                Log.info(error?.localizedDescription ?? "")
            }
        }
    }
    
    private func uploadRating(score: Float) {
        RatingReviewTarget().addFeedBack(content: "Good", type: 5, complete: { response, error in
            guard error == nil else {
                Log.error("app 评分上传错误 === \(error?.localizedDescription ?? "")")
                return
            }
            Log.debug("分数上传完毕 ==== \(response ?? [:])")
        })
    }
    */
    /// 系统分享
    public func systemShare(title: String?, image: String? = nil, urlString: String? = nil) {
        var activityItems: [Any] = []
        if let title = title {
            activityItems.append(title)
        }
        if let image = image, let img = UIImage(named: image) {
            activityItems.append(img)
        }
        if let urlString = urlString, let url = URL(string: urlString) {
            activityItems.append(url)
        }
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // 设置不出现在活动的项目
        activityController.excludedActivityTypes = [.print, .saveToCameraRoll, .assignToContact]
        activityController.popoverPresentationController?.sourceView = self.view
        self.present(activityController, animated: true)
    }
}
