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

    //Adding button to the top
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
  }
  
  
  @objc func handleLogout()
  {
    //launch Login controller
    let loginController = LoginController()
    present(loginController, animated: true, completion: nil)
  }

}

