//
//  Tracks.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 08.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Tracks: NSObject, NSCoding {
    public var tracks: [Track] = []
    public var count: Int = 0
    
    enum Key:String {
        case tracks = "tracks"
        case count = "count"
    }
    
    init(tracks: [Track], count: Int){
        self.tracks = tracks
        self.count = count
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(tracks, forKey: Key.tracks.rawValue)
        aCoder.encode(tracks, forKey: Key.count.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let mTracks = aDecoder.decodeObject(forKey: Key.tracks.rawValue) as! [Track]
        let mCount = aDecoder.decodeObject(forKey: Key.count.rawValue) as! Int
        self.init(tracks: mTracks, count: mCount)
    }
    
    
}
