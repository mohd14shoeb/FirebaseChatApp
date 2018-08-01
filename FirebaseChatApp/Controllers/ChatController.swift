//
//  ChatController.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 28/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase

class ChatController: UICollectionViewController, UITextFieldDelegate
{
  
  var user: User? {
    didSet{
      navigationItem.title = user?.name
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
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    collectionView?.backgroundColor = UIColor(r: 240, g: 240, b: 240)
    setupInputComponent()
  }
  
  func setupInputComponent()
  {
    let containerView = UIView()
    view.addSubview(containerView)
    
    
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    let sendButton = UIButton(type: .system)
    sendButton.setTitle("Send", for: .normal)
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
    containerView.addSubview(sendButton)
    

    sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    
  
    containerView.addSubview(sendMessageTextField)
    
    sendMessageTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
    sendMessageTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    sendMessageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
    sendMessageTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    
    let ContainerViewSeparatorLine = UIView()
    ContainerViewSeparatorLine.backgroundColor = UIColor(r: 220, g: 220, b: 220)
    ContainerViewSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(ContainerViewSeparatorLine)
    
    ContainerViewSeparatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
    ContainerViewSeparatorLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
    ContainerViewSeparatorLine.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    ContainerViewSeparatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
    

    
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    textField.resignFirstResponder()
    return true
  }
  
  @objc func handleSendMessage()
  {
    let ref = Database.database().reference().child("messages")
    // to represent a list of message, we generate a unique node
    // user selected by the current logged user, to send a message
    let receiverUserId = user?.id
    // curren logged user
    let senderUserId = Auth.auth().currentUser?.uid
    let messageTimeStamp = Date().timeIntervalSince1970
    let message = ["senderUserId": senderUserId!, "receiverUserId":
    receiverUserId, "text": sendMessageTextField.text, "timeStamp" : messageTimeStamp] as [String : AnyObject]
    //send message adding every time a new one without replacing that already sent
    ref.childByAutoId().updateChildValues(message)
  }
  
  
}
