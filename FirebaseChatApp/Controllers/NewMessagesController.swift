//
//  RecentMessagesController.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 26/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase

class NewMessagesController: UITableViewController
{
  // MARK: Properties
  
  var messagesController: RecentMessagesController?
  let cellId = "cellId"
  var users = [User]()
  
  
  // MARK: App LifeCycle
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelButton))
    //register the Cell in the TableView
    tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    
    fetchUserInfo()
  }
  

  // MARK: Functions
  
  
  func fetchUserInfo()
  {
    Database.database().reference().child("users").observe(.childAdded, with:
    { (snapshot) in
      
      if let dictionary = snapshot.value as? [String: AnyObject]
      {
        let user = User(dictionary: dictionary)
        user.id = snapshot.key
        self.users.append(user)
        // reload of the table view should occur in the main thread
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
  
  
  // MARK: Overrided Functions
  
  
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    dismiss(animated: true)
    {
      let user = self.users[indexPath.row]
      self.messagesController?.showChatController(user)
    }
  }

}

