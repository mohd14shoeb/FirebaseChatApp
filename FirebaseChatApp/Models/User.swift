//
//  User.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 26/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit

class User: NSObject
{
  
  // MARK: Properties
  
  var id: String? // used thus every user has an unique id
  var name: String?
  var email: String?
  var profileImageUrl: String?
  
  
  
  // MARK: Properties
  
  init(dictionary: [String: AnyObject])
  {
    self.name = dictionary["name"] as? String ?? ""
    self.email = dictionary["email"] as? String ?? ""
    self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
  }
  
}
