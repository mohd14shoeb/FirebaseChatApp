//
//  Message.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 30/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit

class Message: NSObject
{
  var senderUserId: String?
  var receiverUserId: String?
  var text: String?
  var timeStamp: NSNumber?
}
