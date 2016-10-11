//
//  Photo+CoreDataProperties.swift
//  simple-snapchat
//
//  Created by Boqin Hu on 10/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var photo_data: NSData?
    @NSManaged public var photo_id: Int64

}
