//
//  ChatCellMessage.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 02/08/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit


// Unlike UITableViewCells wich has a default TextLabel and DetailedLabel, the UICollectionViewCell doesn't, so this is the purpose of this class

class ChatCellMessage: UICollectionViewCell
{
 
  let textView: UITextView =
  {
    let textView = UITextView()
    textView.text = "Some Text"
    textView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
    textView.font = UIFont.systemFont(ofSize: 18)
    textView.translatesAutoresizingMaskIntoConstraints = false
    return textView
  }()
  
  
  override init(frame: CGRect)
  {
    super.init(frame: frame)
    addSubview(textView)
    //add constraint because otherwise we can't see it in the cell
    
    textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
    textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
}
