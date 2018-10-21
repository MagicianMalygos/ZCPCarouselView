//
//  ZCPCarouselView.swift
//  SwiftTest
//
//  Created by 朱超鹏 on 2018/10/12.
//  Copyright © 2018年 zcp. All rights reserved.
//

import UIKit

///// 轮播图图片切换模式
//public enum ZCPCarouselScrollMode {
//    /// 滚动模式
//    case scroll
//    /// 淡入淡出模式
//    case fade
//}

/// 轮播图页码控制器切换模式
public enum ZCPCarouselPageControlChangeMode {
    /// 整页切换
    case full
    /// 半页切换
    case half
}

/// 轮播图数据源协议
@objc public protocol ZCPCarouselDataSource: NSObjectProtocol {
    /// 返回图片个数
    ///
    /// - Parameter carouselView: 轮播图
    /// - Returns: 数据源图片个数
    @objc optional func numberOfImagesInCarouselView(_ carouselView: ZCPCarouselView) -> Int
    /// 返回指定位置上的图片
    ///
    /// - Parameters:
    ///   - carouselView: 轮播图
    ///   - index: 指定位置
    /// - Returns: 指定位置上的图片（可返回String、UIImage、Data）
    @objc optional func carouselView(_ carouselView: ZCPCarouselView, imageAt index: Int) -> Any
    /// 返回指定位置上的默认图
    ///
    /// - Parameters:
    ///   - carouselView: 轮播图
    ///   - index: 指定位置
    /// - Returns: 指定位置上的默认图
    @objc optional func carouselView(_ carouselView: ZCPCarouselView, defaultImageAt index: Int) -> UIImage?
    /// 返回指定位置图片上的附加视图
    ///
    /// - Parameters:
    ///   - carouselView: 轮播图
    ///   - imageView: 指定图片
    ///   - index: 指定位置
    /// - Returns: 指定位置图片上的附加视图
    @objc optional func carouselView(_ carouselView: ZCPCarouselView, additionalViewFor imageView: UIImageView, at index: Int) -> UIView?
}

/// 轮播图滚动方向
public enum ZCPCarouselAutoScrollDirection {
    /// 向左滚动
    case left
    /// 向右滚动
    case right
}

/// 轮播图下载器协议
public protocol ZCPCarouselDownloaderProtocol: NSObjectProtocol {
    /// 根据给定的图片链接下载图片
    ///
    /// - Parameters:
    ///   - urlString: 图片链接
    ///   - block: 下载完成执行的block，用于返回UIImage对象
    func downloadImage(_ urlString: String?, _ block: @escaping (_ image: UIImage) -> Void)
}

/// 轮播图页面控制器协议
public protocol ZCPCarouselPageControlProtocol: NSObjectProtocol {
    var numberOfPages: Int { get set }
    var currentPage: Int { get set }
}

extension UIPageControl: ZCPCarouselPageControlProtocol {
    
}

/// 轮播图回调协议
@objc public protocol ZCPCarouselDelegate: NSObjectProtocol {
    /// 点击当前图片
    ///
    /// - Parameters:
    ///   - carouselView: 轮播图
    ///   - index: 当前图片索引
    @objc optional func carouselView(_ carouselView: ZCPCarouselView, didSelectImageAt index: Int)
    /// 滑动时响应
    ///
    /// - Parameters:
    ///   - carouselView: 轮播视图
    ///   - offSetX: 滑动当前图片的偏移量
    ///   - ratio: 滑动当前图片的偏移量比例，值为offSetX/imageWidth，范围为[-1, 1]
    @objc optional func carouselView(_ carouselView: ZCPCarouselView,  didScrollTo offSetX: CGFloat, _ ratio: CGFloat)
    /// 整页切换到下张图时响应
    ///
    /// - Parameters:
    ///   - carouselView: 轮播图
    ///   - index: 图片索引
    @objc optional func carouselView(_ carouselView: ZCPCarouselView,  didChangeImageAt index: Int)
}

/// 轮播图
public class ZCPCarouselView: UIView, UIScrollViewDelegate {
    
    // MARK: public property
    /// 数据源
    public var imageArray: Array<Any>! { didSet { updateImageArray(imageArray) } }
    /// 缺省图
    public var placeholderImage: UIImage?
    
    /// 是否开启自动滚动
    public var isAutoScroll: Bool = false { didSet { if isAutoScroll { startTimer() } } }
    /// 自动滚动的方向
    public var autoScrollDirection: ZCPCarouselAutoScrollDirection = .left
    /// 自动滚动的时间间隔
    public var autoScrollDuration: TimeInterval = 1 {
        didSet {
            // 使用了NSTimer，如果时间间隔有更新，需要重启定时器
            if let t = timer, t.timeInterval != autoScrollDuration {
                startTimer()
            }
        }
    }
    
