//
//  Estensions.swift
//  FirebaseChatApp
//
//  Created by Gianni Gianino on 28/07/2018.
//  Copyright © 2018 indie. All rights reserved.
//

import UIKit
import Firebase


// MARK: Properties

// image caching thus we avoid to re-download the image if already done
let imageCache = NSCache<NSString, UIImage>()


// MARK: Extensions

extension UIImageView
{
  func loadImageUsingCache(with urlString: String)
  {
    //to avoid the image flashing when downloaded
    self.image = nil
    //use cached image if already downloaded
    if let cachedImage = imageCache.object(forKey: NSString(string: urlString))
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
          print(error!)
          return
        }
        DispatchQueue.main.async(execute: {
          //cell.imageView?.image = UIImage(data: data!)
          //cell.customProfileImageView.image = UIImage(data: data!)
          if let downloadedImage = UIImage(data: data!)
          {
            imageCache.setObject(downloadedImage, forKey: NSString(string: urlString))
            self.image = downloadedImage
          }
        })
    }).resume()
  }
}


/// Extension to make easier to setup color

extension UIColor
{
  convenience init(r: CGFloat, g: CGFloat, b: CGFloat)
  {
    self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
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

