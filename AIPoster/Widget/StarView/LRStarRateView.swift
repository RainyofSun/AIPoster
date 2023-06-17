//
//  LRStarRateView.swift
//  HSTranslation
//
//  Created by 苍蓝猛兽 on 2023/2/8.
//

import UIKit

protocol StarReteViewDelegate: AnyObject {
    //返回星星评分的分值
    func starRate(view starRateView:LRStarRateView,count:Float)
}
 
extension StarReteViewDelegate {
    func starRate(view starRateView:LRStarRateView,count:Float) {
        print("默认实现 -----------")
    }
}

//星星评分规则：1颗星==1分
class LRStarRateView: UIView {
    weak open var delegate:StarReteViewDelegate?
    
    var integerStar:Bool = true{//整星，defualt is true
        didSet{
            showStarRate()
        }
    }
    var userPanEnabled:Bool = false{//滑动,defualt is false
        didSet{
            if userPanEnabled {
                let pan = UIPanGestureRecognizer(target: self,action: #selector(starPan(_:)))
                addGestureRecognizer(pan)
            }
        }
    }
    
    var _followDuration:TimeInterval = 0.1//默认跟随时间为0.1秒
    var followDuration:TimeInterval{
        set{
            _followDuration = newValue
        }get{
            return _followDuration
        }
    }
    
    fileprivate var starForegroundView:UIView?
    var _currentStarCount:Float = 0 //当前的星星数量，defualt is 0
    var currentStarCount:Float{
        set{
            _currentStarCount = newValue
            showStarRate()
        }
        get{
            return Float(String(format: "%.1f", _currentStarCount)) ?? _currentStarCount
        }
    }
    
    var _minStarCount: Float = .zero // 默认最低的评分
    var minStarCount: Float {
        set {
            _minStarCount = newValue
        }
        get {
            return _minStarCount
        }
    }
    
    fileprivate var starBackgroundView:UIView?
    fileprivate var _numberOfStars:Int = 5//星星总数量，defualt is 5
    fileprivate var numberOfStars:Int{
        set{
            _numberOfStars = newValue
        }
        get{
            return _numberOfStars
        }
    }


// MARK: - 对象实例化
    convenience init(frame: CGRect, bottomStar: String = "ad_icon_star_empty", topStar: String = "ad_icon_star_full") {
       self.init(frame: frame,numberOfStars:5,currentStarCount:0.0, bottomStar: bottomStar, topStar: topStar)
    }
    
    init(frame: CGRect,numberOfStars:Int,currentStarCount:Float, bottomStar: String, topStar: String) {
        super.init(frame: frame)
        self.numberOfStars = numberOfStars
        self.currentStarCount = currentStarCount
        clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self,action: #selector(starTap(_:)))
        addGestureRecognizer(tap)
        
        starBackgroundView = starViewWithImageName(bottomStar)
        addSubview(starBackgroundView!)
        
        starForegroundView = starViewWithImageName(topStar)
        addSubview(starForegroundView!)

        showStarRate()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - 绘制星星UI
    fileprivate func starViewWithImageName(_ imageName:String) -> UIView {
        let starView = UIView.init(frame: bounds)
        starView.clipsToBounds = true
        //添加星星
        let width = frame.width / CGFloat(numberOfStars)
        for index in 0...numberOfStars {
            let imageView = UIImageView.init(frame: CGRect(x:CGFloat(index) * width,y: 0,width:width,height:bounds.size.height))
            imageView.image = UIImage(named: imageName)
            starView.addSubview(imageView)
        }
        return starView
    }
    
    //显示评分
    fileprivate func showStarRate(){
        if self.currentStarCount <= _minStarCount {
            print("已经达到了最低分标准 \(self.currentStarCount) --------------")
            return
        }

        backSorce()
        
        var width: CGFloat = .zero
        if !self.integerStar{//支持非整星评分
            width = self.width / CGFloat(self.numberOfStars) * CGFloat(self.currentStarCount)
        } else {//只支持整星评分
            width = self.width / CGFloat(self.numberOfStars) * CGFloat(ceil(self.currentStarCount))
        }
        
        UIView.animate(withDuration: self.followDuration, animations: {
            self.starForegroundView?.width = width
        })
    }
    
    //MARK: - 手势交互
    //滑动评分
    @objc func starPan(_ recognizer:UIPanGestureRecognizer) -> () {
        var OffX:CGFloat = 0
        if recognizer.state == .began{
            OffX = recognizer.location(in: self).x
        }else if recognizer.state == .changed{
            OffX += recognizer.location(in: self).x
        }else{
            return
        }
        currentStarCount = Float(OffX) / Float(bounds.width) * Float(numberOfStars)
    }
    
    //点击评分
    @objc func starTap(_ recognizer:UITapGestureRecognizer) -> () {
        let OffX = recognizer.location(in: self).x
        currentStarCount = Float(OffX) / Float(bounds.width) * Float(numberOfStars)
    }
    
    //MARK: - 协议回调/返回星星数
    fileprivate func backSorce(){
        if (delegate != nil) {
            var newScore:Float =  integerStar ? Float(ceil(self.currentStarCount)) :currentStarCount
            if  newScore > Float(numberOfStars){
                newScore = Float(numberOfStars)
            }else if newScore < 0{
                newScore = 0
            }
            //协议代理
            delegate?.starRate(view: self, count: newScore)
        }
    }
}

