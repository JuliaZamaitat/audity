//
//  Track.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 08.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import Foundation
import UIKit

class Track: NSObject, NSCoding {
    
    
    var title: String = ""
    var length: String = ""
    
    init(title: String, length: String) {
        self.title = title
        self.length = length
    }
    
    public func encode(with aCoder: NSCoder){
        aCoder.encode(title, forKey: "title")
        aCoder.encode(length, forKey: "length")
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.length = aDecoder.decodeObject(forKey: "length") as! String
        
    }
}
