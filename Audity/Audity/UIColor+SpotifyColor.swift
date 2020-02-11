//
//  UIColor+SpotifyColor.swift
//  Audity
//
//  Created by Julia Zamaitat on 06.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

extension UIColor {
    struct SpotifyColor {
        static let Green = UIColor.init(netHex: 0x1DB954)
        static let Black = UIColor.init(netHex: 0x191414)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

