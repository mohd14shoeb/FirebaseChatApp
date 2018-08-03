//
//  ChatController.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 28/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase

class ChatController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout
{
  
  let cellId = "cellId"
  
  var user: User? {
    didSet{
      navigationItem.title = user?.name
      observeMessages()
    }
  }
  
  
  var messages = [Message]()
  
  
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
    collectionView?.alwaysBounceVertical = true
    //Add collectionView padding (the bottom edge make possibile to see also the last message when exceeds the collectionView frame when we are scrolling, 75 = 15 + 50 of the containerView so bottom and top padding are equivalent when we see them)
    collectionView?.contentInset = UIEdgeInsetsMake(15, 0, 75, 0)
    //registering the cell
    collectionView?.register(ChatCellMessage.self, forCellWithReuseIdentifier: cellId)
    setupInputComponent()
  }
  
  func observeMessages()
  {
    guard let loggedUserId = Auth.auth().currentUser?.uid else { return }
    let userMessages = Database.database().reference().child("messagesGroudpedById").child(loggedUserId)
    userMessages.observe(.childAdded, with:
    {
      (snapshot) in
      guard let messageId = snapshot.key as? String else { return }
      let messagesRef = Database.database().reference().child("messages").child(messageId)
      
      messagesRef.observeSingleEvent(of: .value, with:
      { (snapshot) in
        
        guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
        let message = Message(dictionary: dictionary)
        if self.user?.id! == message.receiverUserId!
        {
          self.messages.append(message)
          DispatchQueue.main.async{
              self.collectionView?.reloadData()
          }
        }
        
      }, withCancel: nil)
    }, withCancel: nil)
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return messages.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatCellMessage
    let message = messages[indexPath.row]
    cell.textView.text = message.text
    cell.bubbleWidthConstraint?.constant = estimatedFrameForText(text: message.text!).width + 32
    return cell
  }
  
  
  // this method id from UICollectionViewDelegateFlowLayout
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    var height: CGFloat = 80
    var width: CGFloat = 30
    //get estimated height of the cell based on the text
    if let text = messages[indexPath.row].text
    {
      height = estimatedFrameForText(text: text).height + 20
      width = estimatedFrameForText(text: text).width + 32
    }
    return CGSize(width: view.frame.width, height: height)
  }
  
  
  private func estimatedFrameForText(text: String) -> CGRect
  {
    let size = CGSize(width: 200, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
  }
  
  
  
  func setupInputComponent()
  {
    let containerView = UIView()
    view.addSubview(containerView)
    
    //this background trick avoid the collectionView background to overlap the containerView background
    containerView.backgroundColor = .white
    
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
    let childRef = ref.childByAutoId()
    let messageTimeStamp = Date().timeIntervalSince1970
    let message = ["senderUserId": senderUserId!, "receiverUserId":
    receiverUserId, "text": sendMessageTextField.text, "timeStamp" : messageTimeStamp] as [String : AnyObject]
    //send message adding every time a new one without replacing that already sent
    
    
    // to display all the messages of the same user in the ChatController we group them by the senderUserId
      //ref.childByAutoId().updateChildValues(message)
    childRef.updateChildValues(message)
    {
      (error, ref) in
      if error != nil{
        print(error)
        return
      }
      //clearing inputTextField
      self.sendMessageTextField.text = nil
      
      let messagesGroudpedById = Database.database().reference().child("messagesGroudpedById").child(senderUserId!)
      let messageId = childRef.key
      messagesGroudpedById.updateChildValues([messageId: 1])
    }
  }
  
  
}
