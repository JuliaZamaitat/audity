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
    let releaseDate: String
    
    
    init(title: String, author: String, image: String, releaseDate: String) {
        self.title = title
        self.author = author
        self.image = image
        self.releaseDate = releaseDate
        //self.releaseDate = dateformat(date: releaseDate)
    }
    
    /* Maybe useful later when working with the Spotify API
     func dateformat(date: String) -> Date?{
    let input = date
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/mm/dd"
    guard let date = formatter.date(from: input) else {return nil}
    return date
    }*/
}
