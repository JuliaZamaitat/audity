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
    static var audiobook: Audiobook?
    static var currentTrack: Track?
    static var queue: [Track]?
    var statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
 
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    private var subscribedToPlayerState: Bool = false
    
    
    private var trackIdentifier = ""
    private var position: Float = 0
    
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
        if (PlayerViewController.currentTrack != nil){
            trackIdentifier = PlayerViewController.currentTrack!.uri
            AppDelegate.sharedInstance.currentTrack = PlayerViewController.currentTrack
            AppDelegate.sharedInstance.currentAlbum = PlayerViewController.audiobook
            print("im viewDidLoad: \(PlayerViewController.queue!.count)")
            AppDelegate.sharedInstance.currentQueue = PlayerViewController.queue
            print("Mein Identifier: \(trackIdentifier)")
        } else {
            PlayerViewController.currentTrack = AppDelegate.sharedInstance.currentTrack
            PlayerViewController.audiobook = AppDelegate.sharedInstance.currentAlbum
            print("Count der Audiobook Trackliste: \(PlayerViewController.audiobook!.trackList.count)")
            trackIdentifier = PlayerViewController.currentTrack!.uri
            PlayerViewController.queue = AppDelegate.sharedInstance.currentQueue
        }
       
        //check if new song title was clicked or just player opened
        if !(trackIdentifier == PlayerViewController.myPlayerState?.track.uri) {
             playTrack()
        }
       
        /*for track in audiobook!.trackList {
            enqueueTrack(identifier: track.uri)
        }*/
        NotificationCenter.default.addObserver(self, selector: #selector(activateTimer), name: NSNotification.Name("trackChanged"), object: nil)
        adjustBackground()
        guard let audiobook = PlayerViewController.audiobook else {return}
        let url = audiobook.image
        let data = try? Data(contentsOf: url)
        coverImage.image = UIImage(data: data!)
        progressSlider.isContinuous = true
        progressSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateSlider), userInfo: nil , repeats: true)
        authorLabel.text = audiobook.author
        updateTrackInfo()
    }
    
    func updateTrackInfo(){
        titleLabel.text = PlayerViewController.currentTrack?.title
        duration_ms = Float(PlayerViewController.currentTrack!.duration)
        progressSlider.maximumValue = duration_ms!
        
        let artistNames = PlayerViewController.currentTrack?.artists
        let joinedArtistNames = artistNames?.joined(separator: ", ")
        descriptionLabel.text = joinedArtistNames
    }


    override func viewWillAppear(_ animated: Bool) {
       NotificationCenter.default.post(name: NSNotification.Name("viewLoaded"), object: nil)
        
}
    
    /*override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        
    }*/
    
    /*override func viewDidAppear(_ animated: Bool) {
        
    }*/
    
    /*override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }*/
    
    
    @objc private func activateTimer(){
        //timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateSlider), userInfo: nil , repeats: true)
        getPlayerState()
        print("Im Listener: \(PlayerViewController.myPlayerState!.playbackPosition)" )
    }
    
   @objc private func updateSlider() {
       getPlayerState() //IS there another way?
       position = Float(PlayerViewController.myPlayerState!.playbackPosition)
    print("meine position: \(position)")
        progressSlider.value = position
        let remainingTimeInSeconds = PlayerViewController.currentTrack!.duration/1000 - Int(position/1000)
        timeRemainingLabel.text = "-\(getFormattedTime(timeInterval: Double(remainingTimeInSeconds)))"
        timeElapsedLabel.text = getFormattedTime(timeInterval: Double(position/1000))
        if (duration_ms! - position < 1000){
            timer?.invalidate()
            print("Here bitch!")
            updatePlayingQueue()
        }
    }
    
    //checks is song is about to end, plays next track from the album and stops if there are none
    
   
    func updatePlayingQueue(){
        
            // let position = Float(PlayerViewController.myPlayerState!.playbackPosition)
            if !(PlayerViewController.queue!.isEmpty){
                print("Titel in queue: \(PlayerViewController.queue![0].title)")
                PlayerViewController.currentTrack = PlayerViewController.queue![0]
                trackIdentifier =  PlayerViewController.currentTrack!.uri
                print("neuer identifier: \(trackIdentifier)")
                AppDelegate.sharedInstance.currentTrack = PlayerViewController.currentTrack
                PlayerViewController.queue = []
                let start = PlayerViewController.audiobook!.trackList.firstIndex(of: PlayerViewController.currentTrack!)!
                let end = PlayerViewController.audiobook!.trackList.count
                for i in start+1..<end {
                    PlayerViewController.queue!.append(PlayerViewController.audiobook!.trackList[i])
                    }
               
                playTrack()
                updateTrackInfo()
               //TODO when this is finished, timer has to be turned on again!  timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateSlider), userInfo: nil , repeats: true)
            } else {
                pausePlayback()
                //timer?.invalidate()
            }
         
        
    }
    
    
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            timer?.invalidate()
            switch touchEvent.phase {
            case .ended:
                let position = Int(self.progressSlider.value)
                self.appRemote.playerAPI?.seek(toPosition: position, callback: { (result, error) in
                    guard error == nil else {
                        return
                    }
                    if result != nil {
                        self.timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.updateSlider), userInfo: nil , repeats: true)
                        print("Audiobook Tracklist Count: \(PlayerViewController.audiobook?.trackList.count)")
                    }
                })
            default:
                break
            }
        }
        
    }
    
    func getFormattedTime(timeInterval: TimeInterval) -> String {
        let mins = timeInterval / 60
        let secs = timeInterval.truncatingRemainder(dividingBy: 60)
        let timeformatter = NumberFormatter()
        timeformatter.minimumIntegerDigits = 2
        timeformatter.minimumFractionDigits = 0
        timeformatter.roundingMode = .down
        guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
            return ""
        }
        return "\(minsStr):\(secsStr)"
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
        getPlayerState()
        print("Position vom Player im Play Track: \(PlayerViewController.myPlayerState!.playbackPosition)")
      
        print("That's the uri of the track currently played: \(trackIdentifier)")
        NotificationCenter.default.post(name: NSNotification.Name("trackChanged"), object: nil)
        //NotificationCenter.default.post(name: NSNotification.Name("colorTitle"), object: nil)
      
        print("Neue Warteschlange: \(PlayerViewController.queue)")
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
        let position = PlayerViewController.myPlayerState!.playbackPosition
        let seconds_in_milliseconds = 15000
        self.appRemote.playerAPI?.seek(toPosition: position + seconds_in_milliseconds, callback: { (result, error) in
            guard error == nil else {
                print(error)
                return
            }
        })
    }
    
    @IBAction func didPressSkipBackward15Button(_ sender: UIButton) {
        let position = PlayerViewController.myPlayerState!.playbackPosition
        let seconds_in_milliseconds = 15000
        self.appRemote.playerAPI?.seek(toPosition: position - seconds_in_milliseconds, callback: { (result, error) in
            guard error == nil else {
                print(error)
                return
            }
        })
    }
    
    @IBAction func didPressPreviousButton(_ sender: AnyObject) {
        skipPrevious()

    }
    
    @IBAction func didPressNextButton(_ sender: AnyObject) {
        skipNext()
    }
    
    private func skipPrevious() {
        appRemote.playerAPI?.skip(toPrevious: defaultCallback)
    }
    
    private func skipNext() {
        appRemote.playerAPI?.skip(toNext: defaultCallback)
    }
    
    private func enqueueTrack(identifier: String) {
        appRemote.playerAPI?.enqueueTrackUri(identifier, callback: defaultCallback)
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
        //updateUI()
        
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
