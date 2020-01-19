//
//  Audity.swift
//  Audity
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
    var uri: String
    
    enum Keys: String, CodingKey {
        case title
        case author
        case image
        case releaseDate
        case trackList
        case totalTracks
        case duration
        case uri
    }
    
    init(id: String, title: String, author: String, image: URL, releaseDate: String, totalTracks: Int, trackList: [Track], duration: Int, uri: String) {
        self.id = id
        self.title = title
        self.author = author
        self.image = image
        self.releaseDate = releaseDate
        self.totalTracks = totalTracks
        self.trackList = trackList
        self.duration = duration
        self.uri = uri
    }
    
    static func == (lhs: Audiobook, rhs: Audiobook) -> Bool {
        return lhs.title == rhs.title && lhs.author == rhs.author && lhs.releaseDate == rhs.releaseDate
    }
    
    mutating func getTotalDuration(){
        var minutes = 0
        if !(trackList.isEmpty){
            var ms = 0
            for track in trackList {
                ms += track.duration
            }
           minutes = ms/60000
           
        }
        duration = minutes
    }
}


