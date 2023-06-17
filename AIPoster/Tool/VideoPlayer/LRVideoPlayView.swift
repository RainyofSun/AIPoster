//
//  LRVideoPlayView.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2022/9/26.
//

import UIKit
import AVKit

class LRVideoPlayView: UIView {

    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let _viewLayer = self.layer as? AVPlayerLayer {
            _viewLayer.videoGravity = .resizeAspectFill
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocPrint()
    }

}
