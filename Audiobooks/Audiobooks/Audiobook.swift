//
//  Audiobook.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 07.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import Foundation
import UIKit


struct Audiobook: Equatable, Codable {
    
    
    let title: String
    let author: String
    let image: String
    let releaseDate: String
    let trackList: [Track]
    
    enum Keys: String, CodingKey {
        case title
        case author
        case image
        case releaseDate
        case trackList
    }
    
    /*init(title: String, author: String, image: String, releaseDate: String, trackList: [Track]) {
        self.title = title
        self.author = author
        self.image = image
        self.releaseDate = releaseDate
        self.trackList = trackList
        //self.releaseDate = dateformat(date: releaseDate)
    }*/
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: Keys.self)
        self.title = try valueContainer.decode(String.self, forKey: Keys.title)
        self.author = try valueContainer.decode(String.self, forKey: Keys.author)
        self.image = try valueContainer.decode(String.self, forKey: Keys.image)
        self.releaseDate = try valueContainer.decode(String.self, forKey: Keys.releaseDate)
        self.trackList = [try valueContainer.decode(Track.self, forKey: Keys.trackList)]
    }
    
    static func == (lhs: Audiobook, rhs: Audiobook) -> Bool {
        return lhs.title == rhs.title && lhs.author == rhs.author && lhs.releaseDate == rhs.releaseDate
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
