//
//  NSObject+Extension.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/13.
//

import UIKit

extension NSObject {
    func getCleanHostWindow() -> UIWindow {
        let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).last
        return window!
    }
    
    // MARK:返回className
    var className:String{
        get{
          let name =  type(of: self).description()
            if(name.contains(".")){
                return name.components(separatedBy: ".")[1];
            }else{
                return name;
            }
        }
    }
    
    // 取出某个对象的地址
    private func sg_getAnyObjectMemoryAddress(object: AnyObject) -> String {
        let str = Unmanaged<AnyObject>.passUnretained(object).toOpaque()
        return String(describing: str)
    }

    // 对比两个对象的地址是否相同
    public func sg_equateableAnyObject(object: AnyObject) -> Bool {
        let str1 = sg_getAnyObjectMemoryAddress(object: self)
        let str2 = sg_getAnyObjectMemoryAddress(object: object)
        return (str1 == str2)
    }
}
