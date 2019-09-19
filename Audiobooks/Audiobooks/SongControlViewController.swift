//
//  SongControlViewController.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 17.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

class SongControlViewController: UIViewController {

    @IBOutlet weak var miniPlayerView: MiniPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miniPlayerView.isHidden = true
        view.backgroundColor = UIColor.SpotifyColor.Black
        NotificationCenter.default.addObserver(self, selector: #selector(showMiniPlayer), name: NSNotification.Name("viewLoaded"), object: nil)

        // Do any additional setup after loading the view.
    }
    
    @objc private func showMiniPlayer(){
         miniPlayerView.isHidden = false
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showMaxiPlayerSegue"){
            let destinationVC = segue.destination as! PlayerViewController
           
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
