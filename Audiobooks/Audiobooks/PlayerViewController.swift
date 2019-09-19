//
//  PlayerViewController.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 06.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

class PlayerViewController: ViewControllerPannable, SPTAppRemotePlayerStateDelegate {
   
    
    static var myPlayerState: SPTAppRemotePlayerState?
    var duration_ms: Float?
    var timer: Timer?
    var audiobook: Audiobook?
    var currentTrack: Track?
    var statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
    var count = 1
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    
    private var subscribedToPlayerState: Bool = false
    
    
    private var trackIdentifier = ""
    
    var isPlaying: Bool = true {
        didSet {
            if isPlaying {
                playPauseButton.setImage(UIImage(named:"round-pause-button-white")!, for: .normal)
            } else {
                playPauseButton.setImage(UIImage(named: "play-button-round-white"), for: .normal)
            }
        }
    }
    
    var appRemote: SPTAppRemote {
        get {
            return AppDelegate.sharedInstance.appRemote
        }
    }
    
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPlayerState()

        if (currentTrack != nil){
            trackIdentifier = currentTrack!.uri
            AppDelegate.sharedInstance.currentTrack = currentTrack
            AppDelegate.sharedInstance.currentAlbum = audiobook
            print("Mein Identifier: \(trackIdentifier)")
        } else {
            currentTrack = AppDelegate.sharedInstance.currentTrack
            audiobook = AppDelegate.sharedInstance.currentAlbum
            trackIdentifier = currentTrack!.uri
        }
       
        //check if new song title was clicked or just player opened
        if !(trackIdentifier == PlayerViewController.myPlayerState?.track.uri) {
             playTrack()
        }
       
      
       
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.updateSlider), userInfo: nil , repeats: true)
        
        adjustBackground()
        guard let audiobook = audiobook else {return}
        let url = audiobook.image
        let data = try? Data(contentsOf: url)
        coverImage.image = UIImage(data: data!)
        titleLabel.text = currentTrack?.title
        duration_ms = Float(currentTrack!.duration)
        progressSlider.maximumValue = duration_ms!
        progressSlider.isContinuous = true
        progressSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
        let artistNames = currentTrack?.artists
        let joinedArtistNames = artistNames?.joined(separator: ", ")
        descriptionLabel.text = joinedArtistNames
        authorLabel.text = audiobook.author
    }
    
    override func viewWillAppear(_ animated: Bool) {
       NotificationCenter.default.post(name: NSNotification.Name("viewLoaded"), object: nil)
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        
    }*/
    
   @objc private func updateSlider() {
        getPlayerState() //IS there another way?
        var position = Float(PlayerViewController.myPlayerState!.playbackPosition)
        progressSlider.value = position
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            timer?.invalidate()
            switch touchEvent.phase {
            case .ended:
                var position = Int(self.progressSlider.value)
                self.appRemote.playerAPI?.seek(toPosition: position, callback: { (result, error) in
                    guard error == nil else {
                        return
                    }
                    if result != nil {
                        self.timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.updateSlider), userInfo: nil , repeats: true)
                    }
                })
            default:
                break
            }
        }
        
    }
    
 
    
    
    private func getPlayerState() {
        appRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            PlayerViewController.myPlayerState = result as? SPTAppRemotePlayerState
        }
    }
    
    private func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
            print(error.description)
        }
    }
    
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        animateCover()
        playOrPause()
    }
    
    func playOrPause(){
        
        if !(appRemote.isConnected) {
            
            // The Spotify app is not installed, present the user with an App Store page
            
        } else if PlayerViewController.myPlayerState == nil || PlayerViewController.myPlayerState!.isPaused {
            print("About to start")
            startPlayback()
            
        } else {
            print("About to pause")
            pausePlayback()
            count += 1
        }
    }
    
   
    
    private func startPlayback() {
        appRemote.playerAPI?.resume(defaultCallback)
         //appRemote.playerAPI?.play(trackIdentifier, callback: defaultCallback)
    }
    
    private func pausePlayback() {
        appRemote.playerAPI?.pause(defaultCallback)
    }
    
    private func playTrack() {
        appRemote.playerAPI?.play(trackIdentifier, callback: defaultCallback)
        
    }
    
    func animateCover(){
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
    
    
    func adjustBackground(){
        view.layer.cornerRadius = 20.0
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        statusBar?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        statusBar?.isHidden = false
    }
    
    
    @IBAction func didPressSkipForward15Button(_ sender: UIButton) {
        var position = PlayerViewController.myPlayerState!.playbackPosition
        var seconds_in_milliseconds = 15000
        self.appRemote.playerAPI?.seek(toPosition: position + seconds_in_milliseconds, callback: { (result, error) in
            guard error == nil else {
                print(error)
                return
            }
        })
    }
    
    @IBAction func didPressSkipBackward15Button(_ sender: UIButton) {
        var position = PlayerViewController.myPlayerState!.playbackPosition
        var seconds_in_milliseconds = 15000
        self.appRemote.playerAPI?.seek(toPosition: position - seconds_in_milliseconds, callback: { (result, error) in
            guard error == nil else {
                print(error)
                return
            }
        })
    }
    
    
    // MARK: - <SPTAppRemotePlayerStateDelegate>
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        PlayerViewController.myPlayerState = playerState
        print("player state changed")
        print("isPaused", playerState.isPaused)
        print("track.uri", playerState.track.uri)
        print("track.name", playerState.track.name)
        print("track.imageIdentifier", playerState.track.imageIdentifier)
        print("track.artist.name", playerState.track.artist.name)
        print("track.album.name", playerState.track.album.name)
        print("track.isSaved", playerState.track.isSaved)
        print("playbackSpeed", playerState.playbackSpeed)
        print("playbackOptions.isShuffling", playerState.playbackOptions.isShuffling)
        print("playbackOptions.repeatMode", playerState.playbackOptions.repeatMode.hashValue)
        print("playbackPosition", playerState.playbackPosition)
        
    }
    
    private func subscribeToPlayerState() {
        guard (!subscribedToPlayerState) else { return }
        appRemote.playerAPI!.delegate = self
        appRemote.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
        }
    }
    
    private func unsubscribeFromPlayerState() {
        guard (subscribedToPlayerState) else { return }
        appRemote.playerAPI?.unsubscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = false
        }
    }
    
    func appRemoteConnected() {
        //subscribeToPlayerState()
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
        getPlayerState()
    }
    
     func appRemoteDisconnect() {
        self.subscribedToPlayerState = false
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
