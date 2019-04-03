//
//  PhotosParser.swift
//  Virtual Tourist
//
//  Created by InstaDeep Team  on 2/15/19.
//  Copyright © 2019 InstaDeep Team . All rights reserved.
//

import Foundation

struct PhotosParser: Codable {
    let photos: Photos
}

struct Photos: Codable {
    let pages: Int
    let photo: [PhotoParser]
}

struct PhotoParser: Codable {
    
    let url: String?
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_n"
        case title
    }
}
