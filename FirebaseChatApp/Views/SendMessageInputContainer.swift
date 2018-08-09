//
//  ChatSendMessageContainerView.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 08/08/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit


class SendMessageInputContainer: UIView, UITextFieldDelegate
{
  
  // MARK: Properties
  
  lazy var handleImagePickerGestureRecognizer = UITapGestureRecognizer(target: chatController, action: #selector(chatController?.handleImagePicker))
  
  var chatController: ChatController?
  {
    didSet
    {
      sendButton.addTarget(chatController, action: #selector(chatController?.handleSendMessage), for: .touchUpInside)
      uploadImageView.addGestureRecognizer(handleImagePickerGestureRecognizer)
    }
  }
  
  
  lazy var sendMessageTextField: UITextField =
  {
    let textField = UITextField()
    textField.placeholder = "Enter message..."
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.delegate = self
    return textField
  }()
  
  let ContainerViewSeparatorLine: UIView =
  {
    let ContainerViewSeparatorLine = UIView()
    ContainerViewSeparatorLine.backgroundColor = UIColor(r: 220, g: 220, b: 220)
    ContainerViewSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
    return ContainerViewSeparatorLine
  }()
  
  
  let uploadImageView: UIImageView =
  {
    let uploadImageView = UIImageView()
    uploadImageView.image = UIImage(named: "attachment")
    uploadImageView.isUserInteractionEnabled = true
    uploadImageView.translatesAutoresizingMaskIntoConstraints = false
    return uploadImageView
  }()
  
  let sendButton: UIButton =
  {
    let sendButton = UIButton(type: .system)
    sendButton.setTitle("Send", for: .normal)
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    return sendButton
  }()
  
  
  
  
  /// If we want to make the sendMessageTextField to work when the keyboard interactive mode is enabled, we could override the inputAccessoryView with the following code.
  
  //  override var inputAccessoryView: UIView?
  //    {
  //    get {
  //      let containerView = UIView()
  //      containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
  //      containerView.backgroundColor = UIColor.black
  //
  //      let inputTextfield = UITextField()
  //      containerView.addSubview(inputTextfield)
  //      inputTextfield.placeholder = "Enter some text"
  //      inputTextfield.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
  //
  //      return containerView
  //    }
  //  }
  
  
  // MARK: Initialization
  
  
  override init(frame: CGRect)
  {
    super.init(frame: frame)
    setupViewComponents()
  }
  
  
  required init?(coder aDecoder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: Functions
  
  func setupViewComponents()
  {
    addSubview(uploadImageView)
    uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    uploadImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
    uploadImageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
    
    addSubview(sendButton)
    sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    
    addSubview(sendMessageTextField)
    sendMessageTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
    sendMessageTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    sendMessageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
    sendMessageTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    
    addSubview(ContainerViewSeparatorLine)
    ContainerViewSeparatorLine.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    ContainerViewSeparatorLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
    ContainerViewSeparatorLine.bottomAnchor.constraint(equalTo: topAnchor).isActive = true
    ContainerViewSeparatorLine.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
  }
  
  
  
  // MARK: Delegate Functions
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    chatController?.handleSendMessage()
    return true
  }
  
}
