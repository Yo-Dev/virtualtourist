//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by InstaDeep Team  on 2/15/19.
//  Copyright © 2019 InstaDeep Team . All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    
    
    convenience init(title: String, imageUrl: String, forPin: Pin, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = title
            self.image = nil
            self.imageUrl = imageUrl
            self.pin = forPin
        } else {
            fatalError("Unable to find  name!")
        }
    }
    
}
