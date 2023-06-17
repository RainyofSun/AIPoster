//
//  CALayer+Extension.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/15.
//

import UIKit

extension CALayer {
    /// 设置阴影参数
    /// - Parameters:
    ///   - blur: 对应 Sketch 阴影 "模糊" 设置
    ///   - alpha: 对应 Sketch 阴影 "颜色" 的alpha值 例: 40% 即 0.4
    ///   - radius: 圆角半径
    ///   - color: 对应 Sketch 阴影 "颜色"
    ///   - offset: 对应 Sketch 阴影 "偏移" x y, CGSize(width: x, height: y)
    ///   - expand: 对应 Sketch 阴影 "扩展" 值
    func addShadow(blur: CGFloat, alpha: Float, corner radius: CGFloat, color: UIColor = .black, offset: CGSize = .zero, expand: CGFloat = 0) {
        // 内容视图圆角大小
        if radius != .zero {
            self.cornerRadius = radius
        }
        // 对应 Sketch 阴影 "颜色" 的alpha值 40% 即 0.4
        self.shadowOpacity = alpha
        // 对应 Sketch 阴影 "偏移" x y
        self.shadowOffset = offset
        // 对应 Sketch 阴影 "模糊" 设置, 值是 blur / 2
        self.shadowRadius = blur / 2
        // 对应 Sketch 阴影 "颜色"
        self.shadowColor = color.cgColor
        if expand != .zero {
            // 对应 Sketch 阴影 "扩展" 值 用来设置阴影的范围
            let rect = bounds.insetBy(dx: -expand, dy: -expand)
            // 阴影的范围
            self.shadowPath = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
        }
    }
}
