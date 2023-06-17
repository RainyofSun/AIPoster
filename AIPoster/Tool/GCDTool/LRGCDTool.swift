//
//  LRGCDTool.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/13.
//

import UIKit

/// 延迟执行
public func delay(_ time: Double, block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time) { block() }
}

/// 在 global 线程执行
public func exchangeGlobalQueue(_ handle: @escaping () -> Void) {
    if Thread.isMainThread {
        DispatchQueue.global().async {
            handle()
        }
    } else {
        handle()
    }
}

/// 在主线程执行
public func exchangeMainQueue(_ handle: @escaping () -> Void) {
    if Thread.isMainThread {
        handle()
    } else {
        DispatchQueue.main.async {
            handle()
        }
    }
}
