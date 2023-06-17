//
//  CMTime+Extension.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/4/12.
//

import UIKit
import AVFoundation

extension CMTime {
    /// 时间格式转换 (--:--:--)
    /// showHours 当 hour 小于0时 是否显示
    func positionalTime(showHours: Bool = false) -> String {
        let roundedSeconds: TimeInterval = seconds.rounded()
        let hours:  Int = Int(roundedSeconds / 3600)
        let minute: Int = Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let second: Int = Int(roundedSeconds.truncatingRemainder(dividingBy: 60))
        if showHours {
            return String(format: "%02d:%02d:%02d", hours, minute, second)
        }
        return hours > 0 ? String(format: "%d:%02d:%02d", hours, minute, second) : String(format: "%02d:%02d", minute, second)
    }
}
