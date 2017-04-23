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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
                      UISearchControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var posts = [Post]()
    var searchedWords = [String]()
    
    var isSearchActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.delegate = self
        searchBar.tintColor = UIColor.black
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchBar.returnKeyType = .search
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.loadDataFromFlickrAPI(tags: "")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isSearchActive {
            
            return 5
        }
        else {
            
            return self.posts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as! FeedCell
        
        if self.isSearchActive {
            
            cell.profileImageView.isHidden = true
            cell.postImageView.isHidden = true
            cell.authorLabel.isHidden = true
            cell.timeagoLabel.isHidden = true
            cell.wordLabel.isHidden = false
            
            cell.configureCachedWords()
            
        }
        else {
            
            cell.profileImageView.isHidden = false
            cell.postImageView.isHidden = false
            cell.authorLabel.isHidden = false
            cell.timeagoLabel.isHidden = false
            cell.wordLabel.isHidden = true
            
            cell.post = self.posts[indexPath.row]
            cell.configureFeed()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.isSearchActive {
            
            return 45
        }
        else {
            
            return 270
        }
    }
    
    // MARK: - SearchBar Delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        self.posts.removeAll(keepingCapacity: false)
        self.isSearchActive = true
        self.tableView.reloadData()
        
        searchBar.showsCancelButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.tableView.reloadData()
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        print("Search button clicked: \(searchBar.text!)")
        self.loadDataFromFlickrAPI(tags: searchBar.text!)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        self.isSearchActive = false
        
        if searchBar.text == "" {
            print("Reload home posts")
        }
        
        self.tableView.reloadData()
        
        self.loadDataFromFlickrAPI(tags: "")
    }

    // MARK: - Flickr API
    
    func loadDataFromFlickrAPI(tags: String) {
        
        let API_ITEMS = "items"
        let API_TITLE = "author"
        let API_PUBLISHED = "published"
        let API_MEDIA = "media"
        let API_PHOTO_URL = "m"
        let API_AUTHOR = "author"
        let API_LINK = "link"
        let API_TAGS = "tags"
        
        var urlPath = ""
        
        if tags != "" {
            
            urlPath = "https://api.flickr.com/services/feeds/photos_public.gne?\(tags)&format=json&nojsoncallback=1"
        }
        else {
            
            urlPath = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1"
        }
        
        // 1.Alamofire public request from Flickr API as JSON format added:
        Alamofire.request(urlPath).responseJSON { response in
            
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
                        
                    }
                }
                
                // To make sure published date sorting
                self.posts = self.posts.sorted { $0.published! > $1.published! }
                
                self.tableView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
        
    }

}

