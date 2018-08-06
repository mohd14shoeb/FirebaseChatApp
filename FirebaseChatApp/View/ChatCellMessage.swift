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
  
  //static color for blue and gray messages bubbles
  static let bubbleBlueColor = UIColor(r: 90, g: 194, b: 250)
  static let bubbleGrayColor = UIColor(r: 230, g: 230, b: 230)
  // used to dinamically change bubble width
  var bubbleWidthAnchorConstraint: NSLayoutConstraint?
  var bubbleRightAnchorConstraint: NSLayoutConstraint?
  var bubbleLeftAnchorConstraint: NSLayoutConstraint?
  
  let textView: UITextView =
  {
    let textView = UITextView()
    textView.text = "Some Text"
    textView.font = UIFont.systemFont(ofSize: 16)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.backgroundColor = UIColor.clear
    return textView
  }()
  
  var profileImageView: UIImageView =
  {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.layer.cornerRadius = 16 // half of his width constraints
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  
  let bubbleView: UIView =
  {
    let bv = UIView()
    //view.backgroundColor = UIColor(r: 0, g: 137, b: 249)
    bv.backgroundColor = ChatCellMessage.bubbleBlueColor
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
    addSubview(profileImageView)
    
    profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    
    //add constraint because otherwise we can't see it in the cell
    bubbleRightAnchorConstraint = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
    bubbleRightAnchorConstraint?.isActive = true
    
    //we use this to switch the bubble to the left for received messages(we don't need isActive because by default is false)
    bubbleLeftAnchorConstraint = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
    
    
    
    bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    bubbleWidthAnchorConstraint = bubbleView.widthAnchor.constraint(equalToConstant: 200)
    bubbleWidthAnchorConstraint?.isActive = true
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
