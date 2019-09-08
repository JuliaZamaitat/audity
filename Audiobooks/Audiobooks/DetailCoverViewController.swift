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
    
    @IBOutlet weak var addToLibraryButton: UIButton!
   
    var audiobook: Audiobook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustStyle()
        guard let audiobook = audiobook else {return}
        coverImage.image = UIImage(named: audiobook.image)
        titelLabel.text = audiobook.title
        // Do any additional setup after loading the view.
    }
    
    func adjustStyle() {
        view.backgroundColor = UIColor.SpotifyColor.Black
        
        addToLibraryButton.layer.borderWidth = 0.5
        addToLibraryButton.layer.cornerRadius = 15
        
        addToLibraryButton.layer.borderColor = UIColor.white.cgColor
    }

    @IBAction func addToLibraryButtonTapped(_ sender: Any) {
       
        if MyLibrary.myBooks.contains(audiobook!) {
            let alert = UIAlertController(title: "Ups", message: "Du hast das Hörbuch bereits gespeichert", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Schließen", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            MyLibrary.myBooks.append(audiobook!)
            let alert = UIAlertController(title: "Yeay", message: "Erfolgreich hinzugefügt", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Schließen", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
