//
//  ViewController.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 23/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

  override func viewDidLoad()
  {
    super.viewDidLoad()

    // logout button
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    // handle user logout or not
    if Auth.auth().currentUser?.uid == nil {
      perform(#selector(handleLogout), with: nil, afterDelay: 0)
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

}

