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
  
  let sendMessageTextField: UITextField =
  {
    let textField = UITextField()
    textField.placeholder = "Enter message..."
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
  }()
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    navigationItem.title = "Chat Controller"
    collectionView?.backgroundColor = UIColor(displayP3Red: 193, green: 66, blue: 66, alpha: 0.9)
    
    sendMessageTextField.delegate = self
    
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
    
  }
  
  
}
