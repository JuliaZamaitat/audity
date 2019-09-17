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
    
    let id: String
    let title: String
    let author: String
    let image: URL
    let releaseDate: String
    var trackList: [Track]
    var totalTracks: Int
    var duration: Int
    
    enum Keys: String, CodingKey {
        case title
        case author
        case image
        case releaseDate
        case trackList
        case totalTracks
    }
    
    init(id: String, title: String, author: String, image: URL, releaseDate: String, totalTracks: Int, trackList: [Track], duration: Int) {
        self.id = id
        self.title = title
        self.author = author
        self.image = image
        self.releaseDate = releaseDate
        self.totalTracks = totalTracks
        self.trackList = trackList
        self.duration = duration
        //self.releaseDate = dateformat(date: releaseDate)
    }
    
    /*init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: Keys.self)
        self.title = try valueContainer.decode(String.self, forKey: Keys.title)
        self.author = try valueContainer.decode(String.self, forKey: Keys.author)
        self.image = try valueContainer.decode(String.self, forKey: Keys.image)
        self.releaseDate = try valueContainer.decode(String.self, forKey: Keys.releaseDate)
        self.trackList = [try valueContainer.decode(Track.self, forKey: Keys.trackList)]
    }*/
    
    static func == (lhs: Audiobook, rhs: Audiobook) -> Bool {
        return lhs.title == rhs.title && lhs.author == rhs.author && lhs.releaseDate == rhs.releaseDate
    }
    
    mutating func getTotalDuration(){
        var minutes = 0
        if !(trackList.isEmpty){
            var ms = 0
            for track in trackList {
                ms += track.duration
                print(ms)
            }
           minutes = ms/60000
           
        }
        print("Im Audiobook Model: \(minutes)")
        duration = minutes
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


