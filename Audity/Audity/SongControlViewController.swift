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
    @IBOutlet weak var expandPlayerButton: UIButton!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    var isPlaying: Bool = true {
        didSet {
            if isPlaying {
                playPauseButton.setImage(UIImage(named:"pause_button_white")!, for: .normal)
            } else {
                playPauseButton.setImage(UIImage(named: "play_button_white"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miniPlayerView.isHidden = true
        view.backgroundColor = UIColor.SpotifyColor.Black
        NotificationCenter.default.addObserver(self, selector: #selector(showMiniPlayer), name: NSNotification.Name("viewLoaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMiniPlayer), name: NSNotification.Name("trackChanged"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if PlayerViewController.isPlaying != nil {
            if PlayerViewController.isPlaying! {
                playPauseButton.setImage(UIImage(named:"pause_button_white")!, for: .normal)
                isPlaying = true
            } else {
                playPauseButton.setImage(UIImage(named: "play_button_white"), for: .normal)
                 isPlaying = false
            }
        }
    }
    
    @objc private func showMiniPlayer(){
        miniPlayerView.isHidden = false
        miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
        let title = AppDelegate.sharedInstance.currentTrack?.title
        let author = AppDelegate.sharedInstance.currentAlbum?.author
        expandPlayerButton.setTitle("\(title!) - \(author!)", for: .normal)
        //expandPlayerButton.titleLabel?.backgroundColor = .yellow
        let spacing: CGFloat = 50.0
        expandPlayerButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        let tabBarHeight = AppDelegate.sharedInstance.tabBarHeight
    }
    
    @objc func updateMiniPlayer(){
        let title = AppDelegate.sharedInstance.currentTrack?.title
        let author = AppDelegate.sharedInstance.currentAlbum?.author
        expandPlayerButton.setTitle("\(title!) - \(author!)", for: .normal)
    }
    
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        AppDelegate.sharedInstance.playerViewController.playOrPause()
        isPlaying = !isPlaying
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if (segue.identifier == "showMaxiPlayerSegue") {
            NotificationCenter.default.post(name: NSNotification.Name("miniPlayerPressed"), object: nil)
            PlayerViewController.wasSelectedOrSkipped = false
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
