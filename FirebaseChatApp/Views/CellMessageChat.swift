//
//  ChatCellMessage.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 02/08/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit


/// Description:  Unlike UITableViewCells wich has a default TextLabel and DetailedLabel, the UICollectionViewCell doesn't, so this is the purpose of this class

class CellMessageChat: UICollectionViewCell
{
  // MARK: Properties
  
  lazy var handleImageZoomGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleImageZoom))
  
  //static color for blue and gray messages bubbles
  static let bubbleBlueColor = UIColor(r: 90, g: 194, b: 250)
  static let bubbleGrayColor = UIColor(r: 230, g: 230, b: 230)
  // used to dinamically change bubble width
  var bubbleWidthAnchorConstraint: NSLayoutConstraint?
  var bubbleRightAnchorConstraint: NSLayoutConstraint?
  var bubbleLeftAnchorConstraint: NSLayoutConstraint?
  // use this var to delegate to the chatController the image zoom tap handling
  var chatController: ChatController?
  
  
  
  let textView: UITextView =
  {
    let textView = UITextView()
    textView.text = "Some Text"
    textView.font = UIFont.systemFont(ofSize: 16)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.backgroundColor = UIColor.clear
    textView.isEditable = false
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
  
  
  lazy var messageImageView: UIImageView =
  {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.layer.cornerRadius = 16
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.isUserInteractionEnabled = true
    imageView.addGestureRecognizer(handleImageZoomGestureRecognizer)
    return imageView
  }()
  
  
  let bubbleView: UIView =
  {
    let bv = UIView()
    //view.backgroundColor = UIColor(r: 0, g: 137, b: 249)
    bv.backgroundColor = CellMessageChat.bubbleBlueColor
    bv.translatesAutoresizingMaskIntoConstraints = false
    bv.layer.cornerRadius = 16
    bv.layer.masksToBounds = true
    return bv
  }()
  
  
  
  // MARK: Initialization
  
  
  override init(frame: CGRect)
  {
    super.init(frame: frame)
    addSubview(bubbleView)
    addSubview(textView)
    addSubview(profileImageView)
    // if the user send an image we add it inside of the bubble
    bubbleView.addSubview(messageImageView)
    messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
    messageImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
    messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
    messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    
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
  
  
  // MARK: Functions
  
  @objc func handleImageZoom(tapGesture: UITapGestureRecognizer)
  {
    if let imageView = tapGesture.view as? UIImageView {
      self.chatController?.performZoomInForImageView(imageView)
    }
  }
  
}
