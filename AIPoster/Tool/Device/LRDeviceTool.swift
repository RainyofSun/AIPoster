//
//  LRCleanDeviceTool.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/13.
//

import UIKit
import AppTrackingTransparency
import AdSupport

class LRDeviceTool: NSObject {
    // MARK: - idfa
    /// 获取当前设备的IDFA
    @discardableResult
    static func getIDFA() -> Dictionary<String,String> {
        var idfaStr: String = ""
        var idfaStatus: String = "0"
        if #available(iOS 14, *) {
            let status: ATTrackingManager.AuthorizationStatus = ATTrackingManager.trackingAuthorizationStatus
            if status == .notDetermined {
                // 用户未选择或者未弹窗
                let sem: DispatchSemaphore = DispatchSemaphore.init(value: 0)
                ATTrackingManager.requestTrackingAuthorization { (status: ATTrackingManager.AuthorizationStatus) in
                    if status == .authorized {
                        // 用户允许
                        idfaStr = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    }
                    LRFacebookStatistics.shared.advertiserTrackingEnabled(open: (status == .authorized))
                    idfaStatus = String(status.rawValue)
                    sem.signal()
                }
                let _ = sem.wait(timeout: .distantFuture)
            } else if status == .authorized {
                idfaStr = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                LRFacebookStatistics.shared.advertiserTrackingEnabled(open: true)
                idfaStatus = String(status.rawValue)
            } else {
                idfaStr = "请在设置-隐私-Tracking中允许App请求跟踪"
                LRFacebookStatistics.shared.advertiserTrackingEnabled(open: false)
                idfaStatus = String(status.rawValue)
            }
        } else {
            // iOS13及之前版本，继续用以前的方式
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                idfaStr = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                LRFacebookStatistics.shared.advertiserTrackingEnabled(open: true)
                idfaStatus = "2"
            } else {
                idfaStr = "请在设置-隐私-Tracking中允许App请求跟踪"
                LRFacebookStatistics.shared.advertiserTrackingEnabled(open: false)
                idfaStatus = "3"
            }
        }
        Log.debug("+++++++ \n IDFA = \(idfaStr)\nTrackingStatus = \(idfaStatus) \n ++++++++++++")
        return ["idfa":idfaStr,"trackingStatus":idfaStatus]
    }
    
    /// 获取当前IDFA不阻塞线程
    static func IDFARequest() {
        if #available(iOS 14, *) {
            let status: ATTrackingManager.AuthorizationStatus = ATTrackingManager.trackingAuthorizationStatus
            if status == .notDetermined {
                // 用户未选择或者未弹窗
                ATTrackingManager.requestTrackingAuthorization { (status: ATTrackingManager.AuthorizationStatus) in
                    if status == .authorized {
                        Log.debug("用户授予了APP Tracking Authorization ----------")
                    }
                    LRFacebookStatistics.shared.advertiserTrackingEnabled(open: (status == .authorized))
                }
            } else if status == .authorized {
                LRFacebookStatistics.shared.advertiserTrackingEnabled(open: true)
            } else {
                LRFacebookStatistics.shared.advertiserTrackingEnabled(open: false)
            }
        }
    }
    
    /// 获取本地版本号
    class public func getLocalVersion() -> String {
        var localVersion:String = ""
        //当前版本
        if let v:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String{
            localVersion = v
        }
        return localVersion
    }
    
    /// 获取当前设备IP
    class func getOperatorsIP() -> String? {
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first
    }
}
