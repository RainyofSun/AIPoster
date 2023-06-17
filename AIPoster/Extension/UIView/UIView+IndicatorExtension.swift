//
//  UIView+IndicatorExtension.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/8.
//

import UIKit

extension UIView {
    
    @discardableResult
    func buildActivityIndicatorView(activityViewStyle: UIActivityIndicatorView.Style = .medium, activityViewColor: UIColor = .white) -> UIActivityIndicatorView {
        let activityView = UIActivityIndicatorView.init(style: activityViewStyle)
        activityView.hidesWhenStopped = true
        activityView.startAnimating()
        activityView.alpha = 1
        activityView.color = activityViewColor
        self.addSubview(activityView)
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return activityView
    }
    
    public func removeIndicatorView(activityView: UIActivityIndicatorView?) {
        if activityView != nil {
            activityView?.stopAnimating()
            activityView?.removeFromSuperview()
        }
    }
}
