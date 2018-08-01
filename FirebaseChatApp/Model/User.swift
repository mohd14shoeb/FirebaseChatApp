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
  var id: String? // id used to associate messages wrote by the corresponding user
  var name: String?
  var email: String?
  var profileImageUrl: String?
  
  init(dictionary: [String: AnyObject])
  {
    self.name = dictionary["name"] as? String ?? ""
    self.email = dictionary["email"] as? String ?? ""
    self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
  }
  
}
