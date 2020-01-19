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
    var audiobookArray: [Audiobook] = []
    var currentAudiobookArray = [Audiobook]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
        adjustStyle()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
    }
    
    
    //In order to hide navigation bar after clicked on search result
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = UIColor.SpotifyColor.Black //removes glitches
        audiobookArray = MyLibrary.myBooks
        currentAudiobookArray = audiobookArray
        tableView.reloadData()
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
        
        if #available(iOS 13, *) {
            self.searchBar.searchTextField.backgroundColor = .white
             self.searchBar.tintColor = .black
        }
        
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
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor.SpotifyColor.Black
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
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

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
             return currentAudiobookArray.count
        } else {
            return 0
        }
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "libraryCell", for: indexPath) as? LibraryTableViewCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = currentAudiobookArray[indexPath.row].title
        cell.authorLabel.text = currentAudiobookArray[indexPath.row].author
        let url = currentAudiobookArray[indexPath.row].image
        if let image = try? Data(contentsOf: url) {//make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            cell.coverImage.image = UIImage(data: image)
        }
        cell.lengthLabel.text = "\(currentAudiobookArray[indexPath.row].duration) min"
        cell.releaseYearLabel.text = currentAudiobookArray[indexPath.row].releaseDate
        cell.backgroundColor = UIColor.SpotifyColor.Black
        cell.selectionStyle = .none
        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    
    // Override to support conditional editing of the table view.
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
     func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let audiobook = currentAudiobookArray[indexPath.row]
            if let index = MyLibrary.myBooks.firstIndex(of: audiobook){
                MyLibrary.myBooks.remove(at: index)}
            currentAudiobookArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            MyLibrary.saveToFile(books: MyLibrary.myBooks)
            tableView.reloadData()
        }
    }
      
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowDetailInLibrarySegue") {
            let destinationVC = segue.destination as! AudiobookDetailViewController
            if let cell = sender as? UITableViewCell,
                let indexPath = self.tableView.indexPath(for: cell){
                let audiobook = currentAudiobookArray[indexPath.row]
                destinationVC.audiobook = audiobook
            }
            
        }
    }

}
