//
//  ViewController.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 23/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController
{
  
  var messages = [Message]()
  var messagesGroupedByUserId = [String : Message]()
  let cellId = "cellId"
  var timer: Timer?
  
  
  lazy var tapChatControllerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showChatController))
  
  
  var containerView: UIView =
  {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  
  lazy var profileImageView: UIImageView =
  {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 20
    imageView.clipsToBounds = true
    return imageView
  }()
  
  
  
  
  init()
  {
    super.init(style: UITableViewStyle.plain)
    print("saved gesture recognizer")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // logout button
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    
    let writeImageIcon = UIImage(named: "recent_message_icon")
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: writeImageIcon, style: .plain, target: self, action: #selector(handleRecentMessages))
    
//    observerMessages()
    
    tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
    
    checkIfUserIsLoggedIn()
    

  }
  
  
  
  func observeUserMessages()
  {
    guard let uid = Auth.auth().currentUser?.uid else {
      return
    }
    //get the reference only of the messages that the current user has sent
    let loggedUserRef = Database.database().reference().child("messagesGroudpedById").child(uid)
    loggedUserRef.observe(.childAdded, with:
    {
      (snapshot) in
      let receiverUserId = snapshot.key
      let receiverUserRef = Database.database().reference().child("messagesGroudpedById").child(uid).child(receiverUserId)
      
      receiverUserRef.observeSingleEvent(of: .childAdded, with:
      {
        (snapshot) in
        let messageId = snapshot.key
        let messageRef = Database.database().reference().child("messages").child(messageId)
        
        messageRef.observeSingleEvent(of: .value, with:
        {
          (snapshot) in
          if let dictionary = snapshot.value as? [String : AnyObject]
          {
            let message = Message(dictionary: dictionary)
            //        message.setValuesForKeys(dictionary)
            //          message.senderUserId = dictionary["senderUserId"] as? String
            //          message.receiverUserId = dictionary["receiverUserId"] as? String
            //          message.text = dictionary["text"] as? String
            //          message.timeStamp = dictionary["timeStamp"] as? NSNumber
            
            // grouping message by user Id
            //          self.messages.append(message)
            if let otherUserId = message.retrieveOtherUserIdInTheMessage()
            {
              self.messagesGroupedByUserId[otherUserId] = message
              // return an array containing the message sent/received by the same id. This array will contian the items in the same order as the were sent, so we should order them by the timestamp.
              self.messages = Array(self.messagesGroupedByUserId.values)
              self.messages.sort(by:
                {
                  (msg1, msg2) -> Bool in
                  return (msg1.timeStamp?.intValue)! > (msg2.timeStamp?.intValue)!
              })
            }
            
            //every time we receive a message a new timer is created but because we invalidate it, only the last timer is executed
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleTableViewReloadData), userInfo: nil, repeats: false)
          }
        }, withCancel: nil)
      }, withCancel: nil)
    }, withCancel: nil )
  }
  
  
  @objc private func handleTableViewReloadData()
  {
    DispatchQueue.main.async
    {
      print("\n called observeUserMessages \n")
      self.tableView.reloadData()
    }
  }
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return messages.count
  }
  
  
  // this method is called for every cell
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    //cell hack for fast test the content of the tableView
    //let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "celliD")
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
    let message = messages[indexPath.row]
    cell.message = message
    return cell 
  }
  
  
  //change the heigh of the table view rows
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 80
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    guard let selectedRowUserId = messages[indexPath.row].retrieveOtherUserIdInTheMessage() else{
      return
    }
    
    let selectedRowUserIdRef = Database.database().reference().child("users").child(selectedRowUserId)
    selectedRowUserIdRef.observeSingleEvent(of: .value, with:
    {
      (snapshot) in
      guard let dictionary = snapshot.value as? [String : AnyObject] else {
        return
      }
      let user = User(dictionary: dictionary)
      user.id = selectedRowUserId
      self.showChatController(user)
    }, withCancel: nil)
  }
  
  
  
  func checkIfUserIsLoggedIn()
  {
    if Auth.auth().currentUser?.uid == nil {
      perform(#selector(handleLogout), with: nil, afterDelay: 0)
    }else{
      updateUserNavBarTitle()
    }
  }
  
  func updateUserNavBarTitle()
  {
    //observing a single user through fetching
    guard let uid = Auth.auth().currentUser?.uid else { return }
    Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with:
      {
        (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
          let user = User(dictionary: dictionary)
          self.setupNavBarWithUser(user)
          //self.navigationItem.title = dictionary["name"] as? String
        }
    }, withCancel: nil)
  }
  
  
  func setupNavBarWithUser(_ user: User)
  {
    // clear the messags to display the updated ones
    messages.removeAll()
    messagesGroupedByUserId.removeAll()
    tableView.reloadData()
    
    observeUserMessages()
    
    let titleView = UIView()
    titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    
    self.navigationItem.titleView = titleView

    // Container View used to display long user name text
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.addSubview(containerView)


    if let profileImageUrl = user.profileImageUrl {
      profileImageView.loadImageUsingCache(with: profileImageUrl)
    }

    containerView.addSubview(profileImageView)

//    ios 9 constraint anchors
//    need x,y,width,height anchors
    profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    let nameLabel = UILabel()
    nameLabel.text = user.name
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(nameLabel)
    //need x,y,width,height anchors
    nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
    nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true

    containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
    containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

    //dont need this anymore
//    titleView.isUserInteractionEnabled = true
//    titleView.addGestureRecognizer(tapChatControllerGestureRecognizer)
  }
  
  @objc func showChatController(_ forUser: User)
  {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    let chatController = ChatController(collectionViewLayout: layout)
    chatController.user = forUser
    navigationController?.pushViewController(chatController, animated: true)
  }
  
  
  @objc func handleLogout()
  {
    do{
      try Auth.auth().signOut()
    } catch let logoutError {
      print(logoutError)
    }
    //launch Login controller
    let loginController = LoginController()
    loginController.messagesController = self
    present(loginController, animated: true, completion: nil)
  }
  
  @objc func handleRecentMessages()
  {
    let recentMessagesController = RecentMessagesController()
    //saving the MessageController in the RecentMessagesController thus later we can present the ChatController.
    recentMessagesController.messagesController = self
    let navigationController = UINavigationController(rootViewController: recentMessagesController)
    present(navigationController, animated: true, completion: nil)
  }

}

