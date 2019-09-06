//
//  Helper.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 06.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import Foundation

class Helper {
    static var app: Helper = {
        return Helper()
    }()
    
    /*this method adjusts the style for the basic search in the search view and library view
     It set's the navigation and tab bar items to a dark theme and styles the search bar as well as the table content view.
 */
    func adjustStyle(obj: UIViewController, tableView: UITableView, searchBarItem: UISearchBar) {
        //Sets up header
        obj.navigationController?.navigationBar.barStyle = .black //to keep the white system controls and titles
        obj.navigationController?.navigationBar.barTintColor = UIColor.SpotifyColor.Black
        
        obj.navigationController?.navigationBar.isTranslucent = false
        obj.navigationController?.navigationBar.shadowImage = UIImage() //to make the border disappear
        
        //Sets up content view
        tableView.backgroundColor = UIColor.SpotifyColor.Black
        tableView.separatorStyle = .none
        
        //Sets up tab bar
        obj.tabBarController?.tabBar.barTintColor = UIColor.SpotifyColor.Black
        obj.tabBarController?.tabBar.tintColor = .white
        
        
        //Sets up the searchbar style
        searchBarItem.backgroundImage = UIImage() //needs to be added in order for the color to work
        searchBarItem.isTranslucent = false
        searchBarItem.barTintColor = UIColor.SpotifyColor.Black
        if let textfield = searchBarItem.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                // Background color
                backgroundview.backgroundColor = UIColor.white
                // Rounded corner
                backgroundview.layer.cornerRadius = 7;
                backgroundview.clipsToBounds = true;
            }
            
        }
    }
    
}
