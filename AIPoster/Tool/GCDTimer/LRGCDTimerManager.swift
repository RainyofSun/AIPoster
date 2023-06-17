//
//  LRGCDTimerManager.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/11/25.
//

import UIKit

class LRGCDTimerManager: NSObject {

    typealias actionBlock = ((NSInteger) -> Void)
        
    private static let sharedManager: LRGCDTimerManager = LRGCDTimerManager()
    private var timerObjectCache: Dictionary<String, LRGCDTimer> = Dictionary()
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    private override init() {
        semaphore.signal()
    }
    
    /// 创建全局定时器
    ///
    /// - Parameters:
    ///   - name: 定时器名称
    ///   - interval: 间隔时间
    ///   - delaySecs: 第一次执行延迟时间，默认为0
    ///   - queue: 定时器调用的队列，默认子队列
    ///   - repeats: 是否重复执行，默认true
    ///   - action: 响应
    class func scheduledTimer(name: String, interval: TimeInterval, delaySecs: TimeInterval = 0, queue: DispatchQueue = DispatchQueue.global(), repeats: Bool = true, action:  actionBlock?) {
        var GCDTimer: LRGCDTimer? = timer(name)
        if (GCDTimer != nil) {
            return
        }
        GCDTimer = LRGCDTimer(interval: interval, delaySecs: delaySecs, queue: queue, repeats: repeats, action: action)
        setTimer(GCDTimer!, name)
    }
}

extension LRGCDTimerManager {
    ///开始定时器
    class func start(_ name: String) {
        let GCDTimer: LRGCDTimer? = timer(name)
        GCDTimer?.start()
    }
    ///执行一次定时器
    class func responseOnce(_ name: String) {
        let GCDTimer: LRGCDTimer? = timer(name)
        GCDTimer?.responseOnce()
    }
    ///取消定时器
    class func cancel(_ name: String) {
        let GCDTimer: LRGCDTimer? = timer(name)
        guard let timer = GCDTimer else {
            return
        }
        timer.cancel()
        removeTimer(name)
    }
    ///暂停定时器
    class func suspend(_ name: String) {
        let GCDTimer: LRGCDTimer? = timer(name)
        GCDTimer?.suspend()
    }
    ///恢复定时器
    class func resume(_ name: String) {
        let GCDTimer: LRGCDTimer? = timer(name)
        GCDTimer?.resume()
    }
}

extension LRGCDTimerManager {
    private class func timer(_ name: String) -> LRGCDTimer? {
        sharedManager.semaphore.wait()
        let GCDTimer = sharedManager.timerObjectCache[name]
        sharedManager.semaphore.signal()
        return GCDTimer
    }
    private class func setTimer(_ timer: LRGCDTimer, _ name: String) {
        sharedManager.semaphore.wait()
        sharedManager.timerObjectCache.updateValue(timer, forKey: name)
        sharedManager.semaphore.signal()
    }
    private class func removeTimer(_ name: String) {
        sharedManager.semaphore.wait()
        sharedManager.timerObjectCache.removeValue(forKey: name)
        sharedManager.semaphore.signal()
    }
}
