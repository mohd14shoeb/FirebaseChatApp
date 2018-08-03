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
  // used to dinamically change bubble width
  var bubbleWidthConstraint: NSLayoutConstraint?
  
  let textView: UITextView =
  {
    let textView = UITextView()
    textView.text = "Some Text"
//    textView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
    textView.font = UIFont.systemFont(ofSize: 16)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.backgroundColor = UIColor.clear
    return textView
  }()
  
  
  let bubbleView: UIView =
  {
    let bv = UIView()
    //view.backgroundColor = UIColor(r: 0, g: 137, b: 249)
    bv.backgroundColor = UIColor(r: 90, g: 194, b: 250)
    bv.translatesAutoresizingMaskIntoConstraints = false
    bv.layer.cornerRadius = 16
//    bv.clipsToBounds = true
    bv.layer.masksToBounds = true
    return bv
  }()
  
  
  
  
  override init(frame: CGRect)
  {
    super.init(frame: frame)
    addSubview(bubbleView)
    addSubview(textView)
    
    //add constraint because otherwise we can't see it in the cell
    bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
    bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    bubbleWidthConstraint = bubbleView.widthAnchor.constraint(equalToConstant: 200)
    bubbleWidthConstraint?.isActive = true
    bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    
    //the textView adapts to the width and height of the bubbleView
    textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8 ).isActive = true
    textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
    textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
}
