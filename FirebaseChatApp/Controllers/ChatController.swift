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
  
  //let dismissKeyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
  
  // this is the user the logged user are chatting with
  var user: User?
  {
    didSet{
      navigationItem.title = user?.name
      observeMessages()
    }
  }
  
  
  
  lazy var sendMessageInputContainerView: SendMessageInputContainerView =
  {
    let containerView = SendMessageInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
    containerView.chatController = self
    //this background color trick avoid the collectionView background to overlap the containerView background
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = .white
    return containerView
  }()
  
  
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
    
    collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    
    // Adding the container input view
    self.view.addSubview(sendMessageInputContainerView)
    sendMessageInputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    containerViewBottomConstraint = sendMessageInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    containerViewBottomConstraint?.isActive = true
    sendMessageInputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    sendMessageInputContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    setupKeyboardObservers()
  }
  
  
  @objc func dismissKeyboard(_ sender: UITapGestureRecognizer)
  {
    sendMessageInputContainerView.sendMessageTextField.resignFirstResponder()
  }
  
  
  func setupKeyboardObservers()
  {
    //figure out the size of the keyboard
    NotificationCenter.default.addObserver(self, selector: #selector(manageKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(manageKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(manageKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
  }
  
  
  override func viewDidDisappear(_ animated: Bool)
  {
    super.viewDidDisappear(animated)
    // remobe the observers for handling the keyboard to avoid memory leaks
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func manageKeyboardDidShow()
  {
    if messages.count > 0 {
      let indexPath = IndexPath(item: messages.count - 1, section: 0)
      collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
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
        DispatchQueue.main.async
        {
          self.collectionView?.reloadData()
          let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
          self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
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
    cell.chatController = self
    
    let message = messages[indexPath.row]
    cell.textView.text = message.text
    
    setupBubbleAndTextCell(cell: cell, message: message)
    
    if let text = message.text
    {
      // the 32 was obtained after severals guesses until we find the correct value
      cell.bubbleWidthAnchorConstraint?.constant = estimatedFrameForText(text: text).width + 32
      cell.textView.isHidden = false
    }else if message.imageUrl != nil {
      cell.bubbleWidthAnchorConstraint?.constant = 200
      cell.textView.isHidden = true
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
    let width = UIScreen.main.bounds.width
    //get estimated height of the cell based on the text
    let message = messages[indexPath.row]
    
    if let text = message.text
    {
      // the 20 here is a guesse until we find the correct value
      height = estimatedFrameForText(text: text).height + 20
    }else if let imageWith = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue
    {
      // h1 / w1 = h2 / w2 (we solve this)
      height = CGFloat(imageHeight / imageWith * 200)
      
    }
    return CGSize(width: width, height: height)
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
      uploadImageToFirebase(image: finalImage)
    }
    dismiss(animated: true, completion: nil)
  }
  
  func uploadImageToFirebase(image: UIImage)
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
            self.sendMessageWithImage(imageUrl, image: image)
          }
        })
      }
    }
  }
  
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
  {
    dismiss(animated: true, completion: nil)
  }
  
  
  
  /* Description: this function create a list of message (otherwise a message sent will replace the pevious one) by adding an unique id to every message. Then it creates a correspondence, between the sender and the receiver of that message. Thus they can see only their messages. */
  
  @objc func handleSendMessage()
  {
    let messageValues = ["text": sendMessageInputContainerView.sendMessageTextField.text!] as [String : AnyObject]
    sendMessageWithValues(values: messageValues)
  }
  
  private func sendMessageWithImage(_ imageUrl: String, image: UIImage)
  {
    let messageValues = ["imageUrl": imageUrl,"imageWidth" : image.size.width, "imageHeight": image.size.height] as [String: AnyObject]
    sendMessageWithValues(values: messageValues)
  }
  
  private func sendMessageWithValues(values: [String : AnyObject])
  {
    let ref = Database.database().reference().child("messages")
    let receiverUserId = user?.id
    let senderUserId = Auth.auth().currentUser?.uid
    let childRef = ref.childByAutoId()
    let messageTimeStamp = Date().timeIntervalSince1970
    var messageValues = ["senderUserId": senderUserId!, "receiverUserId":
      receiverUserId,"timeStamp" : messageTimeStamp] as [String : AnyObject]
    
    //append the parameter values to the above common messageValues
    messageValues.update(other: values)
    
    childRef.updateChildValues(messageValues)
    {
      (error, ref) in
      if error != nil{
        print(error)
        return
      }
      self.sendMessageInputContainerView.sendMessageTextField.text = nil
      let messageId = childRef.key
      let senderIdMessagesRef = Database.database().reference().child("messagesGroudpedById").child(senderUserId!).child(receiverUserId!)
      senderIdMessagesRef.updateChildValues([messageId: 1])
      let receiverIdMessagesRef = Database.database().reference().child("messagesGroudpedById").child(receiverUserId!).child(senderUserId!)
      receiverIdMessagesRef.updateChildValues([messageId: 1])
    }
  }
  
  var originalImageFrame: CGRect?
  var blackkBackrgoundView: UIView?
  var originalImageView: UIImageView?
  
  func performZoomInForImageView(_ originalImageView: UIImageView)
  {
    self.originalImageView = originalImageView
    self.originalImageView?.isHidden = true
    
    originalImageFrame = originalImageView.superview?.convert(originalImageView.frame, to: nil)
    let zoomedImageView = UIImageView(frame: originalImageFrame!)
    zoomedImageView.backgroundColor = UIColor.red
    zoomedImageView.image = originalImageView.image
    zoomedImageView.isUserInteractionEnabled = true
    zoomedImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performZoomOutForImageView)))
    
    if let keyWindow = UIApplication.shared.keyWindow
    {
      //animate a black background behind the window
      blackkBackrgoundView = UIView(frame: keyWindow.frame)
      blackkBackrgoundView?.backgroundColor = UIColor.black
      blackkBackrgoundView?.alpha = 0
      //this will appear behing the image because we add it before the zoomedImageView
      keyWindow.addSubview(blackkBackrgoundView!)
      keyWindow.addSubview(zoomedImageView)
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:
      {
        self.blackkBackrgoundView?.alpha = 1
        self.sendMessageInputContainerView.alpha = 0
        //calculating the correct height
        let height = self.originalImageFrame!.height / self.originalImageFrame!.width * keyWindow.frame.width
        zoomedImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
        zoomedImageView.center = keyWindow.center
        zoomedImageView.layer.masksToBounds = true
        zoomedImageView.layer.cornerRadius = 0
        
      }, completion:
      {
        (completed) in
      })
      
      
    }
  }
  
  @objc func performZoomOutForImageView(tapGesture: UITapGestureRecognizer)
  {
    if let zoomOutImageView = tapGesture.view
    {
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:
      {
        zoomOutImageView.frame = self.originalImageFrame!
        zoomOutImageView.clipsToBounds = true
        zoomOutImageView.layer.cornerRadius = 16
        self.blackkBackrgoundView?.alpha = 0
        self.sendMessageInputContainerView.alpha = 1
        
      }) { (completed) in
        self.originalImageView?.isHidden = false
        zoomOutImageView.removeFromSuperview()
      }
    }
  }
  
  
  
  
}


extension Dictionary
{
  mutating func update(other:Dictionary)
  {
    for (key,value) in other {
      self.updateValue(value, forKey:key)
    }
  }
}

