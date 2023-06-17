//
//  LRLoopVideoPlayer.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/3/25.
//

import UIKit
import AVFoundation

class LRLoopVideoPlayer: NSObject {
    
    private var queuePlayer: AVQueuePlayer?
    private var playerItem: AVPlayerItem?
    private var loopPlayer: AVPlayerLooper?
    
    deinit {
        if self.playerItem?.observationInfo != nil {
            self.playerItem?.removeObserver(self, forKeyPath: "status")
        }
        self.queuePlayer?.pause()
        self.queuePlayer?.removeAllItems()
        self.queuePlayer = nil
        self.loopPlayer = nil
        self.playerItem = nil
        deallocPrint()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "status" {
            // 资源准备好, 可以播放
            if playerItem.status == .readyToPlay {
                self.queuePlayer?.play()
            } else {
                print("load error")
            }
        }
    }
    
    // MARK: Public Methods
    /// 循环播放网络视频
    public func playWebVideosLoop(_ videoUrl: String) -> AVPlayerLayer {
        let playerItem: AVPlayerItem = buildURLItem(url: videoUrl)
        // 监听它状态的改变,实现kvo的方法
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        let queuePlayer: AVQueuePlayer = AVQueuePlayer(playerItem: playerItem)
        let loopPlayer: AVPlayerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        self.queuePlayer = queuePlayer
        self.loopPlayer = loopPlayer
        self.playerItem = playerItem
        let playerLayer: AVPlayerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }
    
    /// 循环播放本地视频
    public func playLocalVideosLoop(_ localFilePath: String) -> AVPlayerLayer? {
        let playerItem: AVPlayerItem = buildLocalFileItem(videoPath: localFilePath)
        let queuePlayer: AVQueuePlayer = AVQueuePlayer(playerItem: playerItem)
        let loopPlayer: AVPlayerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        self.queuePlayer = queuePlayer
        self.loopPlayer = loopPlayer
        let playerLayer: AVPlayerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.videoGravity = .resizeAspectFill
        self.queuePlayer?.play()
        return playerLayer
    }
    
    /// 暂停
    public func pause() {
        self.queuePlayer?.pause()
    }
    
    /// 继续
    public func resume() {
        self.queuePlayer?.play()
    }
}

// MARK: Private Methods
private extension LRLoopVideoPlayer {
    
    // 根据URL播放网络文件
    func buildURLItem(url: String) -> AVPlayerItem {
        return AVPlayerItem(url: URL.init(string: url)!)
    }
    
    // 加载本地的视频文件
    func buildLocalFileItem(videoPath: String) -> AVPlayerItem {
        return AVPlayerItem(url: URL(fileURLWithPath: videoPath))
    }
}
