//
//  UITableView+Extension.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/23.
//

import UIKit

extension UITableView {
    func reloadWithAnimation() {
        let animation = CATransition.init()
        animation.type = .fade
        animation.duration = 0.3
        self.layer.add(animation, forKey: "reloadAnimation")
        self.reloadData()
        self.layer.removeAnimation(forKey: "reloadAnimation")
    }
}

extension UITableViewCell {
    /// 左侧插入动画
    func leftInsertAnimation() {
        var center: CGPoint = self.center
        let origalCenter = center
        center.x += self.bounds.width
        self.center = center
        UIView.animate(withDuration: APPAnimationDurationTime) {
            self.center = origalCenter
        }
    }
    
    /// 弹簧效果
    func springAnimation() {
        var center: CGPoint = self.center
        let origalCenter = center
        center.y += self.bounds.height
        self.center = center
        UIView.animate(withDuration: APPAnimationDurationTime) {
            self.center = origalCenter
        }
    }
    
    /// 折叠展开效果
    func foldAnimation() {
        self.transform = CGAffineTransformMakeTranslation(0, -100)
        UIView.animate(withDuration: APPAnimationDurationTime) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    /// 左侧3D变化效果
    func left3DAnimation() {
        var rotation: CATransform3D = CATransform3DMakeRotation((90.0 * Double.pi)/180, 0, 0.7, 0.4)
        rotation.m34 = 1.0 / -600
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 10, height: 10)
        self.alpha = 0
        self.layer.transform = rotation
        self.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        UIView.animate(withDuration: APPAnimationDurationTime * 2.5) {
            self.layer.transform = CATransform3DIdentity
            self.alpha = 1
            self.layer.shadowOffset = CGSizeZero
        }
    }
    
    /// 底部飞入效果
    func flyInAnimation() {
        self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        //x和y的最终值为1
        UIView.animate(withDuration: APPAnimationDurationTime) {
            self.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
}
