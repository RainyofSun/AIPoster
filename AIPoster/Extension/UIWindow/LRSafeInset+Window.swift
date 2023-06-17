//
//  LRSafeInset+Window.swift
//  Scaning
//
//  Created by 苍蓝猛兽 on 2023/5/18.
//

import UIKit
    
extension UIWindow {
    
    public class func safeAreaBottom() -> CGFloat {
        return self.keyWindow()?.safeAreaInsets.bottom ?? 0
    }
    public class func safeAreaTop() -> CGFloat {
        return self.keyWindow()?.safeAreaInsets.top ?? 0
    }
    
    /// Returns the tabController
    public class func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            let sceneDelegate = UIApplication.shared.connectedScenes
                .first!.delegate as! SceneDelegate
            return sceneDelegate.window
        } else {
            // iOS12 or earlier
            return UIApplication.shared.keyWindow
        }
    }
    
    /// Returns the window root controller
    public class func rootViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            let sceneDelegate = UIApplication.shared.connectedScenes
                .first!.delegate as! SceneDelegate
            return sceneDelegate.window!.rootViewController
        } else {
            // iOS12 or earlier
            // UIApplication.shared.keyWindow?.rootViewController
            let appDelegate = UIApplication.shared.delegate?.window
            return appDelegate??.rootViewController
        }
    }
    
    /// Returns the top most controller
    public class func topViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            let sceneDelegate = UIApplication.shared.connectedScenes
                .first!.delegate as! SceneDelegate
            let rootViewController = sceneDelegate.window!.rootViewController
            return topMost(of: rootViewController)
        } else {
            // iOS12 or earlier
            // UIApplication.shared.keyWindow?.rootViewController
            let appDelegate = UIApplication.shared.delegate?.window
            let rootViewController = appDelegate??.rootViewController
            return topMost(of: rootViewController)
        }
    }
    
    /// Returns the top most view controller from given view controller's stack.
    public class func topMost(of viewController: UIViewController?) -> UIViewController? {
        // presented view controller
        if let presentedViewController = viewController?.presentedViewController {
            return self.topMost(of: presentedViewController)
        }
        
        // UITabBarController
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return self.topMost(of: selectedViewController)
        }
        
        // UINavigationController
        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return self.topMost(of: visibleViewController)
        }
        
        // UIPageController
        if let pageViewController = viewController as? UIPageViewController,
           pageViewController.viewControllers?.count == 1 {
            return self.topMost(of: pageViewController.viewControllers?.first)
        }
        
        // child view controller
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return self.topMost(of: childViewController)
            }
        }
        return viewController
    }
}

extension UIApplication {
    var currentScene: UIWindowScene? {
        connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
}
