//
//  UIView+FrameExtension.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/2/13.
//

import UIKit

extension UIView {
    public var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    public var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    public var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    public var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    public var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
    
    public var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame.origin = newValue
        }
    }
    
    public var centerY: CGFloat {
        get {
            return frame.size.height * 0.5 + frame.origin.y
        }
        set {
            frame.origin.y = newValue - frame.height * 0.5
        }
    }
    
    public var centerX: CGFloat {
        get {
            return frame.size.width * 0.5 + frame.origin.x
        }
        set {
            frame.origin.x = newValue - frame.width * 0.5
        }
    }
}
