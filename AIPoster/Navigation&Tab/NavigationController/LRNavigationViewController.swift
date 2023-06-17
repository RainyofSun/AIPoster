//
//  LRNavigationViewController.swift
//  Scaning
//
//  Created by 苍蓝猛兽 on 2023/4/23.
//

import UIKit

class LRNavigationViewController: UINavigationController {
    
    // 自定义右滑返回手势
    var popRecognizer: UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = MainBGColor
        
        self.delegate = self
        initNavigationAppearance()
        self.navigationController?.navigationBar.delegate = self
        replaceInteractivePopGestureRecognizer()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool){
        if self.children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        super.pushViewController(viewController, animated: animated)
    }
}

private extension LRNavigationViewController {
    /// 替换系统右滑返回手势为自定义右滑返回手势
    func replaceInteractivePopGestureRecognizer() {
        // 获取系统边缘右滑返回手势
        guard let gesture = self.interactivePopGestureRecognizer, let gestureView = gesture.view else { return }
        // 让系统右滑返回手势失效
        gesture.isEnabled = false
        
        // 创建自己的右滑返回手势，并添加到视图上
        let popRecognizer = UIPanGestureRecognizer()
        popRecognizer.delegate = self
        popRecognizer.maximumNumberOfTouches = 1
        gestureView.addGestureRecognizer(popRecognizer)
        
        // 桥接系统右滑返回手势的触发方法到自己定义的手势上
        var navigationInteractiveTransition: Any?
        // gesture._targets.first._target 就是系统右滑返回触发方法所在的对象，因为涉及到隐式属性，所以通过 valueForKey 的方式获取
        if let targets = gesture.value(forKey: "_targets") as? NSMutableArray,
           let gestureRecognizerTarget = targets.firstObject as? NSObject {
            navigationInteractiveTransition = gestureRecognizerTarget.value(forKey: "_target")
        }
        if let navigationInteractiveTransition = navigationInteractiveTransition {
            // 因为 handleNavigationTransition 是 ObjC 的私有方法，这里通过字符串转方法名的方式实现桥接
            let handleTransition = NSSelectorFromString("handleNavigationTransition:")
            popRecognizer.addTarget(navigationInteractiveTransition, action: handleTransition)
        }
        self.popRecognizer = popRecognizer
    }
    
    func initNavigationAppearance() {
        // Navigation bar
        UINavigationBar.appearance().barTintColor = .clear
        UINavigationBar.appearance().tintColor = .white
        
        let attrs = [NSAttributedString.Key.foregroundColor: WhiteColor,
                     NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        UINavigationBar.appearance().titleTextAttributes = attrs
        
        UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "chevron.backward")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.backward")
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
    }
}

extension LRNavigationViewController: UIGestureRecognizerDelegate {
    
    /// 判断是否触发右滑返回手势，条件：1. 方向是往右滑, 2. 控制器栈的高度要大于1, 3. 不在转场过程中,
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let popRecognizer = self.popRecognizer else { return false }
        
        // 1. 方向是往右滑
        guard popRecognizer.translation(in: self.view).x >= 0 else { return false }
        
        // 2. 控制器栈的高度要大于1
        guard self.viewControllers.count > 1 else { return false }
        
        // 3. 不在转场过程中
        guard let isTransitioning = self.value(forKey: "_isTransitioning") as? NSNumber else { return false }
        
        if let _topVC = self.topViewController, _topVC.responds(to: #selector(shouldBePopped)) {
            return _topVC.shouldBePopped(self)
        }
        
        return !isTransitioning.boolValue
    }
    
    /// 控制开始触发右滑返回手势的区域，这里是左边边缘距离 1/30 屏幕宽度范围内都能触发
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self.view)
        return point.x >= 0 && point.x < ceil(UIScreen.main.bounds.size.width/30.0)
    }
    
    /// 解决 scrollView 的滑动手势 和 右滑返回手势 冲突问题
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard otherGestureRecognizer is UIPanGestureRecognizer else {
            return false
        }
        guard let otherGestureView = otherGestureRecognizer.view as? UIScrollView else {
            return false
        }
        guard otherGestureView.bounces && otherGestureView.alwaysBounceHorizontal else {
            guard otherGestureView.bounces && otherGestureView.alwaysBounceVertical else {
                return otherGestureView.contentOffset.x <= 0
            }
            return false
        }
        return otherGestureView.contentOffset.x <= 0
    }
}

/// 遵循这个协议，可以隐藏导航栏
protocol HideNavigationBarProtocol where Self: UIViewController {}

extension LRNavigationViewController: UINavigationControllerDelegate {
    //导航控制器将要显示控制器时调用
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if (viewController is HideNavigationBarProtocol){
            self.setNavigationBarHidden(true, animated: true)
        }else {
            self.setNavigationBarHidden(false, animated: true)
        }
    }
}

// MARK: UINavigationBarDelegate
extension LRNavigationViewController: UINavigationBarDelegate {
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        // The following code is called only when the user taps on the back button.
        guard let vc = topViewController else {
            return false
        }
        
        if vc.responds(to: #selector(shouldBePopped)) {
            return vc.shouldBePopped(self)
        } else {
            return false
        }
    }
}

extension UIViewController {
    @objc func shouldBePopped(_ navigationController: UINavigationController) -> Bool {
        return true
    }
}
