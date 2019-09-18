//
//  PlayerViewController.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 06.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

class PlayerViewController: ViewControllerPannable {

    var audiobook: Audiobook?
    var currentTrack: Track?
     var statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var isPlaying: Bool = true {
        didSet {
            if isPlaying {
                playPauseButton.setImage(UIImage(named:"round-pause-button-white")!, for: .normal)
            } else {
                playPauseButton.setImage(UIImage(named: "play-button-round-white"), for: .normal)
            }
        }
    }
    
    @IBAction func playPauseButtonTapped(_ sender: Any) {
            if isPlaying {
                UIView.animate(withDuration: 0.3) {
                    self.coverImage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
            } else {
                UIView.animate(withDuration: 0.3, animations: { //andere Schreibweise
                    self.coverImage.transform = CGAffineTransform.identity
                })
            }
            isPlaying = !isPlaying
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor.SpotifyColor.Black
        adjustBackground()
        guard let audiobook = audiobook else {return}
        let url = audiobook.image
        let data = try? Data(contentsOf: url)
        coverImage.image = UIImage(data: data!)
        titleLabel.text = currentTrack?.title
      
        let artistNames = currentTrack?.artists
        let joinedArtistNames = artistNames?.joined(separator: ", ")
        descriptionLabel.text = joinedArtistNames
        authorLabel.text = audiobook.author
       
    }
    
    func adjustBackground(){
        view.layer.cornerRadius = 20.0
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        statusBar?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        statusBar?.isHidden = false
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
