//
//  DetailCoverViewController.swift
//  Audity
//
//  Created by Julia Zamaitat on 08.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

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
        let url = audiobook.image
        let data = try? Data(contentsOf: url)
        coverImage.image = UIImage(data: data!)
        coverImage.contentMode = .scaleAspectFit
        titelLabel.text = audiobook.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if MyLibrary.myBooks.contains(audiobook!){
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
        titelLabel.adjustsFontSizeToFitWidth = true
    }

    @IBAction func addToLibraryButtonTapped(_ sender: Any) {
        if let book = audiobook {
            if MyLibrary.myBooks.contains(book) {
                if let index = MyLibrary.myBooks.firstIndex(of: book){
                    MyLibrary.myBooks.remove(at: index)
                    let alert = UIAlertController(title: "Bye", message: "Hörbuch entfernt", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Schließen", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    addToLibraryButton.setTitle("Zur Bibliothek hinzufügen", for: .normal)
                    MyLibrary.saveToFile(books: MyLibrary.myBooks)
                }
               
            } else {
                MyLibrary.myBooks.append(book)
                let alert = UIAlertController(title: "Yeay", message: "Erfolgreich hinzugefügt", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Schließen", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                addToLibraryButton.setTitle("Aus Bibliothek entfernen", for: .normal)
                MyLibrary.saveToFile(books: MyLibrary.myBooks)
            }
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
