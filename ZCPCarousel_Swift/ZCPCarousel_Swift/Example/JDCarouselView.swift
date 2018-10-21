//
//  JDCarouselView.swift
//  SwiftTest
//
//  Created by 朱超鹏 on 2018/10/14.
//  Copyright © 2018年 zcp. All rights reserved.
//

import UIKit

class JDCarouselView: UIView, ZCPCarouselDelegate {
    
    // MARK: - property
    var imageArray: Array<Any> {
        get { return carouselView.imageArray }
        set {
            carouselView.imageArray = newValue
        }
    }
    
    let carouselView: ZCPCarouselView = {
        let view = ZCPCarouselView()
        view.isAutoScroll = true
        view.autoScrollDuration = 4
        view.autoScrollDirection = .left
        return view
    }()
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(carouselView)
        
        carouselView.pageControl = JDPageControl()
        carouselView.pageControlChangeMode = .half
        carouselView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        carouselView.frame = bounds
        carouselView.pageControl?.frame = CGRect(x: 0, y: carouselView.frame.height - 10, width: frame.width, height: 10)
    }
    
    override var frame: CGRect {
        didSet {
            setNeedsLayout()
            carouselView.setNeedsLayout()
        }
    }
}

// MARK: - 京东pageControl

fileprivate let LINE_WIDTH: Float = 3
fileprivate let LINE_LENGTH: Float = 8
fileprivate let GAP_LENGTH: Float = 10

class JDPageControl: UIView, CAAnimationDelegate, ZCPCarouselPageControlProtocol {
    // MARK: - property
    var numberOfPages: Int = 0 {
        didSet { updateNumberOfPages(numberOfPages) }
    }
    var currentPage: Int = 0 {
        willSet { if currentPage != newValue { setCurrentPage(newValue) } }
    }
    
    var moveLayer: CAShapeLayer!
    var dashedLayer: CAShapeLayer!
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override
    override var frame: CGRect {
        didSet { updateLayerOrigin() }
    }
    
    // MARK: - private
    private func updateLayerOrigin() {
        let layerCenter = CGPoint(x: layer.bounds.size.width / 2, y: layer.bounds.size.height / 2)
        if let l = moveLayer { l.position = layerCenter }
        if let l = dashedLayer { l.position = layerCenter }
    }
    
    private func updateNumberOfPages(_ numberOfPages: Int) {
        if let l = moveLayer { l.removeFromSuperlayer() }
        if let l = dashedLayer { l.removeFromSuperlayer() }
        
        moveLayer = CAShapeLayer()
        dashedLayer = CAShapeLayer()
        
        let needWidth = CGFloat(Float(numberOfPages) * LINE_LENGTH + Float(numberOfPages - 1) * GAP_LENGTH)
        let y = CGFloat(LINE_WIDTH / 2)
        
        let movePath = UIBezierPath()
        movePath.move(to: CGPoint(x: 0, y: y))
        movePath.addLine(to: CGPoint(x: needWidth, y: y))
        moveLayer.bounds = CGRect(x: 0, y: 0, width: needWidth, height: CGFloat(LINE_WIDTH))
        moveLayer.path = movePath.cgPath
        moveLayer.lineCap = CAShapeLayerLineCap.round
        moveLayer.lineJoin = CAShapeLayerLineJoin.round
        moveLayer.strokeColor = UIColor.white.cgColor
        moveLayer.lineWidth = CGFloat(LINE_WIDTH)
        moveLayer.strokeEnd = 0
        moveLayer.lineDashPhase = -5
        moveLayer.lineDashPattern = [NSNumber(value: LINE_LENGTH + GAP_LENGTH - 5), NSNumber(value: 5)]
        
        let dashedPath = UIBezierPath()
        dashedPath.move(to: CGPoint(x: 0, y: y))
        dashedPath.addLine(to: CGPoint(x: needWidth, y: y))
        dashedLayer.bounds = CGRect(x: 0, y: 0, width: needWidth, height: CGFloat(LINE_WIDTH))
        dashedLayer.path = dashedPath.cgPath
        dashedLayer.lineCap = CAShapeLayerLineCap.round
        dashedLayer.lineJoin = CAShapeLayerLineJoin.round
        dashedLayer.strokeColor = UIColor.white.cgColor
        dashedLayer.lineWidth = CGFloat(LINE_WIDTH)
        dashedLayer.lineDashPhase = 0
        dashedLayer.lineDashPattern = [NSNumber(value: LINE_LENGTH), NSNumber(value: GAP_LENGTH)]
        layer.addSublayer(moveLayer)
        layer.addSublayer(dashedLayer)
    }
    
    private func setCurrentPage(_ newPage: Int) {
        let needWidth = CGFloat(Float(numberOfPages) * LINE_LENGTH + Float(numberOfPages - 1) * GAP_LENGTH)
        let fromValue = CGFloat(LINE_LENGTH + Float(currentPage) * (LINE_LENGTH + GAP_LENGTH)) / needWidth
        let toValue = CGFloat(LINE_LENGTH + Float(newPage) * (LINE_LENGTH + GAP_LENGTH)) / needWidth
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.duration = 0.2
        anim.fromValue = Float(fromValue)
        anim.toValue = Float(toValue)
        anim.fillMode = CAMediaTimingFillMode.both
        anim.isRemovedOnCompletion = false
        anim.delegate = self
        moveLayer.add(anim, forKey: nil)
    }
    
    // MARK: - CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let animation = anim as! CABasicAnimation
        let toValue = animation.toValue as! Float
        moveLayer.strokeEnd = CGFloat(toValue)
        moveLayer.removeAllAnimations()
    }
}
