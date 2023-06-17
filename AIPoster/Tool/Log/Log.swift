//
//  Log.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/8/2.
//

import Foundation
import CocoaLumberjack
/// Enum which maps an appropiate symbol which added as prefix for each log message
///
/// - error: Log type error
/// - info: Log type info
/// - debug: Log type debug
/// - verbose: Log type verbose
/// - warning: Log type warning
/// - severe: Log type severe
public enum LogLevel: String {
    case error = "‼️[error]" // error
    case warning = "⚠️[warning]" // warning
    case info = "ℹ️[info]" // info
    case debug = "💬[debug]" // debug
    case verbose = "🔬[verbose]" // verbose
}
/// Build or archive enviroment
public enum EnvType {
    case prod
    case other
}
public func print(_ object: Any) {
    // Only allowing in DEBUG mode
    #if DEBUG
    Swift.print(object)
    #endif
}

class Log: NSObject {
    
    //单例
    static let shared = Log()
    private override init() {}
    
    public func registe(with env: EnvType) {
        
        #if DEBUG
        /// os log (contains xcode console)
        DDLog.add(DDOSLogger.sharedInstance, with: .all) // (iOS10 before)
        //修改Logs文件夹的位置
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as? NSString
        let logDirectory = path?.appendingPathComponent("Log")
        let fileLoggerManagerDefault = LRDDLogFileSub.init(logsDirectory: logDirectory)
        /// file log
        let fileLogger: DDFileLogger = DDFileLogger(logFileManager: fileLoggerManagerDefault) // File Logger
        //重用log文件，不要每次启动都创建新的log文件(默认值是NO)
        fileLogger.doNotReuseLogFiles = false
        //log文件在24小时内有效，超过时间创建新log文件(默认值是24小时)
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        //最多保存7个log文件
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        //log文件夹最多保存20M
        fileLogger.logFileManager.logFilesDiskQuota = 1024*1024*20;
        //禁用文件大小滚动
        fileLogger.maximumFileSize = 0
        // 设置日志格式
        fileLogger.logFormatter = self
        DDLog.add(fileLogger, with: .all)

        #else
        /// file log
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        //重用log文件，不要每次启动都创建新的log文件(默认值是NO)
        fileLogger.doNotReuseLogFiles = false
        //log文件在24小时内有效，超过时间创建新log文件(默认值是24小时)
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        //最多保存7个log文件
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        //log文件夹最多保存20M
        fileLogger.logFileManager.logFilesDiskQuota = 1024*1024*20;
        //禁用文件大小滚动
        fileLogger.maximumFileSize = 0
        if env == .prod {
            DDLog.add(fileLogger, with: .info)
        } else {
            /// os log (contains xcode console)
            DDLog.add(DDASLLogger.sharedInstance, with: .all) // (iOS10 before)
            /// file log
            let fileLogger: DDFileLogger = DDFileLogger() // File Logger
            DDLog.add(fileLogger, with: .all)
        }
        #endif
    }
    
    // MARK: - Loging methods
    
    public class func error( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        DDLogError("GYLOGGER \(LogLevel.error.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
    
    public class func warning( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        DDLogWarn("GYLOGGER \(LogLevel.warning.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
    public class func info( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        DDLogInfo("GYLOGGER \(LogLevel.info.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
    
    public class func debug( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
#if (SHAREEXTENSIONLOG || KEYBOARDEXTENSIONLOG)
        print("GYLOGGER \(LogLevel.debug.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
#else
        DDLogDebug("GYLOGGER \(LogLevel.debug.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
#endif
    }
    
    public class func verbose( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        DDLogVerbose("GYLOGGER \(LogLevel.verbose.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
    
    // MARK: -
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

extension Log: DDLogFormatter {

    func format(message logMessage: DDLogMessage) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss:SSS"
        let timeStamp = dateFormatter.string(from: NSDate.init() as Date)
        
        let formatLog = "\(timeStamp)\n className:\(logMessage.fileName)\n fuction:\(logMessage.function ?? "")\n line:\(logMessage.line)\n \(logMessage.message)";
        return formatLog;
    }
}

extension NSObject {
    public func deallocPrint() {
#if (SHAREEXTENSION || KEYBOARDEXTENSION)
        print("deinit: \(NSStringFromClass(type(of: self)))")
#else
        Log.debug("deinit: \(NSStringFromClass(type(of: self)))")
#endif
    }
}
