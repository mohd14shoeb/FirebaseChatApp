//
//  Message.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 30/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject
{
  
  // MARK: Properties
  
  var senderUserId: String?
  var receiverUserId: String?
  var text: String?
  var timeStamp: NSNumber?
  var imageUrl: String?
  var imageHeight: NSNumber?
  var imageWidth: NSNumber?


  init( dictionary: [String : AnyObject])
  {
    self.senderUserId = dictionary["senderUserId"] as? String
    self.receiverUserId = dictionary["receiverUserId"] as? String
    self.text = dictionary["text"] as? String
    self.timeStamp = dictionary["timeStamp"] as? NSNumber
    self.imageUrl = dictionary["imageUrl"] as? String
    self.imageHeight = dictionary["imageHeight"] as? NSNumber
    self.imageWidth = dictionary["imageWidth"] as? NSNumber
  }
  
  
  // MARK: Functions
  
  ///Description: if the current user id is receiverUserId we return the sernderUserId otherwise we do the opposite( in the current analyzed message there is one sender and one receiver )
  
  func retrieveOtherUserIdInTheMessage() -> String?
  {
    return senderUserId == Auth.auth().currentUser?.uid ? receiverUserId : senderUserId
    
    //is the same as the following
//    if receiverUserId == Auth.auth().currentUser?.uid{
//      return senderUserId
//    }else{
//      return receiverUserId
//    }
  }
  
  
}
