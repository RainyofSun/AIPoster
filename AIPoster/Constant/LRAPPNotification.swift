//
//  LRAPPNotification.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/14.
//

import UIKit

/// 消息通知
extension Notification.Name {
    
    // 网络状态通知
    public static let APPNetStateNotification = Notification.Name("com.AIChat.notification.name.net.appNetState")
    // 退出聊天室通知
    public static let APPExitChatRoomNotification = Notification.Name("com.AIChat.notification.name.exitRoom")
    // 聊天室语音准备播放通知
    public static let APPChatReadyPlayNotification = Notification.Name("com.AIChat.notification.name.readyPlay")
}
