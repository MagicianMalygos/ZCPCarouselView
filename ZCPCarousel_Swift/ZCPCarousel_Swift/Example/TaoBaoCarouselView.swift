//
//  TaoBaoCarouselView.swift
//  SwiftTest
//
//  Created by 朱超鹏 on 2018/10/14.
//  Copyright © 2018年 zcp. All rights reserved.
//

import UIKit

class TaoBaoCarouselView: UIView {

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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
