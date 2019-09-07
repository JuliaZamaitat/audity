//
//  Audiobook.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 07.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import Foundation
import UIKit


class Audiobook {
    let title: String
    let author: String
    let image: String
    
    
    init(title: String, author: String, image: String) {
        self.title = title
        self.author = author
        self.image = image
    }
}
