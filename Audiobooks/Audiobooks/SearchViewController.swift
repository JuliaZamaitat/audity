//
//  SearchViewController.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 07.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collection: UICollectionView!
    
    
    var searchActive = false
    var audiobookArray = [AudiobookTemporary]()
    var currentAudiobookArray = [AudiobookTemporary]() //to update the table
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAudiobooks()
        setUpSearchBar()
        adjustStyle()
        collection.delegate = self
        collection.dataSource = self
        collection.keyboardDismissMode = .onDrag
        //resetAllRecords(in: "Audiobook")
    }
    
    func resetAllRecords(in entity: String){
        
        let context = PersistenceService.context
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Audiobook")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
            print ("There was an error")
        }
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
    
    private func setUpAudiobooks() {
        var tracksArray = [Track]()
        for n in 1...10 {
            let mTrack = Track(title: "Kapitel \(n)", length: "12 minutes")
            tracksArray.append(mTrack)
        }
        /*let audiobook = Audiobook(context: PersistenceService.context)
        audiobook.title = "GRM-Brainfuck"
        audiobook.author = "Sibylle Berg"
        audiobook.image = "grm"
        audiobook.releaseDate = "2019-02-22"
        
        let audiobook2 = Audiobook(context: PersistenceService.context)
        audiobook2.title = "The Color in Anything"
        audiobook2.author = "James Blake"
        audiobook2.image = "james"
        audiobook2.releaseDate = "2019-02-22"*/
        /*let mTracks = Tracks(tracks: tracksArray, count: tracksArray.count)

        let archived = UserDefaults.standard.object(forKey: "mTracks")
        archived.count
        
        audiobook.tracks = mTracks*/
        //audiobookArray.append(audiobook)
        //audiobookArray.append(audiobook2)
        
      
        
        
        audiobookArray.append(AudiobookTemporary(title: "Auch GRM-Brainfuck", author: "Sibylle Berg", image: "james", releaseDate: "2012-12-03", trackList: tracksArray))
        audiobookArray.append(AudiobookTemporary(title: "GRM-Brainfuck", author: "Sibylle Berg", image: "tjh", releaseDate: "2001-07-22", trackList: tracksArray))
        audiobookArray.append(AudiobookTemporary(title: "Mal etwas anderes", author: "Hase", image: "roosevelt", releaseDate: "2019-02-22", trackList: tracksArray))
        audiobookArray.append(AudiobookTemporary(title: "FML", author: "Julia Zamaitat", image: "grm", releaseDate: "2019-02-22", trackList: tracksArray))
        audiobookArray.append(AudiobookTemporary(title: "HAHAHA", author: "Libre", image: "james", releaseDate: "2019-02-22", trackList: tracksArray))
        audiobookArray.append(AudiobookTemporary(title: "Wo sind meine Fische?", author: "Norman Rittr", image: "roosevelt", releaseDate: "2019-02-22", trackList: tracksArray))
        audiobookArray.append(AudiobookTemporary(title: "Raus mit die Viecher", author: "Karin Ritter", image: "tjh", releaseDate: "2019-02-22", trackList: tracksArray))
        
        currentAudiobookArray = audiobookArray
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
        cell.coverImage.image = UIImage(named: currentAudiobookArray[indexPath.row].image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
   

    // MARK: -Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        
        guard !searchText.isEmpty else {
            currentAudiobookArray = audiobookArray
            collection.reloadData()
            return}
        currentAudiobookArray = audiobookArray.filter({ audiobook -> Bool in
            audiobook.title.lowercased().contains(searchText.lowercased())
        })
        collection.reloadData()
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
        searchActive = false
        searchBar.showsCancelButton = false
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
