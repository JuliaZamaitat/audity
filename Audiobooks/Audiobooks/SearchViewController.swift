//
//  SearchViewController.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 07.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
     let group = DispatchGroup()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collection: UICollectionView!
   
    
    var searchActive = false
    var audiobookArray = [Audiobook]()
    var currentAudiobookArray = [Audiobook]() //to update the table
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var accessToken: String?
    
    typealias JSONStandard = [String : AnyObject]
    override func viewDidLoad() {
        super.viewDidLoad()
        //setUpAudiobooks()
        setUpSearchBar()
        adjustStyle()
        collection.delegate = self
        collection.dataSource = self
        collection.keyboardDismissMode = .onDrag
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
        searchBar.placeholder = "Titel oder Autor_in"
        searchBar.backgroundImage = UIImage() //needs to be added in order for the color to work
        searchBar.barTintColor = UIColor.SpotifyColor.Black
        searchBar.isTranslucent = false
        searchBar.tintColor = .black
       
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
        title = "Suche"
        navigationController?.navigationBar.barStyle = .black //to keep the white system controls and titles
        navigationController?.navigationBar.barTintColor = UIColor.SpotifyColor.Black
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage() //to make the border disappear
       
        //Sets up content view
        collection.backgroundColor = UIColor.SpotifyColor.Black
        
        //Sets up tab bar
        tabBarController?.tabBar.barTintColor = UIColor.SpotifyColor.Black
        tabBarController?.tabBar.tintColor = .white
        
    }
    
    func fetchAudiobooks(keywords: String, completion: @escaping (Audiobook?) -> Void){
        let baseURL = URL(string: "https://api.spotify.com/v1/search")!
        let query: [String: String] = [
            "type": "album",
            "q": "\(keywords)"
        ]
        let url = baseURL.withQueries(query)!
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
               self.parseData(JSONData: data)
            }
        }
        task.resume()
    }
    
    
    func parseData(JSONData: Data){
        var image = URL(string: "")
        var name = ""
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let albums = readableJSON["albums"] as? JSONStandard{
                if let items = albums["items"] as? [JSONStandard] {
                    for i in 0..<items.count {
                        let item = items[i]
                        let titleName = item["name"] as! String
                        let releaseDate = item["release_date"] as! String
                        let id = item["id"] as! String
                        let uri = item["uri"] as! String
                        let totalTracks = item["total_tracks"] as! Int
                        if let images = item["images"] as? [JSONStandard] {
                            let imageData = images[1]
                            let mainImageURL =  URL(string: imageData["url"] as! String)
                            image = mainImageURL!
                        }
                        if let artists = item["artists"] as? [JSONStandard] {
                            let artist = artists[0]
                            name = artist["name"] as! String
                        }
                        //if audiobookArray.contains(id)
                        audiobookArray.append(Audiobook.init(id: id, title: titleName, author: name, image: image!, releaseDate: releaseDate,totalTracks: totalTracks, trackList: [], duration: 0, uri: uri))
                        currentAudiobookArray = audiobookArray
                        DispatchQueue.main.async {
                            self.collection.reloadData()
                        }
                    }
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentAudiobookArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(withReuseIdentifier: "searchCollectionCell", for: indexPath) as? SearchCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.titleLabel.text = currentAudiobookArray[indexPath.row].title
        cell.authorLabel.text = currentAudiobookArray[indexPath.row].author
        let url = currentAudiobookArray[indexPath.row].image
        let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        cell.coverImage.image = UIImage(data: data!)
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
   

    // MARK: -Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationController?.setNavigationBarHidden(true, animated: true)
         //searchBar.barTintColor = UIColor.init(netHex: 0x1b1b1b)
       searchActive = true
        searchBar.showsCancelButton = true
        accessToken = AppDelegate.sharedInstance.accessToken
        audiobookArray = []
        collection.reloadData()
    
    }
    
    //brings the navigation bar back
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.endEditing(true)
        searchActive = false
        searchBar.showsCancelButton = false
        currentAudiobookArray = []
        audiobookArray = []
        collection.reloadData()
    }
    
    //Needed so search bar disappeard when "Suchen" on keyboard is pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
        searchBar.barTintColor = UIColor.SpotifyColor.Black
        searchActive = false
        searchBar.showsCancelButton = false
        let keywords = searchBar.text
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")
        fetchAudiobooks(keywords: finalKeywords!) {(audiobook) in
            if let audiobook = audiobook {
                /*print("here")
                 DispatchQueue.main.async {
                 self.collection.reloadData()*/
                
            }
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowDetailsSegue") {
           let destinationVC = segue.destination as! AudiobookDetailViewController
           if let cell = sender as? UICollectionViewCell,
            let indexPath = self.collection.indexPath(for: cell){
                let audiobook = currentAudiobookArray[indexPath.row]
                destinationVC.audiobook = audiobook
            }
        }
    }
}

//For custom size of the collectionView cells
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200 , height: 250)
    }
}