    /// 前一个要显示图片的索引
    public var preImageIndex: Int {
        get { return preIndex_new }
    }
    /// 当前显示图片的索引
    public var currImageIndex: Int {
        get { return currIndex_new }
        set { setCurrImageIndex(newValue) }
    }
    /// 下一个要显示图片的索引
    public var nextImageIndex: Int {
        get { return nextIndex_new }
    }
    
    /// 数据源
    open var dataSource: ZCPCarouselDataSource?
    /// 代理
    open var delegate: ZCPCarouselDelegate?
    /// 下载器（图片的下载（缓存）放到外部去做，可以无关如何下载，只要安安稳稳的加载图片即可）
    open lazy var downloader: ZCPCarouselDownloaderProtocol = {
        return ZCPCarouselDownloader()
    }()
    /// 页码控制视图
    open var pageControl: (UIView & ZCPCarouselPageControlProtocol)? {
        didSet {
            oldValue?.removeFromSuperview()
            addSubview(pageControl!)
            if let map = imageMap {
                pageControl!.numberOfPages = map.count
                pageControl!.currentPage = currIndex_new
            }
        }
    }
    /// 页码控制器切换模式
    var pageControlChangeMode: ZCPCarouselPageControlChangeMode = .full
    
    // MARK: private property
    // private （这里的内容可以整一个基类+协议，两个子类分别处理2图片和3图片的情况）
    /// 位置-图片Map
    private var imageMap: Dictionary<Int, UIImage>?
    /// 位置-默认图Map
    private var defaultImageMap: Dictionary<Int, UIImage>?

    /// 前一个要显示图片的索引
    private var preIndex_new: Int = 0
    /// 当前显示图片的索引
    private var currIndex_new: Int = 0 { didSet { updateIndex() } }
    /// 下一个要显示图片的索引
    private var nextIndex_new: Int = 0

    /// 定时器
    private var timer: Timer?
    /// (fixbug)标记手动操作contentOffset，为true时didScroll回调不处理本次操作。didScroll回调的执行与手动操作contentOffset是同步操作所以可以这样搞。
    private var manualSetContentOffsetFlag = false
    
