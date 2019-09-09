//
//  Audiobook.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 07.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import Foundation
import UIKit


public class Audiobook: NSObject, NSCoding {
    let title: String
    let author: String
    let image: String
    let releaseDate: String
    let trackList: [Track]
    
    init(title: String, author: String, image: String, releaseDate: String, trackList: [Track]) {
        self.title = title
        self.author = author
        self.image = image
        self.releaseDate = releaseDate
        self.trackList = trackList
        //self.releaseDate = dateformat(date: releaseDate)
    }
    
    static func == (lhs: Audiobook, rhs: Audiobook) -> Bool {
        return lhs.title == rhs.title && lhs.author == rhs.author && lhs.releaseDate == rhs.releaseDate
    }
    
    public func encode(with aCoder: NSCoder){
        aCoder.encode(title, forKey: "title")
        aCoder.encode(author, forKey: "author")
        aCoder.encode(image, forKey: "image")
        aCoder.encode(releaseDate, forKey: "releaseDate")
        aCoder.encode(trackList, forKey: "trackList")
       
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as! String
         self.author = aDecoder.decodeObject(forKey: "author") as! String
         self.image = aDecoder.decodeObject(forKey: "image") as! String
         self.releaseDate = aDecoder.decodeObject(forKey: "releaseDate") as! String
         self.trackList = aDecoder.decodeObject(forKey: "trackList") as! [Track]
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
