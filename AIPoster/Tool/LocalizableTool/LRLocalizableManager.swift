//
//  LRLocalizableManager.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/7/29.
//

import UIKit

enum LanguageType {
    case chinese,english,auto
}

// MARK: 单例 -- 管理多语言
class LRLocalizableManager: NSObject {
    /// 加载多语言
    static func localValue(_ str:String) -> String {
        LRLocalizableManager.shared.localValue(str: str)
    }
    /// 设置语言类别
    static func setLanguage(_ type:LanguageType){
        LRLocalizableManager.shared.setLanguage(type)
    }
    /// 语言改变时的通知回调
    final var LanguageChangedKey = "LanguageChangedKey"
    
    //单例
    static let shared = LRLocalizableManager()
    
    private override init() {}
    
    private var bundle:Bundle = Bundle.main
    
    private func localValue(str:String) -> String{
        //table参数值传nil也是可以的，传nil系统就会默认为Localizable
        bundle.localizedString(forKey: str, value: nil, table: "Localizable")
    }

    private func setLanguage(_ type:LanguageType){
        var typeStr = ""
        switch type {
        case .chinese:
            // 简体中文
            typeStr = "zh-Hans"
            UserDefaults.standard.setValue("zh-Hans", forKey: "language")
        case .english:
            typeStr = "en"
            UserDefaults.standard.setValue("en", forKey: "language")
        default:
            typeStr = String(format: "%@-%@", Locale.current.languageCode ?? "en",Locale.current.scriptCode ?? "")
        }
        //返回项目中 en.lproj 文件的路径
        var path = Bundle.main.path(forResource: typeStr, ofType: "lproj")
        if path == nil {
            path = Bundle.main.path(forResource: "en", ofType: "lproj")
        }
        //用这个路径生成新的bundle
        bundle = Bundle(path: path!)!
        if type == .auto {
            //和系统语言一致
            bundle = Bundle.main
            UserDefaults.standard.removeObject(forKey: "language")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: LanguageChangedKey), object: nil)
    }
}
