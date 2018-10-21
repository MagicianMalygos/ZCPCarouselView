//
//  LOLCarouselView.swift
//  ZCPCarousel_IOS
//
//  Created by 朱超鹏 on 2018/10/20.
//  Copyright © 2018年 zcp. All rights reserved.
//

import UIKit

class LOLCarouselView: UIView {
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
        carouselView.pageControl = LOLPageControl()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        carouselView.frame = bounds
        carouselView.pageControl?.frame = CGRect(x: 0, y: carouselView.frame.height - 10, width: frame.width, height: 10)
    }
}

// MARK: - 掌盟pageControl

internal let ITEM_SIDE: Double = 10
internal let ITEM_GAP: Double = 10

class LOLPageControl: UIView, ZCPCarouselPageControlProtocol {
    // MARK: - property
    var numberOfPages: Int = 0 {
        didSet { updateNumberOfPages(numberOfPages) }
    }
    var currentPage: Int = 0 {
        willSet { if currentPage != newValue { setCurrentPage(newValue) } }
    }
    /// page item container
    var itemContainerLayer = CALayer()
    /// page item list
    var itemLayerArr = Array<LOLPageItemLayer>()
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(itemContainerLayer)
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
        itemContainerLayer.position = CGPoint(x: layer.bounds.size.width / 2, y: layer.bounds.size.height / 2)
    }
    
    private func updateNumberOfPages(_ numberOfPages: Int) {
        
        itemContainerLayer.sublayers?.removeAll()
        itemLayerArr.removeAll()
        
        // 添加layer
        for index in 0..<numberOfPages {
            let itemLayer = generatePageItemLayer(false)
            itemLayerArr.append(itemLayer)
            itemContainerLayer.addSublayer(itemLayer)
            
            itemLayer.frame = CGRect(x: Double(index) * (ITEM_SIDE + ITEM_GAP), y: 0, width: ITEM_SIDE, height: ITEM_SIDE)
        }
        
        let needWidth = CGFloat(Double(numberOfPages) * ITEM_SIDE + Double(numberOfPages - 1) * ITEM_GAP)
        itemContainerLayer.bounds = CGRect(x: 0, y: 0, width: needWidth, height: CGFloat(ITEM_SIDE))
    }
    
    private func setCurrentPage(_ newPage: Int) {
        if itemLayerArr.count <= newPage { return }
        var itemLayer = itemLayerArr[newPage]
        let layerFrame = itemLayer.frame
        
        itemLayer.removeFromSuperlayer()
        itemLayer = generatePageItemLayer(true)
        itemLayer.frame = layerFrame
        itemContainerLayer.addSublayer(itemLayer)
    }
    
    func generatePageItemLayer(_ isSelected: Bool) -> LOLPageItemLayer {
        return LOLPageItemLayer(CGSize(width: ITEM_SIDE, height: ITEM_SIDE), isSelected)
    }
}

class LOLPageItemLayer: CALayer {
    
    // MARK: - property
    lazy var outLayer: CAShapeLayer = {
        return CAShapeLayer()
    }()
    lazy var inLayer: CAShapeLayer = {
        return CAShapeLayer()
    }()
    
    var isSelected: Bool = false {
        didSet {
            updateState()
        }
    }
    
    // MARK: - life cycle
    init(_ size: CGSize, _ isSelected: Bool) {
        super.init()
        bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        setup(size, isSelected)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    func setup(_ size: CGSize, _ isSelected: Bool) {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size.width / 2.0, y: 0.0))
        path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2, y: size.height))
        path.addLine(to: CGPoint(x: 0.0, y: size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2.0, y: 0.0))
        
        outLayer.frame = bounds
        outLayer.backgroundColor = UIColor.clear.cgColor
        outLayer.path = path.cgPath
        outLayer.strokeColor = UIColor(red: CGFloat(183.0/255.0), green: CGFloat(174.0/255.0), blue: CGFloat(47.0/255.0), alpha: CGFloat(1)).cgColor
        outLayer.lineWidth = 1
        addSublayer(outLayer)
        
        let gap = CGFloat(3)
        
        if isSelected {
            inLayer.frame = bounds
            inLayer.backgroundColor = UIColor.clear.cgColor
            let inLayerPath = UIBezierPath()
            inLayerPath.move(to: CGPoint(x: size.width / 2.0, y: gap))
            inLayerPath.addLine(to: CGPoint(x: size.width - gap, y: size.height / 2))
            inLayerPath.addLine(to: CGPoint(x: size.width / 2, y: size.height - gap))
            inLayerPath.addLine(to: CGPoint(x: gap, y: size.height / 2))
            inLayerPath.addLine(to: CGPoint(x: size.width / 2.0, y: gap))
            inLayer.path = inLayerPath.cgPath
            inLayer.strokeColor = UIColor(red: CGFloat(183.0/255.0), green: CGFloat(174.0/255.0), blue: CGFloat(47.0/255.0), alpha: CGFloat(1)).cgColor
            inLayer.fillColor = UIColor(red: CGFloat(183.0/255.0), green: CGFloat(174.0/255.0), blue: CGFloat(47.0/255.0), alpha: CGFloat(1)).cgColor
            inLayer.lineWidth = 1
            addSublayer(inLayer)
        }
    }
    
    func updateState() {
        if isSelected {
            
        } else {
            
        }
    }
}
