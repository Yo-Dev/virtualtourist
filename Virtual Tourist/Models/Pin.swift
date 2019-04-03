//
//  Pin.swift
//  Virtual Tourist
//
//  Created by InstaDeep Team  on 2/15/19.
//  Copyright © 2019 InstaDeep Team . All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    static let name = "Pin"
    
    convenience init(latitude: String, longitude: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: Pin.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity ")
        }
    }
    
}
