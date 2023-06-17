//
//  UIColor+Extension.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/13.
//

import UIKit

extension UIColor {
    
    struct ColorRGB {
        var R: CGFloat = 0
        var G: CGFloat = 0
        var B: CGFloat = 0
        var A: CGFloat = 1
    }
    
    struct ColorHexString {
        var hex:String = "#FFFFFF"
        var alpha: CGFloat = 1.0
    }
    
    /// 动态创建颜色, 不适合 UITextFiled、 UITextView 这两种控件,这两种空间会实时调用 draw 方法进行绘制,每次绘制的都会回调UIColor的初始化方法,会使CPU的频率升高
    convenience init(light: ColorHexString, dark: ColorHexString) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                return UIColor(hexString: light.hex, alpha: light.alpha)
            case .dark:
                return UIColor(hexString: dark.hex, alpha: dark.alpha)
            @unknown default:
                return UIColor(hexString: light.hex, alpha: light.alpha)
            }
        }
    }
    
    /// 动态创建颜色, 不适合 UITextFiled、 UITextView 这两种控件,这两种空间会实时调用 draw 方法进行绘制,每次绘制的都会回调UIColor的初始化方法,会使CPU的频率升高
    convenience init(lightRGB: ColorRGB, darkRGB: ColorRGB) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                return UIColor(HS_R: lightRGB.R, HS_G: lightRGB.G, HS_B: lightRGB.B, alpha: lightRGB.A)
            case .dark:
                return UIColor(HS_R: darkRGB.R, HS_G: darkRGB.G, HS_B: darkRGB.B, alpha: darkRGB.A)
            @unknown default:
                return UIColor(HS_R: lightRGB.R, HS_G: lightRGB.G, HS_B: lightRGB.B, alpha: lightRGB.A)
            }
        }
    }
    
    convenience init(HS_R:CGFloat, HS_G:CGFloat, HS_B:CGFloat, alpha:CGFloat = 1.0) {
        self.init(red: HS_R/255.0, green: HS_G/255.0, blue: HS_B/255.0, alpha: alpha)
    }
    
    convenience init(hexString: String,alpha: CGFloat = 1.0) {
            let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            let scanner = Scanner(string: hexString)
             
            if hexString.hasPrefix("#") {
                scanner.scanLocation = 1
            }
             
            var color: UInt32 = 0
            scanner.scanHexInt32(&color)
             
            let mask = 0x000000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask
             
            let red   = CGFloat(r) / 255.0
            let green = CGFloat(g) / 255.0
            let blue  = CGFloat(b) / 255.0
             
            self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // UIColor -> Hex String
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
         
        let multiplier = CGFloat(255.999999)
         
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
         
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
    
    
    func geImageWithColor(size: CGSize = CGSize.init(width: 1, height: 1)) -> UIImage? {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor( self.cgColor )
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
