//
//  Audiobook+CoreDataProperties.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 09.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//
//

import Foundation
import CoreData


extension Audiobook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Audiobook> {
        return NSFetchRequest<Audiobook>(entityName: "Audiobook")
    }

    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var image: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var tracks: NSObject?
    @NSManaged public var newRelationship: Library?

}
