//
//  UserCell.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 31/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase

/// Custom UserCell so that we can reuse it across different UITableView/UICollectionView


class UserCell: UITableViewCell
{
  
  //this class is responsible to customize the view of the cell like the profileImageView and other things and not the tableView methods
  var message: Message?
  {
    didSet
    {
      setupNameAndProfileImage()

      detailTextLabel?.text = message?.text
      
      if let seconds = message?.timeStamp?.doubleValue
      {
        let timeStampDate = Date(timeIntervalSince1970: seconds)
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "hh:mm:ss a"
        messageTimeLabel.text = dateFormatted.string(from: timeStampDate)
      }
    }
  }
  
  private func setupNameAndProfileImage()
  {
    // if the current user is the one who received the message we display the user who sent him that message, otherwise we do the opposite
    if let id = message?.retrieveOtherUserIdInTheMessage()
    {
      // get the reference of the user of which the current user have sent a message and we observe any tipe of value change on this receiverUserId ref
      let ref = Database.database().reference().child("users").child(id)
      ref.observe(.value, with:
        {
          (snapshot) in
          if let dictionary = snapshot.value as? [String : AnyObject]
          {
            self.textLabel?.text = dictionary["name"] as? String
            if let profileImageUrl = dictionary["profileImageUrl"] as? String
            {
              self.customProfileImageView.loadImageUsingCache(with: profileImageUrl)
            }
          }
      }, withCancel: nil)
    }
  }
  
  
  // to customize the text frame
  override func layoutSubviews()
  {
    super.layoutSubviews()
    //56 = 8 of leftanchor + profile image of 40 + 8 of rightanchro
    textLabel?.frame = CGRect(x: 80, y: (textLabel!.frame.origin.y) - 2 , width: textLabel!.frame.width, height: textLabel!.frame.height)
    detailTextLabel?.frame = CGRect(x: 80, y: (detailTextLabel!.frame.origin.y) + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
  }
  
  //use our own image view for the cell so the image can fill correctly
  let customProfileImageView: UIImageView =
  {
    let imageView = UIImageView()
    //imageView.image = UIImage(named: "default_image_profile")
    imageView.layer.cornerRadius = 32 // half the profile image height
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  
  let messageTimeLabel: UILabel =
  {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = UIColor.darkGray
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  //Every time a Cell is dequeue it this method is called
  override init(style: UITableViewCellStyle, reuseIdentifier: String?)
  {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    addSubview(customProfileImageView)
    addSubview(messageTimeLabel)
    
    //add ios 9 constraints to our custom profile imageview
    customProfileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
    customProfileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    customProfileImageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
    customProfileImageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
    
    messageTimeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    messageTimeLabel.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 25).isActive = true
    messageTimeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
    messageTimeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
}

