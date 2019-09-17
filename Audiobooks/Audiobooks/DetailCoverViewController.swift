//
//  DetailCoverViewController.swift
//  Audiobooks
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
        let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        coverImage.image = UIImage(data: data!)
        titelLabel.text = audiobook.title
        // Do any additional setup after loading the view.
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
        if MyLibrary.myBooks.contains(audiobook!) {
            if let index = MyLibrary.myBooks.firstIndex(of: audiobook!){
                MyLibrary.myBooks.remove(at: index)
                let alert = UIAlertController(title: "Bye", message: "Hörbuch entfernt", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Schließen", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                addToLibraryButton.setTitle("Zur Bibliothek hinzufügen", for: .normal)
                
                MyLibrary.saveToFile(books: MyLibrary.myBooks)
            }
           
        } else {
            MyLibrary.myBooks.append(audiobook!)
            print("Das Hörbuch: \(audiobook!.duration)")
            let alert = UIAlertController(title: "Yeay", message: "Erfolgreich hinzugefügt", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Schließen", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            addToLibraryButton.setTitle("Aus Bibliothek entfernen", for: .normal)
            for book in MyLibrary.myBooks{
                print("Länge hier: \(book.duration)")
            }
            MyLibrary.saveToFile(books: MyLibrary.myBooks)
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
