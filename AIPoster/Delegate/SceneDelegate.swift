//
//  SceneDelegate.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit
import SnapKit
import Toast_Swift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    // 冷启动APP参数
    var appLaunchOptions: UIScene.ConnectionOptions?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard (scene is UIWindowScene) else { return }
        self.window = UIWindow.init(windowScene: scene as! UIWindowScene)
        self.appLaunchOptions = connectionOptions
        // 冷启动配置
        self.coldStartProgramConfiguration()
        // 根控制器设置
        self.setAPPRootController()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        // AD 授权
        delay(0.5) {
            LRDeviceTool.IDFARequest()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        delay(0.2) {
            // 广告
            let isExpired = LRIAPStoreManager.shared.localVerificationSubscriptionExpirationTime()
            // 订阅过期并且是热启动
            if isExpired {
                LRGoogleOpenADManager.shared.tryToPresentAd(adType: GoogleADType.GoogleOpenAD2)
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

// MARK: HSADFullScreenContentDelegate
extension SceneDelegate: HSADFullScreenContentDelegate {
    func hs_adDidDismissFullScreenContent(adType: GoogleADType) {
        if self.appLaunchOptions == nil || adType != .GoogleOpenAD1 {
            Log.debug("前后台切换,展示开屏广告,广告关闭之后不需要再展示订阅页面 -----------")
            return
        }

        // TODO: 展示订阅页面
        self.appLaunchOptions = nil
    }
}

// MARK: Private Methods
private extension SceneDelegate {
    // ------------ 冷启动程序配置 ---------------------
    func coldStartProgramConfiguration() {
        // AppsFlyer 延迟等待ATT 授权
//        LRAppsFlyerStatistics.shared.waitForATTUserAuthorization()
        // 全局 toast 配置
        toastConfig()
        // 开启网络监测
        LRNetStateManager.shared.NetworkStatusListener()
        // Log 日志
        Log.shared.registe(with: .other)
        // 广告缓存
        startAdvertisingCache()
        // IAP监听
        IAPObserver()
    }
    
    // ------------ ToastManager 设置 ----------------
    func toastConfig() {
        ToastManager.shared.duration = 2
        ToastManager.shared.isTapToDismissEnabled = false
        ToastManager.shared.position = .center
    }
    
    // ------------ 冷启动广告缓存 ---------------------
    func startAdvertisingCache() {
        if LRIAPStoreManager.shared.localVerificationSubscriptionExpirationTime() {
            // 开屏广告
            let _ = LRGoogleOpenADManager.shared
            // 插屏广告
            let _ = LRGoogleInterstitialADManager.shared
        } else {
            Log.debug("VIP 未过期不进行冷启动Google 开屏广告的缓存 --------------")
        }
    }
    
    // ------------ 添加IAP监听 ----------------------
    func IAPObserver() {
        if !Device().isSimulator {
            /// 开启IAP订阅回调
            LRIAPStoreManager.shared.addIAPPurchaseObserver()
            /// 订阅订阅成功的通知
            NotificationCenter.default.addObserver(self, selector: #selector(statisticsUserSubscribe(notification:)), name: LRIAPStoreManager.shared.IAPSubscribeSuccessNotification, object: nil)
            
            if LRNetStateManager.shared.netState != .NoNet {
                /// 查询当前是否有订阅,订阅是否过期
                LRIAPStoreManager.shared.IAPSubscribeIsExpired()
            } else {
                Log.debug("+++++++ 当前没有网络不查询 +++++++++")
            }
        }
    }
    
    // ------------ 设置APP根控制器 ----------------------
    func setAPPRootController() {
        self.window?.backgroundColor = MainBGColor
        self.window?.rootViewController = LRTabbarViewController()
//        self.window?.rootViewController = LRStartVideoViewController()
        self.window?.makeKeyAndVisible()
    }
}

