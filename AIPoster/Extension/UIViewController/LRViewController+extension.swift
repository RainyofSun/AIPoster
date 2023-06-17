//
//  LRViewController+extension.swift
//  Scaning
//
//  Created by 苍蓝猛兽 on 2023/5/18.
//

import UIKit

extension UIViewController {
    func statusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    func navHeight() -> CGFloat {
        return self.navigationController?.navigationBar.frame.height ?? 44
    }
    
    func tabBarHeight() -> CGFloat {
        return self.tabBarController?.tabBar.frame.height ?? 44
    }
}
