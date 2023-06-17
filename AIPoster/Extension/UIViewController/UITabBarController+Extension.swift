//
//  UITabBarController+Extension.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/4/19.
//

import UIKit

extension UITabBarController {
    /// 根据类名寻找在Tab中的Index
    /// 类名
    func specialClassSubscript(className: String) -> Int? {
        var _index: Int?
        self.children.enumerated().forEach { (controllerIndex: Int, vcItem: UIViewController) in
            if let _nav = vcItem as? UINavigationController, let _rootVC = _nav.viewControllers.first {
                if _rootVC.className == className {
                    _index = controllerIndex
                }
            } else if vcItem.className == className {
                _index = controllerIndex
            }
        }
        
        return _index
    }
}
