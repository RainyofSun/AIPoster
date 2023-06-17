//
//  LRChatBootChatCache.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/6/1.
//

import UIKit

class LRChatBootChatCache: LRUserDefaultCacheBase {
    /// 存储静音播放设置
    public class func saveSpeechMute(isMute: Bool) {
        standardCache(value: isMute, key: ChatBootSpeechMuteKey)
    }
    
    /// 读取静音播放设置
    public class func readSpeechMute() -> Bool {
        if let _value = standardRead(key: ChatBootSpeechMuteKey) as? Bool {
            return _value
        }
        return false
    }
    
    /// 重置静音播放设置
    public class func deleteSpeechMute() {
        standardDelete(key: ChatBootSpeechMuteKey)
    }
}
