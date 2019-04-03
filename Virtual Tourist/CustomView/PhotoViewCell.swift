//
//  PhotoViewCell.swift
//  Virtual Tourist
//
//  Created by InstaDeep Team  on 2/15/19.
//  Copyright © 2019 InstaDeep Team . All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    static let identifier = "PhotoViewCell"
    
    var imageUrl: String = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
