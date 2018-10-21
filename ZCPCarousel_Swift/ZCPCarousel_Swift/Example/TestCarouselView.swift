//
//  TestCarouselView.swift
//  SwiftTest
//
//  Created by 朱超鹏 on 2018/10/14.
//  Copyright © 2018年 zcp. All rights reserved.
//

import UIKit

class TestCarouselView: UIView, ZCPCarouselDelegate {

    // MARK: - property
    var imageArray: Array<Any> {
        get { return carouselView.imageArray }
        set {
            carouselView.imageArray = newValue
            pageControl.numberOfPages = newValue.count
            setNeedsLayout()
        }
    }
    
    let carouselView: ZCPCarouselView = {
        let view = ZCPCarouselView()
        view.isAutoScroll = true
        view.autoScrollDuration = 4
        view.autoScrollDirection = .left
        return view
    }()
    let pageControl: UIPageControl = UIPageControl()
    
    // MARK: life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        carouselView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        carouselView.frame = bounds
        pageControl.frame = CGRect(x: carouselView.frame.width - 100, y: carouselView.frame.height - 20, width: 100, height: 20)
        carouselView.setNeedsLayout()
    }
    
    override var frame: CGRect {
        didSet {
            setNeedsLayout()
            carouselView.setNeedsLayout()
        }
    }
    
    // MARK: ZCPCarouselDelegate
    func carouselView(_ carouselView: ZCPCarouselView, didChangeImageAt index: Int) {
        pageControl.currentPage = index
    }
}
