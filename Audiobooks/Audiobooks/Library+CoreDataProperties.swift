//
//  Library+CoreDataProperties.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 09.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//
//

import Foundation
import CoreData


extension Library {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Library> {
        return NSFetchRequest<Library>(entityName: "Library")
    }

    @NSManaged public var books: NSMutableArray
    


}
