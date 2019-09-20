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
    
    @objc private func showMiniPlayer(){
        miniPlayerView.isHidden = false
        miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(miniPlayerView)
        let title = AppDelegate.sharedInstance.currentTrack?.title
        let author = AppDelegate.sharedInstance.currentAlbum?.author
        
        expandPlayerButton.setTitle("\(title!) - \(author!)", for: .normal)
        let tabBarHeight = AppDelegate.sharedInstance.tabBarHeight
        //let height = CGFloat(view.frame.height) - tabBarHeight!
     
        //let topConstraint = NSLayoutConstraint(item: miniPlayerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: height)
        
        /*let bottomConstraint = NSLayoutConstraint(item: miniPlayerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 300)
        view.addConstraints([bottomConstraint])*/
       
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
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
