platform :ios, '16.0'
inhibit_all_warnings!
use_frameworks!

# 定义公共库
def CommonPods
  pod 'CocoaLumberjack/Swift'
  pod 'HandyJSON', '5.0.2'
  pod 'Moya', '15.0.0'
  pod 'SnapKit', '5.6.0'
  pod 'CryptoSwift', '1.5.1'
  pod 'WCDB.swift', '2.0.1'
  pod 'SwiftyJSON', '4.3.0'
  pod 'Toast-Swift', '5.0.1'
  pod 'lottie-ios', '3.4.1'
  pod 'Reachability', '3.2'
  pod 'Kingfisher', '7.3.0'
  pod 'MZRefresh', '0.0.5'
end

# 主工程引用的库
def HostAPPPods
  # IAP
  pod 'SwiftyStoreKit', '0.16.1'
  # 广告
#  pod 'Google-Mobile-Ads-SDK', '9.7.0'
  # 推送
#  pod 'FirebaseMessaging', '9.6.0'
  # 统计
#  pod 'FBSDKCoreKit', '14.1.0'
#  pod 'AppsFlyerFramework', '6.8.0'
#  pod 'FirebaseAnalytics', '9.3.0'
  # 友盟基础库
#  pod 'UMCommon', '7.4.1'
#  pod 'UMDevice', '3.1.0'
#  pod 'UMAPM', '1.8.2'

  # 友盟Log
#  pod 'UMCCommonLog', '2.0.2'
  # 钥匙串
  pod 'KeychainSwift', '20.0.0'
  
end

target 'AIPoster' do 
  CommonPods()
  HostAPPPods()
end

# 解决Cocopods Xcode 14.0 pod 报错
# https://www.jianshu.com/p/58d3202411c0
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["DEVELOPMENT_TEAM"] = "ZKAHWC98CR"
      end
    end
  end
end

