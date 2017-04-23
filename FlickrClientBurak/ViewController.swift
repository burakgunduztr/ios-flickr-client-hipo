//
//  ViewController.swift
//  FlickrClientBurak
//
//  Created by Burak Gunduz on 22/04/2017.
//  Copyright © 2017 Burak Gunduz. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loadDataFromFlickrAPI()
        
    }
    
    func loadDataFromFlickrAPI() {
        
        let API_ITEMS = "items"
        let API_TITLE = "author"
        let API_PUBLISHED = "published"
        let API_MEDIA = "media"
        let API_PHOTO_URL = "m"
        let API_AUTHOR = "author"
        let API_LINK = "link"
        let API_TAGS = "tags"
        
        // 1.Alamofire public request from Flickr API as JSON format added:
        Alamofire.request("https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1").responseJSON { response in
            
            print(response.request ?? "")  // original URL request
            print(response.response ?? "") // HTTP URL response
            print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            
            switch response.result {
                
            case .success(let value):
                
                // Successfully handled JSON Data:
                let json = JSON(value)
                
                for (_, subJson) in json[API_ITEMS] {
                    
                    if let title = subJson[API_TITLE].string,
                        let publishedDate = subJson[API_PUBLISHED].string,
                        let author = subJson[API_AUTHOR].string,
                        let tags = subJson[API_TAGS].string,
                        let photoUrl = subJson[API_MEDIA][API_PHOTO_URL].string,
                        let link = subJson[API_LINK].string {
                        
                        // Parse author name
                        let subAuthorArr = author.components(separatedBy: "(\"")
                        let actualAuthorArr = subAuthorArr[1].components(separatedBy: "\")")
                        let actualAuthor = actualAuthorArr[0]
                        
                        // Changing "published": "2017-04-23T14:16:32Z" to "2017-04-23 14:16:32 +0000":
                        
                        // Fix published date issue to be convertible
                        let datePublishArr = publishedDate.components(separatedBy: "T")
                        let actualDate = datePublishArr[0]
                        
                        // Fix published time issue to be convertible
                        let timePublishArr = datePublishArr[1].components(separatedBy: "Z")
                        let actualTime = timePublishArr[0]
                        
                        let mergedDate = String(describing: actualDate) + " " + String(describing: actualTime) + " +0000"
                        
                        // Creating a post then add into array
                        let post = Post(p_title: title, p_published: mergedDate, p_photoUrl: photoUrl, p_link: link, p_author: actualAuthor, p_tags: tags)
                        self.posts.append(post)
                        
                        // To make sure published date sorting
                        self.posts = self.posts.sorted { $0.published! > $1.published! }
                        
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

