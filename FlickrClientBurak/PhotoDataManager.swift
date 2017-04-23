//
//  PhotoDataManager.swift
//  FlickrClientBurak
//
//  Created by Burak Gunduz on 24/04/2017.
//  Copyright © 2017 Burak Gunduz. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class PhotosDataManager {
    
    static let sharedManager = PhotosDataManager()
    
    let photoCache = AutoPurgingImageCache(
        memoryCapacity: 100 * 1024 * 1024,
        preferredMemoryUsageAfterPurge: 80 * 1024 * 1024
    )
    
    //MARK: - Image Downloading
    
    func getNetworkImage(_ urlString: String, completion: @escaping ((UIImage) -> Void)) -> (Request) {
        print("downloaded url: " + urlString)
        
        return Alamofire.request(urlString).responseImage(completionHandler: { response in
            
            guard let image = response.result.value else { return }
            
            self.cacheCollectionImage(image, urlString: urlString)
            
            completion(image)
            
        })
    }
    
    //MARK: = Image Caching
    
    func cacheCollectionImage(_ image: UIImage, urlString: String) {
        
        print("Cached called!")
        photoCache.add(image, withIdentifier: urlString)
    }
    
    func cachedImage(_ urlString: String) -> UIImage? {
        
        print("cachedImage() func called")
        return photoCache.image(withIdentifier: urlString)
    }
}

