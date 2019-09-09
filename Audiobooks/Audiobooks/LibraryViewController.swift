//
//  LibraryViewController.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 06.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchActive = false
    var audiobookArray = MyLibrary.myBooks
    var currentAudiobookArray = [Audiobook]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
        adjustStyle()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    //In order to hide navigation bar after clicked on search result
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = UIColor.SpotifyColor.Black //removes glitches
        if searchActive {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    
    //To hide navigation bar when collectionView is crolled
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
            
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
 
    private func setUpSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "In deiner Bibliothek suchen"
        searchBar.backgroundImage = UIImage() //needs to be added in order for the color to work
        searchBar.barTintColor = UIColor.SpotifyColor.Black
        searchBar.isTranslucent = false
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                // Background color
                backgroundview.backgroundColor = UIColor.white
                // Rounded corner
                backgroundview.layer.cornerRadius = 7;
                backgroundview.clipsToBounds = true;
            }
        }
        
        //sets up the cancel button
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        
    }
    
    private func adjustStyle() {
        //Sets up header
        title = "Bibliothek"
        navigationController?.navigationBar.barStyle = .black //to keep the white system controls and titles
        navigationController?.navigationBar.barTintColor = UIColor.SpotifyColor.Black
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage() //to make the border disappear
        
        //Sets up content view
        tableView.backgroundColor = UIColor.SpotifyColor.Black
        tableView.separatorStyle = .none
        
        //Sets up tab bar
        tabBarController?.tabBar.barTintColor = UIColor.SpotifyColor.Black
        tabBarController?.tabBar.tintColor = .white
        
    }
    
    // MARK: -Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        guard !searchText.isEmpty else {
            currentAudiobookArray = audiobookArray
            tableView.reloadData()
            return}
        currentAudiobookArray = audiobookArray.filter({ audiobook -> Bool in
            audiobook.title.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        //searchBar.barTintColor = UIColor.init(netHex: 0x1b1b1b)
        searchActive = true
        searchBar.showsCancelButton = true
    }
    
    //brings the navigation bar back
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.endEditing(true)
        searchActive = false
        searchBar.showsCancelButton = false
    }
    
    //Needed so search bar disappeard when "Suchen" on keyboard is pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
        searchBar.barTintColor = UIColor.SpotifyColor.Black
        searchBar.tintColor = .black
        searchActive = false
        searchBar.showsCancelButton = false
    }
    

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentAudiobookArray.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "libraryCell", for: indexPath) as? LibraryTableViewCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = currentAudiobookArray[indexPath.row].title
        cell.authorLabel.text = currentAudiobookArray[indexPath.row].author
        cell.coverImage.image = UIImage(named: currentAudiobookArray[indexPath.row].image)
        cell.lengthLabel.text = "120 min"
        cell.releaseYearLabel.text = currentAudiobookArray[indexPath.row].releaseDate
        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}