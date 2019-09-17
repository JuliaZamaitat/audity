//
//  DetailDescriptionViewController.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 08.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

class DetailDescriptionViewController: UIViewController {

    var audiobook: Audiobook?
  
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
   
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.SpotifyColor.Black
        guard let audiobook = audiobook else {return}
        releaseDateLabel.text = audiobook.releaseDate
        let author = audiobook.author
        let title = audiobook.title
        let joinedString = "\(title) von \(author)"
        descriptionLabel.text = joinedString
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lengthLabel.text = "\(audiobook!.duration) min"
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
