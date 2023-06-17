//
//  LRTabbarViewController.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit

class LRTabbarViewController: UITabBarController {
    
    override var selectedIndex: Int {
        didSet {
            if selectedIndex == 2, let _nav = self.viewControllers?[selectedIndex] as? LRNavigationViewController {
                let _ = self.tabBarController(self, shouldSelect: _nav)
                self.tabBarController(self, didSelect: _nav)
            }
        }
    }
    
    // 友盟统计使用
    private let UMStatisticsValues: [String] = ["tab_home", "tab_discover", "tab_compress", "tab_secretSpace", "tab_setting"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        UITabBar.appearance().backgroundColor = MainBGColor
        UITabBar.appearance().tintColor = MainBGColor
        self.viewControllers = getChildController()
    }
    
    func getChildController() -> [UIViewController] {
        let homeController = LRNavigationViewController(rootViewController: LRAIPosterHomeViewController())
        let AIImageController = LRNavigationViewController(rootViewController: LRAIPosterAIImageViewController())
        let imageEditController = LRNavigationViewController(rootViewController: LRAIPosterImageEditViewController())
        
        homeController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Tab_icon_home_normal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "Tab_icon_home_select")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        homeController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: .zero, bottom: .zero, right: .zero)
        AIImageController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Tab_icon_explore_normal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "Tab_icon_explore_select")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        AIImageController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: .zero, bottom: .zero, right: .zero)
        imageEditController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Tab_icon_history_normal")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "Tab_icon_history_select")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        imageEditController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: .zero, bottom: .zero, right: .zero)
        
        return [homeController, AIImageController, imageEditController]
    }
}

extension LRTabbarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // 震感
        UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light).impactOccurred()
        guard let _nav = viewController as? LRNavigationViewController, let _rootVC = _nav.children.first else {
            return false
        }
        if _rootVC.responds(to: #selector(shouldBeSelected)) {
            return _rootVC.shouldBeSelected(self)
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        // 视频压缩的界面需要广告的关闭回调延迟到手动点击的时刻
//        var _delayCallback: Bool = false
//        if let _nav = viewController as? LRNavigationViewController, let _rootVC = _nav.viewControllers.first {
//            _delayCallback = (_rootVC.className == "LRCompressViewController")
//        }
//        // 展示插屏2
//        LRGoogleInterstitialADManager.shared.showInsertAD(vc: tabBarController, adType: GoogleADType.GoogleInterstitialAD2, whenCloseCallback: _delayCallback)
//        // 友盟统计
//        LRUMengStatistics.event(eventId: UM_HOME_STATTISTICS_EVENT, label: UMStatisticsValues[selectedIndex])
    }
}

// MARK: TabBar 是否可以选中
extension UIViewController {
    @objc func shouldBeSelected(_ tabbarController: LRTabbarViewController) -> Bool {
        return true
    }
}
