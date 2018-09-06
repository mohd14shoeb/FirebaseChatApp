//
//  LoginController+handlers.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 26/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase


extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate
{
  
  // MARK: Functions
  
  func handleUserRegistration()
  {
    guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else
    {
      print("Form is not valid")
      return
    }
    Auth.auth().createUser(withEmail: email, password: password, completion:
    {
      (user: AuthDataResult?, error) in
      if error != nil {
        print(error!)
        return
      }
      guard let uid = Auth.auth().currentUser?.uid else{ return }
      /// ======== Successufully authenticated user
      
      // creating a unique image name id otherwise all users will have the same profile image name in the Database
      let imageName = UUID().uuidString
      let storage = Storage.storage().reference().child("\(imageName).jpg")
      // if we can get the profile image choosen by the user we save it in the database. ( compressin image so the download is much faster)
      //if let imageData = UIImagePNGRepresentation(self.profileImageView.image!)
      if let profileImage = self.profileImageView.image, let imageData = UIImageJPEGRepresentation(profileImage, 0.1)
      {
        storage.putData(imageData, metadata: nil, completion:
        {
          (metadata, error) in
          if error != nil
          {
            print(error!)
            return
          }
          // get the user profile image url
          storage.downloadURL(completion:
          {
            (url, error) in
            if error != nil {
              print(error!)
              return
            }
            if let imageUrl = url?.absoluteString //optional bindig automatically unwrap the value
            {
              let values = ["name": name, "email": email, "profileImageUrl": imageUrl]
              self.saveUserCredentialsWithUID(uid: uid, values: values)
            }
          })
        })
      }
    })
  }
  
  
  private func saveUserCredentialsWithUID(uid: String, values: [String: String])
  {
    let ref = Database.database().reference()
    let usersReference = ref.child("users").child(uid)
    
    usersReference.updateChildValues(values, withCompletionBlock:
    {
      (err, ref) in
      if err != nil {
        print(err!)
        return
      }
      //we don't need for registration (like we do in login) to call again firebase (updateUserNavBarTitle) to update the title, because we already have access to values
//        self.messagesController?.navigationItem.title = values["name"] as? String
      self.messagesController?.updateUserNavBarTitle()
      self.dismiss(animated: true, completion: nil)
    })
  }
  
  
  @objc func handleImagePicker()
  {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    present(picker, animated: true, completion: nil)
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
    if let finalImage = pickerImageSelected {
      profileImageView.image = finalImage
    }
    dismiss(animated: true, completion: nil)
  }
  
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
  {
    dismiss(animated: true, completion: nil)
  }
  
  
  @objc func handleLoginOrRegistration()
  {
    if loginOrRegistrationSegmentedControl.selectedSegmentIndex == 0{
      handleUserLogin()
    }else{
      handleUserRegistration()
    }
  }
  
  
  func handleUserLogin()
  {
    
    guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else
    {
      informUser("Email or Password missing")
      return
    }
    Auth.auth().signIn(withEmail: email, password: password)
    {
      (user, error) in
      if error != nil{
        self.informUser("Email or Password incorrect")
        return
      }
      self.messagesController?.updateUserNavBarTitle()
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  private func informUser(_ msg: String)
  {
    let userAlert = UIAlertController(title: "Operation Detail", message: msg, preferredStyle: .alert)
    userAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    self.present(userAlert, animated: true, completion: nil)
  }
  

  
  @objc func handleLoginRegistrationChangeTabs()
  {
    let title = loginOrRegistrationSegmentedControl.titleForSegment(at: loginOrRegistrationSegmentedControl.selectedSegmentIndex)
    loginOrRegistrationButton.setTitle(title, for: .normal)
    
    // adapt the view height based on the SegmetedControl toggle
    textFieldsContainerViewHeighAnchor?.constant = loginOrRegistrationSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
    // height of nameTextfield based on the SegmetedControl toggle
    nameTextFieldHeighAnchor?.isActive = false
    nameTextFieldHeighAnchor = nameTextField.heightAnchor.constraint(equalTo: textFieldsContainerView.heightAnchor, multiplier: loginOrRegistrationSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
    nameTextFieldHeighAnchor?.isActive = true
    //adapt the height of the email and password textField
    emailTextFieldHeighAnchor?.isActive = false
    emailTextFieldHeighAnchor = emailTextField.heightAnchor.constraint(equalTo: textFieldsContainerView.heightAnchor, multiplier: loginOrRegistrationSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    emailTextFieldHeighAnchor?.isActive = true
    passwordTextFieldHeighAnchor?.isActive = false
    passwordTextFieldHeighAnchor = passwordTextField.heightAnchor.constraint(equalTo: textFieldsContainerView.heightAnchor, multiplier: loginOrRegistrationSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    passwordTextFieldHeighAnchor?.isActive = true
  }

}
