//
//  Estensions.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 28/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit

// here we are caching our image so we don't need to download it the next time we access it

let imageCache = NSCache<AnyObject, AnyObject>()


extension UIImageView
{
  func loadImageUsingCache(with urlString: String)
  {
    //to avoid the image flashing when downloaded
    self.image = nil
    
    //use cached image if already downloaded
    if let cachedImage = imageCache.object(forKey: urlString as! AnyObject) as? UIImage
    {
      self.image = cachedImage
      return
    }
    
    // otherwise download the image
    let url = URL(string: urlString)
    URLSession.shared.dataTask(with: url!, completionHandler:
      {
        (data, response, error) in
        if error != nil{
          print(error)
          return
        }
        DispatchQueue.main.async(execute: {
          //cell.imageView?.image = UIImage(data: data!)
          //cell.customProfileImageView.image = UIImage(data: data!)
          if let downloadedImage = UIImage(data: data!)
          {
            imageCache.setObject(downloadedImage, forKey: urlString as! AnyObject)
            self.image = downloadedImage
          }
        })
    }).resume()
  }
}
