//
//  UIStackView+LoadingImages.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 06/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Nuke

fileprivate var imageTasksKey: UInt8 = 0

extension UIStackView {
    private var imageTasks: [ImageTask] {
        get {
            return (objc_getAssociatedObject(self, &imageTasksKey) as? [ImageTask]) ?? []
        }
        set {
            objc_setAssociatedObject(self, &imageTasksKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func cancelImagesLoading() {
        arrangedSubviews.forEach {
            if let imageView = $0 as? UIImageView {
                imageView.image = nil
                imageView.isHidden = false
            }
        }
        
        imageTasks.forEach { $0.cancel() }
        imageTasks = []
    }
    
    public func loadImages(with imageURLs: [URL]) {
        guard imageURLs.count > 0 else {
            return
        }
        
        var imageURLs = imageURLs
        
        if imageURLs.count > arrangedSubviews.count {
            imageURLs = Array(imageURLs.dropLast(imageURLs.count - arrangedSubviews.count))
        }
        
        imageURLs.enumerated().forEach { index, url in
            let task = ImagePipeline.shared.loadImage(with: url) { [weak self] response, error in
                self?.addImage(at: index, response?.image)
            }
            
            imageTasks.append(task)
        }
    }
    
    private func addImage(at index: Int, _ image: UIImage?) {
        guard let imageView = arrangedSubviews[index] as? UIImageView else {
            return
        }
        
        imageView.image = image
        imageView.isHidden = image == nil
    }
}