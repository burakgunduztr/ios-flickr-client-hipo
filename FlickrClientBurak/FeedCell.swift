//
//  FeedCell.swift
//  FlickrClientBurak
//
//  Created by Burak Gunduz on 23/04/2017.
//  Copyright © 2017 Burak Gunduz. All rights reserved.
//

import UIKit
import AlamofireImage

class FeedCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeagoLabel: UILabel!
    
    var post: Post!
    var cachedWord: String!
    
    var wordLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

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
        
        self.profileImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        self.profileImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 10).isActive = true
        self.profileImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        self.profileImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        self.authorLabel.font = UIFont.init(name: "Avenir-Medium", size: 13)
        
        self.authorLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8).isActive = true
        self.authorLabel.leftAnchor.constraint(equalTo: self.profileImageView.rightAnchor, constant: 7).isActive = true
        self.authorLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        self.authorLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.timeagoLabel.font = UIFont.init(name: "Avenir-Light", size: 11)

        self.timeagoLabel.centerYAnchor.constraint(equalTo: self.authorLabel.centerYAnchor, constant: 0).isActive = true
        self.timeagoLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10).isActive = true
        self.timeagoLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.timeagoLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.postImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 50).isActive = true
        self.postImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0).isActive = true
        self.postImageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0).isActive = true
        self.postImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        postImageView.image = UIImage(named: "")
        postImageView.contentMode = .scaleAspectFill
        
    }
    
    func configureCachedWords() {
        
        wordLabel.text = "Deneme"
        wordLabel.font = UIFont.init(name: "Avenir-Light", size: 15.0)
        wordLabel.textColor = UIColor.darkGray
        self.contentView.addSubview(wordLabel)
        
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        
        wordLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 28).isActive = true
        wordLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        wordLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        wordLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
