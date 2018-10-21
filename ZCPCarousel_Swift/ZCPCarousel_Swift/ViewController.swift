//
//  ViewController.swift
//  ZCPCarousel_Swift
//
//  Created by 朱超鹏 on 2018/10/21.
//  Copyright © 2018年 zcp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - property
    var carouselView: UIView! = nil
    let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
    let carouselNameArr = ["微博", "京东", "淘宝", "掌盟", "测试"]
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let viewW = view.frame.width
        let viewH = view.frame.height
        let tableviewY = (carouselView != nil) ? carouselView.frame.maxY : 0
        let carouselH = (carouselView != nil) ? carouselView.frame.height : 0
        tableView.frame = CGRect(x: 0, y: tableviewY, width: viewW, height: viewH - carouselH)
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carouselNameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        }
        cell!.textLabel?.text = self.carouselNameArr[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let width = view.frame.width
        var alpha:CGFloat = 0
        var imageArray: Array<String>!
        
        // clean old carousel view
        if carouselView != nil {
            carouselView.removeFromSuperview()
            carouselView = nil
        }
        
        switch indexPath.row {
        case 0:
            // weibo 640 * 172
            imageArray = ["http://u1.img.mobile.sina.cn//public//files//image//640x172_img5bc1c1268c745.png",
                          "http://u1.img.mobile.sina.cn//public//files//image//640x172_img5bbab6ea1ba89.png",
                          "http://u1.img.mobile.sina.cn//public//files//image//640x172_img5bbefaca8753e.png",
                          "http://u1.img.mobile.sina.cn//public//files//image//640x172_img5bc1adce86071.png",
                          "http://u1.img.mobile.sina.cn//public//files//image//640x172_img5bc19adb37795.png"]
            alpha = CGFloat(172.0 / 640.0)
            let view = WeiboCarouselView()
            view.imageArray = imageArray
            carouselView = view
        case 1:
            // jd 590 * 470
            imageArray = ["https://m.360buyimg.com/babel/jfs/t24784/89/1785637164/84667/2650aa20/5bbc0a43N46aeb8ed.jpg",
                          "https://img1.360buyimg.com/pop/jfs/t24808/175/1814985044/88302/d28ad3e9/5bbb4868N61e138a3.jpg",
                          "https://img1.360buyimg.com/pop/jfs/t26620/149/1060286623/94601/acb8e685/5bc02c9aNa6b02b11.jpg",
                          "https://m.360buyimg.com/babel/jfs/t25657/163/2066744508/77866/2c5d6311/5bc043d4N3ff64ffa.jpg",
                          "https://img1.360buyimg.com/pop/jfs/t26890/122/1110678099/101205/dfb72e78/5bc1ae0eN49dfc51b.jpg",
                          "https://m.360buyimg.com/babel/jfs/t26953/351/1002551431/89224/cd268fb/5bbec123N1a8910b9.jpg",
                          "https://m.360buyimg.com/babel/jfs/t27706/361/953801002/80297/c575be45/5bbdbbcaN918f039a.jpg",
                          "https://m.360buyimg.com/babel/jfs/t26830/55/554049237/98922/9500a4a5/5bb0770dN45cb0713.jpg"]
            alpha = CGFloat(470.0 / 590.0)
            let view = JDCarouselView()
            view.imageArray = imageArray
            carouselView = view
        case 2:
            break
        case 3:
            imageArray = ["http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",
                          "http://s1.dwstatic.com/group1/M00/FD/    B0/1878f20ee96e34481a404cf9e80358b7.gif",
                          "http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",
                          "http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",
                          "http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg"]
            alpha = CGFloat(172.0 / 640.0)
            let view = LOLCarouselView()
            view.imageArray = imageArray
            carouselView = view
            break
        case 4:
            imageArray = ["http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",
                          "http://s1.dwstatic.com/group1/M00/FD/    B0/1878f20ee96e34481a404cf9e80358b7.gif",
                          "http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",
                          "http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",
                          "http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg"]
            alpha = CGFloat(200 / width)
            let view = TestCarouselView()
            view.imageArray = imageArray
            carouselView = view
        default:
            break
        }
        
        if carouselView != nil {
            carouselView.frame = CGRect(x: 0, y: 0, width: width, height: width * alpha)
            carouselView.backgroundColor = UIColor.lightGray
            view.addSubview(carouselView)
        }
    }
}

