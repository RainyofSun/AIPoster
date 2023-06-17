//
//  LRHostAppBundleResource.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/8/17.
//

import UIKit

class LRHostAppBundleResource: LRBundleResourceBase {
    /// 大图片从bundle中以文件的形式加载
    public class func bundleImageResource(resourceName: String, directoryName: String = "BigImg") -> UIImage {
        
        guard let imgPath = getFilePath(resourceName: resourceName, resourceType: "png", resourceDirectory: directoryName) else {
            return UIImage.init()
        }
        return UIImage.init(contentsOfFile: imgPath)!
    }
    
    /// 大文件从bundle中加载
    public class func bundlePlistFileResource(resourceName: String) -> Any? {
        
        guard let filePath = getFilePath(resourceName: resourceName, resourceType: "plist", resourceDirectory: "FilePlist") else {
            return nil
        }
        guard let arraySource: NSArray = NSArray(contentsOfFile: filePath), arraySource.count != 0 else {
            guard let dictSource: NSDictionary = NSDictionary(contentsOfFile: filePath), dictSource.count != 0 else {
                return nil
            }
            return dictSource
        }
        return arraySource
    }
    
    /// 启动视频路径
    public class func appStartVideoPath(resourceName: String) -> String? {
        return getFilePath(resourceName: resourceName, resourceType: "mp4", resourceDirectory: "Launcher")
    }
}
