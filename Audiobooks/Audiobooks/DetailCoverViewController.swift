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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustStyle()
        // Do any additional setup after loading the view.
    }
    
    func adjustStyle() {
        view.backgroundColor = UIColor.SpotifyColor.Black
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
