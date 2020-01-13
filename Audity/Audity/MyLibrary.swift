//
//  MyLibrary.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 08.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import Foundation

class MyLibrary: Codable {
   static var myBooks: [Audiobook] = []
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("audiobooks.plist") //has to be like this in order to be working
    
    
    static func saveToFile(books: [Audiobook]){
        let propertyListEncoder = PropertyListEncoder()
        let encodedBooks = try? propertyListEncoder.encode(books)
        try? encodedBooks?.write(to: ArchiveURL, options: .noFileProtection)
        
    }
    
    static func loadFromFile() -> [Audiobook]? {
        guard let codedBooks = try? Data(contentsOf: ArchiveURL) else { return nil }
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<Audiobook>.self, from: codedBooks)
    }
}
