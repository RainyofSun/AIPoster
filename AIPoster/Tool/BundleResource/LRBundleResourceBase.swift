//
//  LRBundleResourceBase.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/11/10.
//

import UIKit

// MARK: 获取bundle资源
class LRBundleResourceBase: NSObject {
    /// 获取文件路径 默认bundle是宿主应用的bundle
    public class func getFilePath(resourceName: String, resourceType: String = "png", resourceDirectory:String = "", bundleName: String = "ResourceBundle") -> String? {
        guard let bundlePath: String = Bundle.main.path(forResource: bundleName, ofType:"bundle") else {
            return nil
        }
        let bundle: Bundle = Bundle.init(path: bundlePath)!
        if resourceDirectory.isEmpty {
            guard let filePath = bundle.path(forResource: resourceName, ofType: resourceType) else {
                return nil
            }
            return filePath
        } else {
            guard let filePath = bundle.path(forResource: resourceName, ofType: resourceType, inDirectory: resourceDirectory) else {
                return nil
            }
            return filePath
        }
    }
}
