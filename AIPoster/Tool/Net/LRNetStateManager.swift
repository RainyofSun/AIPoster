//
//  LRNetStateManager.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/9/5.
//

import UIKit
import Reachability
import CoreTelephony

//MARK: 网络状态监测
class LRNetStateManager: NSObject {
    
    enum NetStatus {
        case WIFI
        case Cellular
        case LTE
        case EDGE
        case NoNet
    }
    
    //单例
    static let shared = LRNetStateManager()
    private override init() {}
    
    private(set) var netState: NetStatus = .NoNet
    
    // Reachability必须一直存在，所以需要设置为全局变量
    private let reachability = Reachability.forInternetConnection()
    
    /***** 网络状态监听部分（开始） *****/
    public func NetworkStatusListener() {
        // 设置初始状态
        setNetState(reach: reachability!)
        // 1、设置网络状态消息监听 2、获得网络Reachability对象
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: Notification.Name.reachabilityChanged,object: reachability)
        // 3、开启网络状态消息监听
        reachability?.startNotifier()
    }
    
    private func setNetState(reach: Reachability) {
        if reach.isReachable() { // 判断网络连接状态
            if reach.isReachableViaWiFi() {
                self.netState = .WIFI
            } else {
                self.netState = .Cellular
            }
        } else {
            checkConnection()
        }
    }
    
    private func checkConnection() {
        let telephonyInfo = CTTelephonyNetworkInfo()
        guard let currentConnection = telephonyInfo.currentRadioAccessTechnology else {
            self.netState = .NoNet
            return
        }
        if (currentConnection == CTRadioAccessTechnologyLTE) { // Connected to LTE
            self.netState = .LTE
        } else if(currentConnection == CTRadioAccessTechnologyEdge) { // Connected to EDGE
            self.netState = .EDGE
        } else { // Connected to 3G
            self.netState = .NoNet
        }
    }
    
    // 主动检测网络状态
    @objc func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        setNetState(reach: reachability)
        Log.debug("+++++++++++ 当前网络状态: \(self.netState)++++++++++++++")
        NotificationCenter.default.post(name: .APPNetStateNotification, object: self.netState)
    }
}
