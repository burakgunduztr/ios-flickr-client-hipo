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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var posts = [Post]()
    var searchedWords = [String]()
    
    var isSearchActive: Bool = false
    
    var reloadCounter: Int = 0
    
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
            
            return self.searchedWords.count
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
            
            if searchedWords.count > 0 {
                cell.configureCachedWords(word: self.searchedWords[indexPath.row])
            }
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.isSearchActive {
            
            let searchWord = self.searchedWords[indexPath.row]
            
            
            self.tableView.endEditing(true)
            self.searchBar.text = searchWord
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
            self.loadDataFromFlickrAPI(tags: searchWord)
        }
    }
    
    // MARK: - SearchBar Delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if let savedWords = UserDefaults.standard.object(forKey: "SEARCHED_WORDS") as? [String] {
            self.searchedWords = savedWords
        }
        
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
        
        self.isSearchActive = false
        self.tableView.reloadData()
        
        let trimmedTags = searchBar.text!.replacingOccurrences(of: " ", with: "", options: [], range: nil)
        print("trimmedTags: \(trimmedTags)")
        
        print("Search button clicked: \(searchBar.text!)")
        self.loadDataFromFlickrAPI(tags: trimmedTags)
        
        if !self.searchedWords.contains(trimmedTags) {
            self.searchedWords.insert(trimmedTags, at: 0)
            self.saveSearchedWords()
        }
        else {
            
            if let index = self.searchedWords.index(of: trimmedTags) {
                self.searchedWords.remove(at: index)
                self.searchedWords.insert(trimmedTags, at: 0)
                self.saveSearchedWords()
            }
        }
    }
    
    func saveSearchedWords() {
        
        UserDefaults.standard.set(self.searchedWords, forKey: "SEARCHED_WORDS")
        UserDefaults.standard.synchronize()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        
        self.isSearchActive = false
        
        if searchBar.text == "" {
            print("Reload home posts")
        }
        
        self.tableView.reloadData()
        
        self.loadDataFromFlickrAPI(tags: "")
    }

    // MARK: - Flickr API
    
    func loadDataFromFlickrAPI(tags: String) {
        
        self.isSearchActive = false
        self.tableView.reloadData()
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
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
            
            print("Tags exist: \(tags)")
            urlPath = "https://api.flickr.com/services/feeds/photos_public.gne?tags=\(tags)&format=json&nojsoncallback=1"
        }
        else {
            
            print("Tag no.")
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
                self.reloadCounter = 0
                
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
            case .failure(let error):
                print(error)
                
                if tags != "" {
                    
                    self.reloadCounter = 1 + self.reloadCounter
                    
                    if self.reloadCounter > 15 {
                        
                        // Display an error
                        self.displayErrorAlert(tags: tags)
                    }
                    else {
                        
                        self.loadDataFromFlickrAPI(tags: tags)
                    }
                    
                    
                }
                else {
                    
                    self.reloadCounter = 1 + self.reloadCounter
                    
                    if self.reloadCounter > 15 {
                        
                        // Display an error
                        self.displayErrorAlert(tags: tags)
                    }
                    else {
                        
                        self.loadDataFromFlickrAPI(tags: "")
                    }
            
                }
            }
        }
    }
    
    func displayErrorAlert(tags: String) {
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        
        let alert = UIAlertController(title: "JSON Serialization Error", message: "Invalid escape sequence around character coming from API.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Retry", style: .destructive) { (UIAlertAction) in
            
            if tags != "" {
                
                self.loadDataFromFlickrAPI(tags: tags)
            }
            else {
                
                self.loadDataFromFlickrAPI(tags: "")
            }
        }
        
        let close = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(action)
        alert.addAction(close)
        
        self.present(alert, animated: true, completion: nil)
    }

}

