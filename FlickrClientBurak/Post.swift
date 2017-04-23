//
//  Post.swift
//  FlickrClientBurak
//
//  Created by Burak Gunduz on 23/04/2017.
//  Copyright © 2017 Burak Gunduz. All rights reserved.
//

import Foundation

class Post {
    
    fileprivate var _title: String?
    fileprivate var _published: String?
    fileprivate var _photoUrl: String?
    fileprivate var _link: String?
    fileprivate var _author: String?
    fileprivate var _tags: String?
    
    var title: String? {
        return _title
    }
    
    var published: String? {
        return _published
    }
    
    var photoUrl: String? {
        return _photoUrl
    }
    
    var link: String? {
        return _link
    }
    
    var author: String? {
        return _author
    }
    
    var tags: String? {
        return _tags
    }
    
    init(p_title: String, p_published: String, p_photoUrl: String, p_link: String, p_author: String, p_tags: String) {
        
        self._title = p_title
        self._published = p_published
        self._photoUrl = p_photoUrl
        self._link = p_link
        self._author = p_author
        self._tags = p_tags
    }
}
