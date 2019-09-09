//
//  Track.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 08.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Track: NSObject, NSCoding {
    var title: String = ""
    var length: String = ""
    
    enum Key:String{
        case title = "title"
        case length = "length"
    }
    init(title: String, length: String) {
        self.title = title
        self.length = length
    }
    
    public override init() {
        super.init()
    }
    
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: Key.title.rawValue)
        aCoder.encode(length, forKey: Key.length.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let mTitle = aDecoder.decodeObject(forKey: Key.title.rawValue) as! String
        let mLength = aDecoder.decodeObject(forKey: Key.length.rawValue) as! String
        self.init(title: mTitle, length: mLength)
    }
    
    
}
