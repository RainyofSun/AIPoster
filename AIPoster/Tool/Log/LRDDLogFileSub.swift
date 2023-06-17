//
//  LRDDLogFileSub.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/10/27.
//

import UIKit
import CocoaLumberjack

/// 重写文件名
class LRDDLogFileSub: DDLogFileManagerDefault {
    
    override func isLogFile(withName fileName: String) -> Bool {
        let hasSuffix = fileName.hasSuffix(".log")
        return hasSuffix
    }
    
    override var newLogFileName: String{
        get{ self.creatNewLogFileName() }
        set{}
    }
    
    func creatNewLogFileName() -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd HH.mm.ss"
        let timeStamp = dateFormatter.string(from: NSDate.init() as Date)

        let disPlayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
        return "\(disPlayName!)\(timeStamp).log"
    }
}
