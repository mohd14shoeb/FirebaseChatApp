//
//  RecentMessagesController.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 26/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase

class RecentMessagesController: UITableViewController
{
  
  
  let cellId = "cellId"
  var users = [User]()
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelButton))
    //register the Cell in the TableView
    
    tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    
    fetchUserInfo()
  }
  
  
  func fetchUserInfo()
  {
    Database.database().reference().child("users").observe(.childAdded, with:
    { (snapshot) in
      
      if let dictionary = snapshot.value as? [String: String]
      {
        let user = User(dictionary: dictionary)
        // properties of User class must match with this setter otherwise it crashes. Safer way is to to assign value from database like user.name = ....
        //user.setValuesForKeys(dictionary)
//        user.name = dictionary["name"] as? String
//        user.email = dictionary["email"] as? String
//        user.profileImageUrl = dictionary["profileImageUrl"] as? String
        self.users.append(user)
        //the following line will crash due to background thread so we use dispatch async
        //self.tableView.reloadData()
        DispatchQueue.main.async
        {
          self.tableView.reloadData()
        }
      }
    }, withCancel: nil)
  }
  
  @objc func handleCancelButton()
  {
    self.dismiss(animated: true, completion: nil)
  }
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return users.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    // this is a hack just for displaying cells fast because it's better to dequeue our cells for memory efficiency
    //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
    
    //we cast it to use our own UserCell
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
    let user = users[indexPath.row]
    cell.textLabel?.text = user.name
    cell.detailTextLabel?.text = user.email

    if let profileImageUrl = user.profileImageUrl
    {
      cell.customProfileImageView.loadImageUsingCache(with: profileImageUrl)

    }
    return cell
  }
  
  //change the heigh of the table view rows
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 80
  }
  
  
}

/// ============= Registering our own Cell so we are able to dequeue it in the TableView and customize ir


class UserCell: UITableViewCell
{
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
  
  //Every time a Cell is dequeue it this method is called
  override init(style: UITableViewCellStyle, reuseIdentifier: String?)
  {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    addSubview(customProfileImageView)
    
    //add ios 9 constraints to our custom profile imageview
    customProfileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
    customProfileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    customProfileImageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
    customProfileImageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
}














