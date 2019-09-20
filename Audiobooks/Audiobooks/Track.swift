//
//  Track.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 08.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import Foundation
import UIKit

struct Track: Codable, Equatable {
    var title: String = ""
    //ar length: String = ""
    var artists: [String] = []
    var duration: Int = 0
    var uri: String
    
    init(title: String, artists: [String], duration: Int, uri: String) {
        self.title = title
        self.artists = artists
        self.duration = duration
        self.uri = uri
       
    }
}
