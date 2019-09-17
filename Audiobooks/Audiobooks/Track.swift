//
//  Track.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 08.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import Foundation
import UIKit

struct Track: Codable {
    var title: String = ""
    //ar length: String = ""
    var id: String = ""
    var artists: [String] = []
    var duration: Int = 0
    
    init(title: String, id: String, artists: [String], duration: Int) {
        self.title = title
        self.id = id
        self.artists = artists
        self.duration = duration
       
    }
}
