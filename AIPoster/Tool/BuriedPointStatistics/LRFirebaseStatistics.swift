//
//  LRFirebaseStatistics.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/9/26.
//

import UIKit
import FirebaseCore

class LRFirebaseStatistics: NSObject {

    public static let shared = LRFirebaseStatistics()
    override init() {
        super.init()
        firebaseConfigure()
    }
    
    private func firebaseConfigure() {
        if let _ = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            FirebaseCore.FirebaseApp.configure()
        }
    }
}
