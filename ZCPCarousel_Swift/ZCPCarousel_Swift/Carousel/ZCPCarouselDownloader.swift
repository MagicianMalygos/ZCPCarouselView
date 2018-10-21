//
//  ZCPCarouselDownloader.swift
//  SwiftTest
//
//  Created by 朱超鹏 on 2018/10/13.
//  Copyright © 2018年 zcp. All rights reserved.
//

import UIKit

class ZCPCarouselDownloader: NSObject, ZCPCarouselDownloaderProtocol {
    
    // MARK: - property
    private lazy var queue: OperationQueue = {
        return OperationQueue()
    }()
    
    // MARK: - ZCPCarouselDownloaderProtocol
    func downloadImage(_ urlString: String?, _ block: @escaping (UIImage) -> Void) {
        guard urlString != nil else { return }
        let download = BlockOperation { [weak self] in
            withExtendedLifetime(self) {
                let url = URL(string: urlString!)
                guard url != nil else { return }
                let data = try? Data(contentsOf: url!)
                guard data != nil else { return }
                let image = self!.getImageWithData(data!)
                guard let resultImage = image else { return }
                block(resultImage)
            }
        }
        queue.addOperation(download)
    }

    // MARK: - private
    private func getImageWithData(_ data: Data) -> UIImage? {
        let source: CGImageSource? = CGImageSourceCreateWithData(data as CFData, nil)
        guard let imageSource = source else { return nil }
        let count: size_t = CGImageSourceGetCount(imageSource)
        
        // 图片
        if count <= 1 {
            return UIImage(data: data)
        }
        // gif图片
        else {
            var images = Array<UIImage>()
            var duration: TimeInterval = 0
            for i in 0..<count {
                let image: CGImage? = CGImageSourceCreateImageAtIndex(imageSource, i, nil)
                guard let cgimage = image else { continue }
                duration = duration + durationWithSourceAtIndex(imageSource, i)
                images.append(UIImage(cgImage: cgimage))
            }
            if duration == 0 {
                duration = 0.1 * Double(count)
            }
            return UIImage.animatedImage(with: images, duration: duration)
        }
    }
    
    private func durationWithSourceAtIndex(_ imageSource: CGImageSource, _ index: Int) -> TimeInterval {
        return 0
    }
}
