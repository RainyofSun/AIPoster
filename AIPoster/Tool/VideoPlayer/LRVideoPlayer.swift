//
//  LRVideoPlayer.swift
//  StorageCleaner
//
//  Created by 苍蓝猛兽 on 2023/4/11.
//

import UIKit
import AVFoundation

protocol VideoPlayProtocol: AnyObject {
    /// 准备开始播放
    func videoReadyToPlay()
    /// 播放完毕
    func videoPlayEnd()
    /// 更新播放进度
    func updateVideoPlayProgress(progress: Float)
    /// 进度更新完毕
    func updateVideoPlayProgressComplete()
}

extension VideoPlayProtocol {
    /// 准备开始播放
    func videoReadyToPlay() {
        Log.debug("默认实现 --------")
    }
}

class LRVideoPlayer: NSObject {

    /// 播放状态
    enum PlayerStatus {
        case Unknown
        case ReadyToPlay
        case Playing
        case Pause
        case Failed
    }
    
    weak open var playDelegate: VideoPlayProtocol?
    
    /// 播放器状态
    open var status: PlayerStatus {
        get {
            return _playerStatus
        }
    }
    
    /// 是否自动开始播放 默认 false
    open var startPlayingAutomatically: Bool = false
    ///视频总时长
    open var totalTimeFormat: String {
        guard let _p = self.player else {
            return "00:00"
        }
        
        if let totalTime = _p.currentItem?.duration {
            return totalTime.positionalTime()
        }
        
        return "00:00"
    }
    
    ///视频播放时长
    open var currentTimeFormat: String {
        guard let _p = self.player else {
            return "00:00"
        }
        
        if let playTime = _p.currentItem?.currentTime() {
            return playTime.positionalTime()
        }
        
        return "00:00"
    }
    
    /// 视频播放进度
    open var playProgress: Float {
        get {
            guard let _p = self.player else {
                return .zero
            }
            
            if let _totalTime = _p.currentItem?.duration, let _playTime = _p.currentItem?.currentTime() {
                let _totalTimeSec = CMTimeGetSeconds(_totalTime)
                let _currentTimeSec = CMTimeGetSeconds(_playTime)
                return Float(_currentTimeSec/_totalTimeSec)
            }
            
            return .zero
        }
    }
    
    /// 视频当前播放时间
    open var currentTime: CMTime {
        get {
            guard let _p = self.player else {
                return .zero
            }
            
            return _p.currentTime()
        }
    }
    
    // 播放器
    private var player: AVPlayer?
    // 多媒体
    private var playerItem: AVPlayerItem?
    // 播放器状态
    private var _playerStatus: PlayerStatus = .Unknown
    // 定时器更新播放进度
    private var _linkTimer: CADisplayLink?
    
    deinit {
        freeLinkTimer()
        freePlayer()
        deallocPrint()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "status" {
            // 资源准备好, 可以播放
            if playerItem.status == .readyToPlay {
                self._playerStatus = .ReadyToPlay
                self.playDelegate?.videoReadyToPlay()
                if self.startPlayingAutomatically {
                    self._playerStatus = .Playing
                    self.resume()
                }
            } else {
                self._playerStatus = .Failed
                print("load error")
            }
        }
    }
    
    // MARK: Public Methods
    public func playWithURL(videoUrl: URL? = nil, URLAsset asset: AVURLAsset? = nil) -> LRVideoPlayView {
        if let _url = videoUrl {
            self.playerItem = AVPlayerItem(url: _url)
        }
        if let _a = asset {
            self.playerItem = AVPlayerItem(asset: _a)
        }
        // 监听它状态的改变,实现kvo的方法
        self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.player = AVPlayer(playerItem: self.playerItem)
        let playerView: LRVideoPlayView = LRVideoPlayView(frame: CGRectZero)
        if let playerLayer = playerView.layer as? AVPlayerLayer {
            playerLayer.player = player
        }
        
        /// 播放结束的通知.
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        return playerView
    }
    
    /// 暂停
    public func pause() {
        self._playerStatus = .Pause
        self.player?.pause()
        freeLinkTimer()
    }
    
    /// 继续
    public func resume() {
        self.player?.play()
        self._playerStatus = .Playing
        buildLinkTimer()
    }
    
    /// 播放进度, 可以给我一个 UISlider,
    public func progress(_ sender: UISlider) {
        let progress: Float64 = Float64(sender.value)
        if (progress <= 0 || progress >= 1) {
            return;
        }
        // 当前视频资源的总时长
        if let totalTime = self.player?.currentItem?.duration {
            let totalSec = CMTimeGetSeconds(totalTime)
            let playTimeSec = totalSec * progress
            let currentTime = CMTimeMake(value: Int64(playTimeSec), timescale: 1)
            self.player?.seek(to: currentTime, completionHandler: { (finished) in
                self.playDelegate?.updateVideoPlayProgressComplete()
            })
        }
    }
    
    /// 给定进度进行播放
    public func seekProcessToPlay(_ time: CMTime, playWithSpecifiedTime play: Bool = true) {
        if (self._playerStatus == .Pause || self._playerStatus == .ReadyToPlay) && play {
            self.resume()
        }
        self.player?.seek(to: time, toleranceBefore: CMTimeMake(value: 1, timescale: 1000), toleranceAfter: CMTimeMake(value: 1, timescale: 1000), completionHandler: { finished in
            self.playDelegate?.updateVideoPlayProgressComplete()
        })
    }
    
    /// 2倍速
    public func rate(_ sender: Any) {
        self.player?.rate = 2.0
    }
    
    /// 静音
    public func muted(_ mute: Bool) {
        self.player?.isMuted = mute
    }
    
    /// 音量
    public func volume(_ sender: UISlider) {
        if (sender.value < 0 || sender.value > 1) {
            return;
        }
        if (sender.value > 0) {
            self.player?.isMuted = false
        }
        self.player?.volume = sender.value
    }
}

// MARK: Private Methods
private extension LRVideoPlayer {
    func freePlayer() {
        self._playerStatus = .Unknown
        self.player?.pause()
        self.player = nil
        self.playerItem?.removeObserver(self, forKeyPath: "status")
        self.playerItem = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // 创建定时器
    func buildLinkTimer() {
        guard _linkTimer == nil else {
            return
        }
        
        _linkTimer = CADisplayLink(target: self, selector: #selector(updateProgress))
        _linkTimer?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    // 释放定时器
    func freeLinkTimer() {
        _linkTimer?.invalidate()
        _linkTimer = nil
    }
}

// MARK: Timer
extension LRVideoPlayer {
    @objc func updateProgress() {
        self.playDelegate?.updateVideoPlayProgress(progress: self.playProgress)
    }
}

// MARK: Notification
extension LRVideoPlayer {
    // 播放完成
    @objc func playToEndTime() {
        self._playerStatus = .Pause
        self.player?.seek(to: CMTime.zero, toleranceBefore: CMTime(value: 1, timescale: 1000), toleranceAfter: CMTime(value: 1, timescale: 1000), completionHandler: { finished in
            self.playDelegate?.videoPlayEnd()
        })
    }
}
