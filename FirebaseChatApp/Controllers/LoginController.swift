//
//  LoginController.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 23/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit

class LoginController: UIViewController
{
  
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
  
  let loginButtonRegistration: UIButton =
  {
    let button = UIButton(type: UIButtonType.system)
    button.backgroundColor = UIColor(r: 57, g: 68, b: 80)
    button.setTitle("Registration", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.layer.masksToBounds = true
    button.layer.cornerRadius = 5
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
  
  
  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "logo")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  
  
  
  
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    view.backgroundColor = UIColor(r: 129, g: 147, b: 166)
    view.addSubview(textFieldsContainerView)
    view.addSubview(loginButtonRegistration)
    view.addSubview(profileImageView)
    
    setupInputsContainerView()
    setupLoginButtonRegistration()
    setupProfileImageView()
    
  }
  
  
  func setupProfileImageView()
  {
    // center and width and height
    profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    profileImageView.bottomAnchor.constraint(equalTo: textFieldsContainerView.topAnchor, constant: -12).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    
  }
  
  
  func setupInputsContainerView()
  {
    // center the input view
    textFieldsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    textFieldsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    // same thing for the with and the height (12 px on bth sides)
    textFieldsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
    textFieldsContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    
    textFieldsContainerView.addSubview(nameTextField)
    textFieldsContainerView.addSubview(nameSeparatorView)
    textFieldsContainerView.addSubview(emailTextField)
    textFieldsContainerView.addSubview(emailSeparatorView)
    textFieldsContainerView.addSubview(passwordTextField)
    
    // constraints for name text field and its separator
    nameTextField.leftAnchor.constraint(equalTo: textFieldsContainerView.leftAnchor, constant: 12).isActive = true
    nameTextField.topAnchor.constraint(equalTo: textFieldsContainerView.topAnchor).isActive = true
    nameTextField.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    nameTextField.heightAnchor.constraint(equalTo: textFieldsContainerView.heightAnchor, multiplier: 1/3).isActive = true
    
    nameSeparatorView.leftAnchor.constraint(equalTo: textFieldsContainerView.leftAnchor).isActive = true
    nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
    nameSeparatorView.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    
    // constraints for email text field and its separator
    emailTextField.leftAnchor.constraint(equalTo: textFieldsContainerView.leftAnchor, constant: 12).isActive = true
    emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
    emailTextField.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    emailTextField.heightAnchor.constraint(equalTo: textFieldsContainerView.heightAnchor, multiplier: 1/3).isActive = true
    
    emailSeparatorView.leftAnchor.constraint(equalTo: textFieldsContainerView.leftAnchor).isActive = true
    emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
    emailSeparatorView.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    // constraints for password text field and its separator
    passwordTextField.leftAnchor.constraint(equalTo: textFieldsContainerView.leftAnchor, constant: 12).isActive = true
    passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
    passwordTextField.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    passwordTextField.heightAnchor.constraint(equalTo: textFieldsContainerView.heightAnchor, multiplier: 1/3).isActive = true
    
  }
  
  func setupLoginButtonRegistration()
  {
    //center the button
    loginButtonRegistration.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    // constraints for width and height and top
    loginButtonRegistration.topAnchor.constraint(equalTo: textFieldsContainerView.bottomAnchor, constant: 12).isActive = true
    loginButtonRegistration.widthAnchor.constraint(equalTo: textFieldsContainerView.widthAnchor).isActive = true
    loginButtonRegistration.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
  }
  
  
  
  
  
  override var preferredStatusBarStyle: UIStatusBarStyle
  {
    return .lightContent
  }
  
  
  
}

extension UIColor
{
  convenience init(r: CGFloat, g: CGFloat, b: CGFloat)
  {
    self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
  }
}












