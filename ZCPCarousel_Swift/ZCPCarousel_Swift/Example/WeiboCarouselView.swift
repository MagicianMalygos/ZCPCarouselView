//
//  WeiboCarouselView.swift
//  SwiftTest
//
//  Created by 朱超鹏 on 2018/10/14.
//  Copyright © 2018年 zcp. All rights reserved.
//

import UIKit

class WeiboCarouselView: UIView, ZCPCarouselDataSource, ZCPCarouselDelegate {
    
    // MARK: - property
    var imageArray: Array<Any>! {
        didSet {
            carouselView.imageArray = imageArray
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
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(carouselView)
        
        carouselView.pageControl = UIPageControl()
        carouselView.pageControl?.isUserInteractionEnabled = false
        carouselView.pageControlChangeMode = .full
        carouselView.dataSource = self
        carouselView.delegate = self
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        carouselView.frame = bounds
        carouselView.pageControl!.frame = CGRect(x: frame.width - 100, y: frame.height - 20, width: 100, height: 20)
    }
    
    // MARK: - ZCPCarouselDataSource
    
    
    // MARK: - ZCPCarouselDelegate
    func carouselView(_ carouselView: ZCPCarouselView, didSelectImageAt index: Int) {
        print("点击了第\(index)个图片")
    }
    func carouselView(_ carouselView: ZCPCarouselView, didChangeImageAt index: Int) {
    }
}
