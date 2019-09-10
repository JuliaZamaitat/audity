//
//  Track.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 08.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import Foundation
import UIKit

class Track: Codable {
    var title: String = ""
    var length: String = ""
    
    init(title: String, length: String) {
        self.title = title
        self.length = length
    }
}