    /// 滚动视图
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.scrollsToTop = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    /// 当前显示的图片视图
    private lazy var currImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.clipsToBounds = true
        return imageView
    }()
    /// 辅助图片视图
    private lazy var otherImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - life cycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.addSubview(currImageView)
        scrollView.addSubview(otherImageView)
        
        // delegate
        scrollView.delegate = self
        // event
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickImage)))
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = self.bounds
        setScrollViewContentSize()
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            // remove
            stopTimer()
        } else {
            // add
            if isAutoScroll {
                startTimer()
            }
        }
    }
    
    // MARK: - 设置
    
    /// 设置滚动视图的contentSize
    func setScrollViewContentSize() {
        if let imgs = imageMap, imgs.count > 1 {
            scrollView.contentSize = CGSize(width: scrollView.frame.width * 5, height: scrollView.frame.height)
            scrollView.contentOffset = CGPoint(x: scrollView.frame.width * 2, y: 0)
            currImageView.frame = CGRect(x: scrollView.frame.width * 2, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        } else {
            // 只有一张图片时，scrollview不能滚动，关闭定时器
            scrollView.contentSize = .zero
            scrollView.contentOffset = .zero
            currImageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            stopTimer()
        }
    }
    /// 设置图片的内容模式
    func setContentMode(_ contentMode: UIView.ContentMode) {
        currImageView.contentMode = contentMode
        otherImageView.contentMode = contentMode
    }
    /// 更新数据源
    func updateImageArray(_ newValue: Array<Any>) {
        if newValue.count == 0 {
            return
        }
        imageMap = Dictionary<Int, UIImage>()
        
        for (index, value) in newValue.enumerated() {
            if value is UIImage {
                imageMap!.updateValue(value as! UIImage, forKey: index)
            } else if (value is NSString) {
                // 如果是网络图片，先设置缺省图，等下载好之后再显示
                let phImage = (placeholderImage != nil) ? placeholderImage : UIImage()
                imageMap!.updateValue(phImage!, forKey: index)
                // 下载图片
                self.downloader.downloadImage(value as? String, { (image) in
                    self.imageMap!.updateValue(image, forKey: index)
                    if self.currIndex_new == index {
                        DispatchQueue.main.async {
                            self.currImageView.image = image
                        }
                    }
                })
            }
        }
        // 在数据初始化后，初始化索引
        currIndex_new               = 0
        // 初始化页码控制器
        pageControl?.numberOfPages  = imageMap!.count
        pageControl?.currentPage    = 0
        setNeedsLayout()
    }
    /// 更新索引
    func updateIndex() {
        if imageMap == nil {
            preIndex_new = 0
            currIndex_new = 0
            nextIndex_new = 0
        } else {
            preIndex_new = (currIndex_new - 1 + imageMap!.count) % imageMap!.count
            nextIndex_new = (currIndex_new + 1) % imageMap!.count
        }
    }
    
    // MARK: - Event
    @objc func clickImage() {
        delegate?.carouselView?(self, didSelectImageAt: currIndex_new)
    }
    
    // MARK: - public
    public func setCurrImageIndex(_ index: Int) {
        // FIXME: 此处要怎么做呢？
    }
    
    // MARK: - Timer
    func startTimer() {
        if !isAutoScroll { return }
        if let imgs = imageMap, imgs.count <= 1 { return }
        if let t = timer, t.timeInterval == autoScrollDuration { return }
        if let t = timer, t.timeInterval != autoScrollDuration { stopTimer() }
        
        timer = Timer(timeInterval: autoScrollDuration, repeats: true, block: { [weak self] (timer) in
            self?.nextPage()
        })
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.default)
    }
    func stopTimer() {
        guard timer != nil else { return }
        timer!.invalidate()
        timer = nil
    }
    
    func nextPage() {
        switch autoScrollDirection {
        case .left:
            scrollView.setContentOffset(CGPoint(x: frame.width * 3, y: 0), animated: true)
            break
        case .right:
            scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: true)
            break
        }
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if CGSize.zero.equalTo(scrollView.contentSize) { return}
        if manualSetContentOffsetFlag { return }
        
        let offsetX = scrollView.contentOffset.x;
        
        // 向左滚动
        if offsetX > frame.width * 2 {
            otherImageView.frame = CGRect(x: currImageView.frame.maxX, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            otherImageView.image = imageMap![nextIndex_new]
            
            if offsetX >= frame.width * 3 {
                changeToNext()
            }
        }
        // 向右滚动
        else if offsetX < frame.width * 2 {
            otherImageView.frame = CGRect(x: scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            otherImageView.image = imageMap![preIndex_new]
            if offsetX <= frame.width {
                changeToPre()
            }
        }
        
        // 回调当前图片的移动偏移量
        let imageOffsetX = offsetX - scrollView.frame.width*2
        let ratio = imageOffsetX / currImageView.frame.width
        
        // 处理半页切换时的页码控制器
        if let pc = pageControl, pageControlChangeMode == .half {
            if ratio < -0.5 && ratio > -1 {
                pc.currentPage = preIndex_new
            } else if ratio > 0.5 && ratio < 1 {
                pc.currentPage = nextIndex_new
            } else {
                pc.currentPage = currIndex_new
            }
        }
        
        delegate?.carouselView?(self, didScrollTo: imageOffsetX, ratio)
    }
    
    func changeToPre() {
        currImageView.image = otherImageView.image
        currIndex_new = preIndex_new
        
        manualSetContentOffsetFlag = true
        scrollView.contentOffset = CGPoint(x: frame.width * 2, y: 0)
        manualSetContentOffsetFlag = false
        
        // 处理整页切换时的页码控制器
        if let pc = pageControl, pageControlChangeMode == .full {
            pc.currentPage = currIndex_new
        }
        
        // 此时整页切换到下张图，回调此方法
        delegate?.carouselView?(self, didChangeImageAt: currIndex_new)
    }
    
    func changeToNext() {
        currImageView.image = otherImageView.image
        currIndex_new = nextIndex_new
        
        manualSetContentOffsetFlag = true
        scrollView.contentOffset = CGPoint(x: frame.width * 2, y: 0)
        manualSetContentOffsetFlag = false
        
        // 处理整页切换时的页码控制器
        if let pc = pageControl, pageControlChangeMode == .full {
            pc.currentPage = currIndex_new
        }
        
        // 此时整页切换到下张图，回调此方法
        delegate?.carouselView?(self, didChangeImageAt: currIndex_new)
    }
    
    // MARK: - test scroll call back
    
    // 开始拖拽（非点击，需要有实际的移动）
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    // 将要结束拖拽动作（整个拖拽结束，如果滑动在某个点停住但是不松手是不会走这个方法的）
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    // 确认结束拖拽动作
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    }
    // 开始滑动减速动作（结束拖拽之后发生的行为）
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    }
    // 滑动减速动作结束，整个滑动结束（如果滑动减速还未结束，此时又重新开始新的拖拽动作，那么该方法就不会再调用了）
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startTimer()
    }
}
