//
//  LoginController.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 23/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase



class LoginController: UIViewController, UITextFieldDelegate
{
  
  // MARK: Overrided Properties
  
  override var preferredStatusBarStyle: UIStatusBarStyle
  {
    return .lightContent
  }
  
  // MARK: Properties
  
  lazy var profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleImagePicker))
  
  var messagesController: RecentMessagesController?
  // these are used to dinamically adapt the view when selecting segmentedControll toggle
  var textFieldsContainerViewHeighAnchor: NSLayoutConstraint?
  var nameTextFieldHeighAnchor: NSLayoutConstraint?
  var emailTextFieldHeighAnchor: NSLayoutConstraint?
  var passwordTextFieldHeighAnchor: NSLayoutConstraint?
  
  
  let textFieldsContainerView: UIView =
  {
    let view = UIView()
    view.backgroundColor = UIColor.white
    view.translatesAutoresizingMaskIntoConstraints = false
    // specify the corner radius of this container
    view.layer.masksToBounds = true
    view.layer.cornerRadius = 5
    return view
  }()
  
  let loginOrRegistrationButton: UIButton =
  {
    let button = UIButton(type: UIButtonType.system)
    button.backgroundColor = UIColor(r: 57, g: 68, b: 80) 
    button.setTitle("Registration", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.layer.masksToBounds = true
    button.layer.cornerRadius = 5
    
    // do some action with this button
    button.addTarget(self, action: #selector(handleLoginOrRegistration), for: .touchUpInside)
    
    return button
  }()
  
  let nameTextField: UITextField =
  {
    let field = UITextField()
    field.placeholder = "Name"
    field.translatesAutoresizingMaskIntoConstraints = false
    return field
  }()
  
  let nameSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let emailTextField: UITextField =
  {
    let field = UITextField()
    field.placeholder = "Email address"
    field.translatesAutoresizingMaskIntoConstraints = false
    return field
  }()
  
  let emailSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let passwordTextField: UITextField =
  {
    let field = UITextField()
    field.placeholder = "Password"
    field.isSecureTextEntry = true
    field.translatesAutoresizingMaskIntoConstraints = false
    return field
  }()
  
  /// important lazy var here allow the target to be saved for the UITapGestureRecognizer
  lazy var profileImageView: UIImageView =
    {
      let imageView = UIImageView()
      imageView.image = UIImage(named: "default_profileimage")
      imageView.layer.cornerRadius = 4
      imageView.clipsToBounds = true
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.contentMode = .scaleAspectFill
      imageView.isUserInteractionEnabled = true
      imageView.addGestureRecognizer(profileImageGestureRecognizer)
      return imageView
  }()
  
  
  let loginOrRegistrationSegmentedControl: UISegmentedControl =
  {
    let sg = UISegmentedControl(items: ["Login", "Registration"])
    sg.tintColor = UIColor.white
    sg.selectedSegmentIndex = 1
    sg.addTarget(self, action: #selector(handleLoginRegistrationChangeTabs), for: .valueChanged)
    sg.translatesAutoresizingMaskIntoConstraints = false
    return sg
  }()
  
  
  // MARK: App LifeCycle

  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    view.backgroundColor = UIColor(r: 129, g: 147, b: 166)
    view.bounds = view.frame.insetBy(dx: 0, dy: -50)
    view.addSubview(textFieldsContainerView)
    view.addSubview(loginOrRegistrationButton)
    view.addSubview(loginOrRegistrationSegmentedControl)
    view.addSubview(profileImageView)
    
    nameTextField.delegate = self
    emailTextField.delegate = self
    passwordTextField.delegate = self
    
    setupProfileImageView()
    setupLoginOrRegistrationSegemntedControl()
    setupTextFieldsContainerView()
    setupLoginOrRegistrationButton()
  }
  
  
  // MARK: Functions
  
  
  func setupLoginOrRegistrationSegemntedControl()
  {
    loginOrRegistrationSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    loginOrRegistrationSegmentedControl.bottomAnchor.constraint(equalTo: textFieldsContainerView.topAnchor, constant: -12).isActive = true
    loginOrRegistrationSegmentedControl.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    loginOrRegistrationSegmentedControl.heightAnchor.constraint(equalToConstant: 35).isActive = true
  }
  


  func setupProfileImageView()
  {
    profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    profileImageView.bottomAnchor.constraint(equalTo: loginOrRegistrationSegmentedControl.topAnchor, constant: -12).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
  }
  
  
  func setupTextFieldsContainerView()
  {
    // fields container center, width and height
    textFieldsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    textFieldsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    textFieldsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
    textFieldsContainerViewHeighAnchor = textFieldsContainerView.heightAnchor.constraint(equalToConstant: 150)
    textFieldsContainerViewHeighAnchor?.isActive = true
    
    textFieldsContainerView.addSubview(nameTextField)
    textFieldsContainerView.addSubview(nameSeparatorView)
    textFieldsContainerView.addSubview(emailTextField)
    textFieldsContainerView.addSubview(emailSeparatorView)
    textFieldsContainerView.addSubview(passwordTextField)
    
    // nameTextField constraints + separator
    nameTextField.leftAnchor.constraint(equalTo: textFieldsContainerView.leftAnchor, constant: 12).isActive = true
    nameTextField.topAnchor.constraint(equalTo: textFieldsContainerView.topAnchor).isActive = true
    nameTextField.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    nameTextFieldHeighAnchor = nameTextField.heightAnchor.constraint(equalTo: textFieldsContainerView.heightAnchor, multiplier: 1/3)
    nameTextFieldHeighAnchor?.isActive = true
    nameSeparatorView.leftAnchor.constraint(equalTo: textFieldsContainerView.leftAnchor).isActive = true
    nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
    nameSeparatorView.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    // emailTextField constraints + separator
    emailTextField.leftAnchor.constraint(equalTo: textFieldsContainerView.leftAnchor, constant: 12).isActive = true
    emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
    emailTextField.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    emailTextFieldHeighAnchor = emailTextField.heightAnchor.constraint(equalTo: textFieldsContainerView.heightAnchor, multiplier: 1/3)
    emailTextFieldHeighAnchor?.isActive = true
    emailSeparatorView.leftAnchor.constraint(equalTo: textFieldsContainerView.leftAnchor).isActive = true
    emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
    emailSeparatorView.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    // passwordTextField constraints
    passwordTextField.leftAnchor.constraint(equalTo: textFieldsContainerView.leftAnchor, constant: 12).isActive = true
    passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
    passwordTextField.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    passwordTextFieldHeighAnchor = passwordTextField.heightAnchor.constraint(equalTo: textFieldsContainerView.heightAnchor, multiplier: 1/3)
    passwordTextFieldHeighAnchor?.isActive = true
    
  }
  
  func setupLoginOrRegistrationButton()
  {
    // loginOrRegistrationButton constraints + width and height
    loginOrRegistrationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    loginOrRegistrationButton.topAnchor.constraint(equalTo: textFieldsContainerView.bottomAnchor, constant: 12).isActive = true
    loginOrRegistrationButton.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    loginOrRegistrationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
  }
  
  
  // MARK: Delegates Functions
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    textField.resignFirstResponder()
    return true
  }
}
