//
//  DetailCoverViewController.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 08.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit
import CoreData

class DetailCoverViewController: UIViewController {

   
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titelLabel: UILabel!
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var addToLibraryButton: UIButton!
   
    var audiobook: Audiobook?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustStyle()
        guard let audiobook = audiobook else {return}
        coverImage.image = UIImage(named: audiobook.image)
        titelLabel.text = audiobook.title
       
        // Do any additional setup after loading the view.
        
        
        
        
       // print(mybook)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let books = AppDelegate.library.books else { return }
        
        if (books.contains(audiobook!)){
             addToLibraryButton.setTitle("Aus Bibliothek entfernen", for: .normal)
        } else {
            addToLibraryButton.setTitle("Zur Bibliothek hinzufügen", for: .normal)
        }
    }
    func adjustStyle() {
        view.backgroundColor = UIColor.SpotifyColor.Black
        subView.backgroundColor = UIColor.SpotifyColor.Black
        addToLibraryButton.layer.borderWidth = 0.5
        addToLibraryButton.layer.cornerRadius = 15
        addToLibraryButton.layer.borderColor = UIColor.white.cgColor
        
        
    }

    @IBAction func addToLibraryButtonTapped(_ sender: Any) {
        print(AppDelegate.library.books?.count)
       
        if (AppDelegate.library.books?.contains(audiobook!))! {
            guard let index = AppDelegate.library.books?.index(of: audiobook!) else { return }
            AppDelegate.library.books?.remove(at: index)
            let alert = UIAlertController(title: "Bye", message: "Hörbuch entfernt", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Schließen", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
                addToLibraryButton.setTitle("Zur Bibliothek hinzufügen", for: .normal)
             PersistenceService.saveContext()
            }
           
            else {
            AppDelegate.library.books?.append(audiobook!)
            let alert = UIAlertController(title: "Yeay", message: "Erfolgreich hinzugefügt", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Schließen", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            addToLibraryButton.setTitle("Aus Bibliothek entfernen", for: .normal)
            PersistenceService.saveContext()
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
