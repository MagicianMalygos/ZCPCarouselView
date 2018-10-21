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
        carouselView.pageControlChangeMode = .half
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        carouselView.frame = bounds
        carouselView.pageControl?.frame = CGRect(x: 0, y: carouselView.frame.height - 15, width: frame.width, height: 10)
    }
}

// MARK: - 掌盟pageControl

fileprivate let ITEM_SIDE: Double = 10
fileprivate let ITEM_GAP: Double = 10

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
            let itemLayer = LOLPageItemLayer()
            itemLayerArr.append(itemLayer)
            itemContainerLayer.addSublayer(itemLayer)
            
            itemLayer.frame = CGRect(x: Double(index) * (ITEM_SIDE + ITEM_GAP), y: 0, width: ITEM_SIDE, height: ITEM_SIDE)
        }
        
        let needWidth = CGFloat(Double(numberOfPages) * ITEM_SIDE + Double(numberOfPages - 1) * ITEM_GAP)
        itemContainerLayer.bounds = CGRect(x: 0, y: 0, width: needWidth, height: CGFloat(ITEM_SIDE))
    }
    
    private func setCurrentPage(_ newPage: Int) {
        if itemLayerArr.count <= newPage { return }
        
        let oldItemLayer = itemLayerArr[currentPage]
        let newItemLayer = itemLayerArr[newPage]
        oldItemLayer.isSelected = false
        newItemLayer.isSelected = true
    }
}

class LOLPageItemLayer: CALayer {
    
    // MARK: - property
    lazy var outLayer: CAShapeLayer = {
        let l = CAShapeLayer()
        l.backgroundColor = UIColor.clear.cgColor
        l.strokeColor = UIColor(red: CGFloat(183.0/255.0), green: CGFloat(174.0/255.0), blue: CGFloat(47.0/255.0), alpha: CGFloat(1)).cgColor
        l.lineWidth = 1
        return l
    }()
    lazy var inLayer: CAShapeLayer = {
        let l = CAShapeLayer()
        l.backgroundColor = UIColor.clear.cgColor
        l.strokeColor = UIColor(red: CGFloat(183.0/255.0), green: CGFloat(174.0/255.0), blue: CGFloat(47.0/255.0), alpha: CGFloat(1)).cgColor
        l.fillColor = UIColor(red: CGFloat(183.0/255.0), green: CGFloat(174.0/255.0), blue: CGFloat(47.0/255.0), alpha: CGFloat(1)).cgColor
        l.lineWidth = 1
        return l
    }()
    
    var isSelected: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - life cycle
    override init() {
        super.init()
        addSublayer(outLayer)
        addSublayer(inLayer)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSublayers() {
        super.layoutSublayers()
        updateSubLayerPath()
    }
    
    // MARK: - private
    func updateSubLayerPath() {
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let size = bounds.size
        
        let gap = CGFloat(2)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if !isSelected {
            outLayer.bounds = CGRect(x: 0, y: 0, width: size.width - gap, height: size.height - gap)
            inLayer.isHidden = true
            
            let path = generateDiamondPathWithRect(outLayer.bounds.size)
            outLayer.path = path.cgPath
        } else {
            outLayer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            inLayer.bounds = CGRect(x: 0, y: 0, width: size.width - gap*3, height: size.height - gap*3)
            inLayer.isHidden = false
            
            var path = generateDiamondPathWithRect(outLayer.bounds.size)
            outLayer.path = path.cgPath
            path = generateDiamondPathWithRect(inLayer.bounds.size)
            inLayer.path = path.cgPath
        }
        
        outLayer.position = center
        inLayer.position = center
        
        CATransaction.commit()
    }
    
    func generateDiamondPathWithRect(_ size: CGSize) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size.width / 2.0, y: 0.0))
        path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2, y: size.height))
        path.addLine(to: CGPoint(x: 0.0, y: size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2.0, y: 0.0))
        return path
    }
}
