//
//  String+Extension.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/14.
//

import UIKit

extension String {

    func substringFromIndex(index:Int) ->String {
        guard index < self.count else {
            print("超出边界")
            return self
        }
        var tempStr = self
        let subIndex = index < 0 ? 0 : index
        let targetIndex = tempStr.index(tempStr.startIndex, offsetBy: subIndex)
        tempStr.removeSubrange(tempStr.startIndex...targetIndex)
        return tempStr
    }
    
    func substringToIndex(index:Int) ->String {
        guard index < self.count else {
            print("超出边界")
            return self
        }
        let subIndex = index < 0 ? 0 : index
        var tempStr = self
        let targetIndex = tempStr.index(tempStr.startIndex, offsetBy: subIndex)
        tempStr.removeSubrange(targetIndex...)
        return tempStr
    }
    
    func substringWithRange(loc:Int,len:Int) ->String {
        guard loc < self.count else {
            print("裁剪位置超出边界")
            return self
        }
        guard len < self.count else {
            print("裁剪长度超出边界")
            return self
        }
        let subIndex = loc < 0 ? 0 : loc
        let end = subIndex + len - 1
        guard end < self.count else {
            print("裁剪长度超出边界")
            return self
        }
        let tempStr = self
        let startIndex = tempStr.index(tempStr.startIndex, offsetBy: subIndex)
        let endIndex = tempStr.index(tempStr.startIndex, offsetBy: end)
        return String.init(tempStr[startIndex...endIndex])
    }
    
    func stringByReplacingOccurrencesOfString(replaceString:String,targetString:String) ->String {
        guard self.contains(replaceString) else {
            return self
        }
        var tempStr = self
        tempStr = tempStr.replacingOccurrences(of: replaceString, with: targetString)
        return tempStr
    }
    
    func textHeight(font: UIFont, width: CGFloat) -> CGFloat {
        let textH : CGFloat = self.boundingRect(with:CGSize(width: width, height:CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [.font:font], context:nil).size.height
        return textH + 3
    }
    
    func textWidth(font: UIFont, height: CGFloat) -> CGFloat {
        let textW : CGFloat = self.boundingRect(with:CGSize(width: CGFloat(MAXFLOAT), height:height), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [.font:font], context:nil).size.width
        return textW + 3
    }
    
    static func convertDictionaryToString(dict:[String: Any]) -> String {
        var result:String = ""
        do {
            //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                result = JSONString
            }
        } catch {
            result = ""
        }
        return result
    }
    
    static func convertStringToDictionary(text: String) -> [String:Any]? {
      if let data = text.data(using: String.Encoding.utf8) {
          do {
              return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject]
          } catch let error as NSError {
              print(error)
          }
      }
      return nil
    }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension String {
    /// 数字转换万/亿
    func digitalConversionMillionOrBillion() -> String {
        let numberA: NSDecimalNumber = NSDecimalNumber(string: self)
        var numberB: NSDecimalNumber?
        var unitStr: String = ""
        if self.count > 3 && self.count < 7 {
            numberB = NSDecimalNumber(string: "10000")
            unitStr = "W"
        } else if self.count == 7 {
            numberB = NSDecimalNumber(string: "1000000")
            unitStr = "M"
        } else if self.count == 8 {
            numberB = NSDecimalNumber(string: "10000000")
            unitStr = ""
        } else if self.count > 8 {
            numberB = NSDecimalNumber(string: "100000000")
            unitStr = ""
        } else {
            return self
        }
        
        //NSDecimalNumberBehaviors对象的创建  参数 1.RoundingMode 一个取舍枚举值 2.scale 处理范围 3.raiseOnExactness  精确出现异常是否抛出原因 4.raiseOnOverflow  上溢出是否抛出原因  4.raiseOnUnderflow  下溢出是否抛出原因  5.raiseOnDivideByZero  除以0是否抛出原因。
        let behaviors: NSDecimalNumberBehaviors = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.up, scale: 1, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        let convertionStr = numberA.dividing(by: numberB!, withBehavior: behaviors)
        
        return convertionStr.stringValue + unitStr
    }
}
