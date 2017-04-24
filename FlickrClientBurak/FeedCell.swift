//
//  FeedCell.swift
//  FlickrClientBurak
//
//  Created by Burak Gunduz on 23/04/2017.
//  Copyright © 2017 Burak Gunduz. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class FeedCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeagoLabel: UILabel!
    
    var post: Post!
    var cachedWord: String!
    
    var wordLabel = UILabel()
    
    var request: Request?
    
    var controllerReferenceHome: ViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Tap gesture for post image
        self.postImageView.isUserInteractionEnabled = true
        let tapEffect = UITapGestureRecognizer(target: self, action: #selector(FeedCell.tapEffectPhoto))
        tapEffect.numberOfTapsRequired = 1
        self.postImageView.addGestureRecognizer(tapEffect)

        self.postImageView.backgroundColor = UIColor.lightGray
    }
    
    func configureFeed() {
        
        self.profileImageView.isHidden = false
        self.postImageView.isHidden = false
        self.authorLabel.isHidden = false
        self.timeagoLabel.isHidden = false
        
        self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
        self.postImageView.translatesAutoresizingMaskIntoConstraints = false
        self.authorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.timeagoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.layer.borderColor = UIColor.white.cgColor
        self.profileImageView.layer.borderWidth = 1.0
        self.profileImageView.backgroundColor = UIColor.lightGray
        
        self.profileImageView.image = UIImage(named: "user")
        
        self.profileImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4).isActive = true
        self.profileImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 10).isActive = true
        self.profileImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        self.profileImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        self.authorLabel.font = UIFont.init(name: "Avenir-Medium", size: 13)
        
        self.authorLabel.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor, constant: 0).isActive = true
        self.authorLabel.leftAnchor.constraint(equalTo: self.profileImageView.rightAnchor, constant: 7).isActive = true
        self.authorLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true
        self.authorLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.timeagoLabel.font = UIFont.init(name: "Avenir-Light", size: 11)

        self.timeagoLabel.centerYAnchor.constraint(equalTo: self.authorLabel.centerYAnchor, constant: 0).isActive = true
        self.timeagoLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10).isActive = true
        self.timeagoLabel.leftAnchor.constraint(equalTo: self.authorLabel.rightAnchor, constant: 8).isActive = true
        self.timeagoLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.postImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 50).isActive = true
        self.postImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0).isActive = true
        self.postImageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0).isActive = true
        self.postImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        postImageView.image = UIImage(named: "")
        postImageView.contentMode = .scaleAspectFill
        
        if let author = self.post.author, let publishedUTC = self.post.published, let photoUrl = self.post.photoUrl {
            
            self.authorLabel.text = author
            self.timeagoLabel.text = getTimeAgo(timeUTC: publishedUTC)
            
            self.reset()
            self.loadImage(url: photoUrl)
        }
        
    }
    
    func reset() {
        
        postImageView.image = nil
        request?.cancel()
    }
    
    func loadImage(url: String) {

        if let image = PhotosDataManager.sharedManager.cachedImage(url) {
            
            self.postImageView.image = image
            return
        }
        
        downloadImage(url: url)
    }

    func downloadImage(url: String) {
        
        request = PhotosDataManager.sharedManager.getNetworkImage(url) { image in
            
            self.postImageView.alpha = 0
            self.postImageView.image = image
            
            let options: UIViewAnimationOptions = [.curveEaseOut]
            UIView.animate(withDuration: 0.8, delay: 0.1, options: options, animations: {
                
                self.postImageView.alpha = 1.0
                
            }, completion: nil)
        }
    }

    
    func getTimeAgo(timeUTC: String) -> String {
        
        let dateStringUTC = timeUTC
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss X"
        let date = dateFormatter.date(from: dateStringUTC)!
        
        let now = Date()
        let formatter = DateComponentsFormatter()
        formatter.calendar?.locale = Locale(identifier: "en_US_POSIX")
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 2
        
        return formatter.string(from: date, to: now)! + " " + NSLocalizedString("ago", comment: "added after elapsed time")
        
    }
    
    func configureCachedWords(word: String) {
        
        wordLabel.text = word
        wordLabel.font = UIFont.init(name: "Avenir-Light", size: 15.0)
        wordLabel.textColor = UIColor.darkGray
        self.contentView.addSubview(wordLabel)
        
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        
        wordLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 28).isActive = true
        wordLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        wordLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        wordLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
    }
    
    func tapEffectPhoto(recognizer: UITapGestureRecognizer) {
        
        if let _ = self.postImageView.image, let controllerHome = self.controllerReferenceHome {
            controllerHome.animateImageView(postImageView: self.postImageView)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
