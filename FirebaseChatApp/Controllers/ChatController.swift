//
//  ChatController.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 28/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase

class ChatController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
  
  let cellId = "cellId"
  // used to store all the messages both for sender and receiver users
  var messages = [Message]()
  // constraint reference to correctly show the keyboard
  var containerViewBottomConstraint: NSLayoutConstraint?
  
  // this is the user the logged user are chatting with
  var user: User?
  {
    didSet{
      navigationItem.title = user?.name
      observeMessages()
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
  
  // the following view could be used to work with keyboard interactive ( we override (through get) the inputAccessoryView to make the containerView following the keyboard when it's in interactive mode. Maybe the other way is to observe the change of the frame of the keyboard
  
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
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    collectionView?.backgroundColor = UIColor(r: 240, g: 240, b: 240)
    collectionView?.alwaysBounceVertical = true
    //Add collectionView padding (the bottom edge make possibile to see also the last message when exceeds the collectionView frame when we are scrolling, 75 = 15 + 50 of the containerView so bottom and top padding are equivalent when we see them)
    collectionView?.contentInset = UIEdgeInsetsMake(15, 0, 75, 0)
    collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 75, 0)
    
    // to create the effect of dismissing the keyboard in an intercative way
    collectionView?.keyboardDismissMode = .interactive
    
    //registering the cell
    collectionView?.register(ChatCellMessage.self, forCellWithReuseIdentifier: cellId)
    setupInputComponent()

    setupKeyboardObservers()
  }
  
  
  
  func setupKeyboardObservers()
  {
    //figure out the size of the keyboard
    NotificationCenter.default.addObserver(self, selector: #selector(manageKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(manageKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool)
  {
    super.viewDidDisappear(animated)
    // remobe the observers for handling the keyboard to avoid memory leaks
    NotificationCenter.default.removeObserver(self)
  }
  
  
  
  @objc func manageKeyboardWillShow(notification: Notification)
  {
    let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]) as? NSValue
    containerViewBottomConstraint?.constant = -(keyboardFrame?.cgRectValue.height)!
    //animate the container so it's smooth
    let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
    UIView.animate(withDuration: keyboardDuration!)
    {
      self.view.layoutIfNeeded()
    }
  }
  
  
  
  @objc func manageKeyboardWillHide(notification: Notification)
  {
    let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]) as? NSValue
    containerViewBottomConstraint?.constant = 0
    let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
    UIView.animate(withDuration: keyboardDuration!)
    {
      self.view.layoutIfNeeded()
    }
  }
  
  
  
  func observeMessages()
  {
    guard let loggedUserId = Auth.auth().currentUser?.uid, let receiverId = user?.id  else { return }
    let userMessages = Database.database().reference().child("messagesGroudpedById").child(loggedUserId).child(receiverId)
    userMessages.observe(.childAdded, with:
    {
      (snapshot) in
      guard let messageId = snapshot.key as? String else { return }
      let messagesRef = Database.database().reference().child("messages").child(messageId)
      
      messagesRef.observeSingleEvent(of: .value, with:
      {
        (snapshot) in
        guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
        let message = Message(dictionary: dictionary)
        
        // I have changed the Firebase structure, so that we don't fetch unnecessary messages anymore (the ones sent from other user that are not part of the ongoing conversation). For this reason we don't need anymore the che 'if self.user?.id! == message.retrieveOtherUserIdInTheMessage()'
        self.messages.append(message)
        DispatchQueue.main.async{
          self.collectionView?.reloadData()
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
    
    setupBubbleAndTextCell(cell: cell, message: message)
    
    if let text = message.text
    {
      // the 32 was obtained after severals guesses until we find the correct value
      cell.bubbleWidthAnchorConstraint?.constant = estimatedFrameForText(text: text).width + 32
    }
    return cell
  }
  
  
  
  
  /*Description: because the cell are reusable in the CollectionView, we must define what happen in both cases*/
  private func setupBubbleAndTextCell(cell: ChatCellMessage, message: Message)
  {
    if let profileImageUrl = self.user?.profileImageUrl {
      cell.profileImageView.loadImageUsingCache(with: profileImageUrl)
    }
    if let messageImageUrl = message.imageUrl{
      cell.messageImageView.loadImageUsingCache(with: messageImageUrl)
      // because the cell are reusable we hide the image if the message sent contain text and not an image
      cell.messageImageView.isHidden = false
      cell.bubbleView.backgroundColor = UIColor.clear
    }else{
      cell.messageImageView.isHidden = true
    }
    
    
    //if the message was sent not from the current user
    if message.senderUserId == Auth.auth().currentUser?.uid
    {
      // gray bubble view of outgoing message
      cell.bubbleView.backgroundColor = ChatCellMessage.bubbleBlueColor
      cell.bubbleRightAnchorConstraint?.isActive = true
      cell.bubbleLeftAnchorConstraint?.isActive = false
      cell.profileImageView.isHidden = true
    }else {
      
      cell.bubbleView.backgroundColor = ChatCellMessage.bubbleGrayColor
      cell.bubbleRightAnchorConstraint?.isActive = false
      cell.bubbleLeftAnchorConstraint?.isActive = true
      cell.profileImageView.isHidden = false
    }
    
  }
  

  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    var height: CGFloat = 80
    //get estimated height of the cell based on the text
    if let text = messages[indexPath.row].text
    {
      // the 20 here is a guesse until we find the correct value
      height = estimatedFrameForText(text: text).height + 20
    }
    return CGSize(width: view.frame.width, height: height)
  }
  
  
  private func estimatedFrameForText(text: String) -> CGRect
  {
    let size = CGSize(width: 200, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
  }
  
  // This method is called everytime the device rotates and make possibile to re-render the layout when rotating
//  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
//  {
////    collectionView?.collectionViewLayout.invalidateLayout()
//  }
  
  
  
  func setupInputComponent()
  {
    let containerView = UIView()
    view.addSubview(containerView)
    
    //this background trick avoid the collectionView background to overlap the containerView background
    containerView.backgroundColor = .white
    
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    
    containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    containerViewBottomConstraint?.isActive = true
    
    containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    let uploadImageView = UIImageView()
    uploadImageView.image = UIImage(named: "attachment@512")
    uploadImageView.isUserInteractionEnabled = true
    uploadImageView.translatesAutoresizingMaskIntoConstraints = false
    uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImagePicker)))
    containerView.addSubview(uploadImageView)
    
    uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
    uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    uploadImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
    uploadImageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
    
    
    
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
    
    sendMessageTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
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
  
  
  
  
  @objc func handleImagePicker()
  {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    present(imagePickerController, animated: true, completion: nil)
  }
  
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
  {
    var pickerImageSelected: UIImage?
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
    {
      pickerImageSelected = editedImage
    }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      pickerImageSelected = originalImage
    }
    if let finalImage = pickerImageSelected
    {
      uploadImageToFirebase(with: finalImage)
    }
    dismiss(animated: true, completion: nil)
  }
  
  func uploadImageToFirebase(with image: UIImage)
  {
    let imageName = UUID().uuidString
    let imageNameRef = Storage.storage().reference().child("message_images").child(imageName)
    if let uploadData = UIImageJPEGRepresentation(image, 0.2)
    {
      imageNameRef.putData(uploadData, metadata: nil)
      {
        (metadata, error) in
        if error != nil{
          print("Failed to upload image: ", error)
          return
        }
        imageNameRef.downloadURL(completion:
        {
          (url, error) in
          if error != nil{
            print("Failed to download image url: ", error)
          }
          if let imageUrl = url?.absoluteString
          {
            self.sendMessage(withImageUrl: imageUrl)
          }
        })
      }
    }
  }
  
  private func sendMessage(withImageUrl imageUrl: String)
  {
    let ref = Database.database().reference().child("messages")
    let receiverUserId = user?.id
    let senderUserId = Auth.auth().currentUser?.uid
    let childRef = ref.childByAutoId()
    let messageTimeStamp = Date().timeIntervalSince1970
    let message = ["senderUserId": senderUserId!, "receiverUserId":
      receiverUserId, "imageUrl": imageUrl, "timeStamp" : messageTimeStamp] as [String : AnyObject]
    childRef.updateChildValues(message)
    {
      (error, ref) in
      if error != nil{
        print(error)
        return
      }
      self.sendMessageTextField.text = nil
      let messageId = childRef.key
      let senderIdMessagesRef = Database.database().reference().child("messagesGroudpedById").child(senderUserId!).child(receiverUserId!)
      senderIdMessagesRef.updateChildValues([messageId: 1])
      let receiverIdMessagesRef = Database.database().reference().child("messagesGroudpedById").child(receiverUserId!).child(senderUserId!)
      receiverIdMessagesRef.updateChildValues([messageId: 1])
    }
  }
  
  
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
  {
    dismiss(animated: true, completion: nil)
  }
  
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    textField.resignFirstResponder()
    return true
  }
  
  /* Description: this function create a list of message (otherwise a message sent will replace the pevious one) by adding an unique id to every message. Then it creates a correspondence, between the sender and the receiver of that message. Thus they can see only their messages. */
  
  @objc func handleSendMessage()
  {
    let ref = Database.database().reference().child("messages")
    let receiverUserId = user?.id
    let senderUserId = Auth.auth().currentUser?.uid
    let childRef = ref.childByAutoId()
    let messageTimeStamp = Date().timeIntervalSince1970
    let message = ["senderUserId": senderUserId!, "receiverUserId":
    receiverUserId, "text": sendMessageTextField.text, "timeStamp" : messageTimeStamp] as [String : AnyObject]
    childRef.updateChildValues(message)
    {
      (error, ref) in
      if error != nil{
        print(error)
        return
      }
      self.sendMessageTextField.text = nil
      let messageId = childRef.key
      let senderIdMessagesRef = Database.database().reference().child("messagesGroudpedById").child(senderUserId!).child(receiverUserId!)
      senderIdMessagesRef.updateChildValues([messageId: 1])
      let receiverIdMessagesRef = Database.database().reference().child("messagesGroudpedById").child(receiverUserId!).child(senderUserId!)
      receiverIdMessagesRef.updateChildValues([messageId: 1])
    }
  }
  
  
}
