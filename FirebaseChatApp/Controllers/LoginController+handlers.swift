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
          print(error)
          return
        }
        guard let uid = Auth.auth().currentUser?.uid else{ return }
        
        // Successufully authenticated user
      
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
            
            // we get from the database the profile image url thus we can register it with the user credentials
            storage.downloadURL(completion:
              {
                (url, error) in
                if error != nil {
                  print(error!)
                  return
                }
                if let imageUrl = url?.absoluteString //optional bindig automatically unwrap
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
    let ref = Database.database().reference(fromURL: "https://fir-chattapp-56db4.firebaseio.com/")
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
//      let user = User(dictionary: values)
//      user.name = values["name"]
//      user.email = values["email"]
//      user.profileImageUrl = values["profileImageUrl"]
      //user.setValuesForKeys(values) //this will crash if key and properties don't match
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
  
  

}
