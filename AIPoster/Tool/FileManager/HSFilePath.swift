//
//  HSFilePath.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/8/4.
//

import Foundation

class FileSystem {
    static let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    
    static let cacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()

    static let downloadDirectory: URL = {
        let directory: URL = FileSystem.documentsDirectory.appendingPathComponent("Download")
        return directory
    }()
    static let videoDirectory: URL = {
        let directory: URL = FileSystem.documentsDirectory.appendingPathComponent("video")
        return directory
    }()
}

class HSFilePath: NSObject {
    static let shared = HSFilePath()
    override init() {}
    
    private static func documentPath() -> String {
        guard let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return "" }
        return document
    }
    
    public static func filePath(_ path: String) -> String {
        let filePath = documentPath() + "/" + path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) == false {
            fileManager.createFile(atPath: filePath, contents: nil)
        }
        return filePath
    }
    
    public static func fileExist(_ filePath: String) -> Bool {
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    public static func removeFile(_ filePath: String) {
        if filePath.isEmpty {
            Log.error("++++++++ 路径为空 +++++++")
            return
        }
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch  {
                Log.error(error)
            }
        }
    }
    
    public static func moveFile(from oldFile: String,to newFile: String) -> String? {
        let oldPath = FileSystem.documentsDirectory.appendingPathComponent(oldFile).path
        let newPath = FileSystem.videoDirectory.appendingPathComponent(newFile).path
        do {
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: FileSystem.videoDirectory.path) {
                try fileManager.createDirectory(at: FileSystem.videoDirectory, withIntermediateDirectories: true)
            }
            if !fileManager.fileExists(atPath: newPath) {
                try fileManager.moveItem(atPath: oldPath, toPath: newPath)
                return newFile
            }
        } catch {
            Log.error(error.localizedDescription)
        }
        return nil
    }
}
