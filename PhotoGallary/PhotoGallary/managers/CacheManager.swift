//
//  CachingManager.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 14.05.22.
//

import UIKit

class CacheManager {

    private var imageCache = NSCache<NSString, UIImage>()

    func checkCachedImage(key: URL) -> UIImage? {
        guard let cachedImage = imageCache.object(forKey: key.absoluteString as NSString) else { return nil }
        return cachedImage
    }

    func cacheImage(image: UIImage, key: URL) {
        imageCache.setObject(image, forKey: key.absoluteString as NSString)
    }
}
