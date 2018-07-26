//
//  ViewController.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 23/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {

  override func viewDidLoad()
  {
    super.viewDidLoad()

    // logout button
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    
    let writeImageIcon = UIImage(named: "recent_message_icon")
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: writeImageIcon, style: .plain, target: self, action: #selector(handleRecentMessages))
    
    
    checkIfUserIsLoggedIn()
  }
  
  func checkIfUserIsLoggedIn()
  {
    if Auth.auth().currentUser?.uid == nil {
      perform(#selector(handleLogout), with: nil, afterDelay: 0)
    }else{
      //observing a single user through fetching
      let uid = Auth.auth().currentUser?.uid
      Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with:
      { (snapshot) in
        
        if let dictionary = snapshot.value as? [String: AnyObject] {
          self.navigationItem.title = dictionary["name"] as? String
        }
        
        
      }, withCancel: nil)
      
    }
  }
  
  
  @objc func handleLogout()
  {
    do{
      try Auth.auth().signOut()
    } catch let logoutError {
      print(logoutError)
    }
    //launch Login controller
    let loginController = LoginController()
    present(loginController, animated: true, completion: nil)
  }
  
  @objc func handleRecentMessages()
  {
    let recentMessagesController = RecentMessagesController()
    let navigationController = UINavigationController(rootViewController: recentMessagesController)
    present(navigationController, animated: true, completion: nil)
  }

}

