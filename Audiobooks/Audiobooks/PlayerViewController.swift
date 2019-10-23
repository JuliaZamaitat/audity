//
//  PlayerViewController.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 06.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

class PlayerViewController: ViewControllerPannable, SPTAppRemotePlayerStateDelegate{
   
    static var myPlayerState: SPTAppRemotePlayerState?
    var duration_ms: Float?
    var durationInSeconds: Float?
    var timer: Timer?
    var timerQueue: Timer?
    
    var playTimer: Timer!
    var sliderTimer: Timer!
    
    var oldTrackIdentifier: String?
    var oldAudioBook: String?
    
    var songFinished = false
    var newIdentifier: String?
    static var timeElapsed: Float?
    private var trackIdentifier: String?
    
    static var newIndexOfTrackInAlbum: Int?
    static var oldIndexOfTrackInAlbum: Int?
    static var audiobook: Audiobook?
    static var albumIdentifier = audiobook?.uri
    static var currentTrack: Track?
    static var helperTracklist: [Track?]?
    static var indexOfTrackInTracklist: Int?
    //var statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
    //var statusBar: NSObject?
 
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton?
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    private var subscribedToPlayerState: Bool = false
    
    

    var isPlaying: Bool?
    static var wasSelectedOrSkipped = false
    
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
    
    
    override func viewWillAppear(_ animated: Bool) {
       NotificationCenter.default.post(name: NSNotification.Name("viewLoaded"), object: nil)
        //make sure the timer does not get duplicated
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPlayerState()
        isPlaying = true
        oldTrackIdentifier = AppDelegate.sharedInstance.currentTrack?.uri
        oldAudioBook = AppDelegate.sharedInstance.currentAlbum?.uri
       
        updateCurrentAlbumAndTrack()
        self.skipToRightSong()
        
        
        activatePlayAndSliderTimer()
        adjustBackground()
        guard PlayerViewController.audiobook != nil else {return}
        updateInterface()
        updateTrackInfo()
    }
    
    //Checks where the user came from and skips to the right index in the queue
    func skipToRightSong(){
       
        //if it's the first time opening the player or a new album was selected and therefore the uri changed
        if oldTrackIdentifier == nil || oldAudioBook != PlayerViewController.audiobook!.uri  {
             PlayerViewController.oldIndexOfTrackInAlbum = PlayerViewController.newIndexOfTrackInAlbum!
             playTrackWithIdentifier(PlayerViewController.albumIdentifier!)
         }
         //check if new song title was clicked or just player opened
        else if !(oldTrackIdentifier == AppDelegate.sharedInstance.currentTrack?.uri) { //doesn't go in here becaue configureNExtSong updates AppDelegate
            PlayerViewController.wasSelectedOrSkipped = true
            let newIndex = PlayerViewController.newIndexOfTrackInAlbum!
            let oldIndex = PlayerViewController.oldIndexOfTrackInAlbum!
            //Skip forwards
            print("OldIndex: \(PlayerViewController.oldIndexOfTrackInAlbum!)")
            print("NewIndex: \(PlayerViewController.newIndexOfTrackInAlbum!)")
             if (PlayerViewController.newIndexOfTrackInAlbum! > PlayerViewController.oldIndexOfTrackInAlbum!){
                 for _ in 0..<(newIndex - oldIndex ) {
                     skipNext()
                     print("looped forward")
                     PlayerViewController.oldIndexOfTrackInAlbum! += 1
                }
               
             } else { //Skip backwards
                 for _ in 0..<(oldIndex - newIndex) {
                 skipPrevious() //not working when song was changed automatically and then new song chosen
                 print("looped backwards")
                 PlayerViewController.oldIndexOfTrackInAlbum! -= 1
                 
                 }
             }
            
         }
        PlayerViewController.wasSelectedOrSkipped = true
    }
    
    //checks whether the album has to start at a different track than the first one if another title was selected from the list
    func checkNotFirstSongWasClicked(){
        if PlayerViewController.newIndexOfTrackInAlbum! != 0{
            for _ in 0..<(PlayerViewController.newIndexOfTrackInAlbum!) {
                skipNext()
                print("In the check")
                }
        }
    }
    
    func updateCurrentAlbumAndTrack(){
        //wenn ein Song aus einem Album ausgewählt wurde
        if (PlayerViewController.currentTrack != nil){
            print("Current track is not nil")
            trackIdentifier = PlayerViewController.currentTrack!.uri
            AppDelegate.sharedInstance.currentTrack = PlayerViewController.currentTrack
            AppDelegate.sharedInstance.currentAlbum = PlayerViewController.audiobook
            AppDelegate.sharedInstance.timeElapsed = PlayerViewController.timeElapsed
            AppDelegate.sharedInstance.albumIndentifier = PlayerViewController.albumIdentifier
            
           
        } else { //wenn der Mini Player gedrückt wurde
            PlayerViewController.currentTrack = AppDelegate.sharedInstance.currentTrack
            PlayerViewController.audiobook = AppDelegate.sharedInstance.currentAlbum
            PlayerViewController.timeElapsed = AppDelegate.sharedInstance.timeElapsed
            PlayerViewController.albumIdentifier = AppDelegate.sharedInstance.albumIndentifier
        }
    }
    
    func activatePlayAndSliderTimer(){
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayButton), userInfo: nil, repeats: true)
        sliderTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
    }
    
    func updateInterface(){
        let url = PlayerViewController.audiobook?.image
        let data = try? Data(contentsOf: url!)
        coverImage.image = UIImage(data: data!)
        authorLabel.text = PlayerViewController.audiobook?.author
        progressSlider.isContinuous = false
        
    }
    
    func updateTrackInfo(){
        guard let currentTrack = PlayerViewController.currentTrack else { return }
        titleLabel?.text = currentTrack.title
        duration_ms = Float(currentTrack.duration)
        durationInSeconds = duration_ms!/Float(1000)
        let artistNames = currentTrack.artists
        let joinedArtistNames = artistNames.joined(separator: ", ")
        descriptionLabel?.text = joinedArtistNames
    }
    
    

    @objc func updatePlayButton(){
        if (progressSlider.value > 0.99 || (Int(PlayerViewController.timeElapsed!) == Int(durationInSeconds!))) { //somewhat timeElapsed is behind by one or two seconds sometimes
            PlayerViewController.wasSelectedOrSkipped = false
//            songFinished = true
//            print("Song if finished: \(songFinished)")
//            playTimer.invalidate()
//            sliderTimer.invalidate()
//            pausePlayback()
//            updateQueue()
            //print("time elapsed: \(Int(PlayerViewController.timeElapsed!))")
            //print("Duration in seconds: \(Int(durationInSeconds!))")
        } else {
            playPauseButton?.setImage(UIImage(named:"round-pause-button-white")!, for: .normal)
            let remainingTimeInSeconds = durationInSeconds! - PlayerViewController.timeElapsed!
            timeRemainingLabel.text = "-\(getFormattedTime(timeInterval: Double(remainingTimeInSeconds)))"
            timeElapsedLabel.text = getFormattedTime(timeInterval: Double(PlayerViewController.timeElapsed!))
            //print("time elapsed: \(Int(PlayerViewController.timeElapsed!))")
        }
    }
    
    @objc func updateSlider() {
        PlayerViewController.timeElapsed! += 1
        AppDelegate.sharedInstance.timeElapsed! += 1
        progressSlider.value = Float(PlayerViewController.timeElapsed!) / Float(durationInSeconds!)
        //print("***\(progressSlider.value)")
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        //stop both timers if we go back to the list of songs
        //playTimer.invalidate()
        //sliderTimer.invalidate()
    }
    
    @IBAction func sliderDragged(_ sender: UISlider) {
        let newPosition = Int(progressSlider.value * duration_ms!)
        if songFinished {
            //playTrack()
            self.appRemote.playerAPI?.seek(toPosition: newPosition, callback: nil)
            self.songFinished = false
            if !playTimer.isValid && !sliderTimer.isValid {
                print("Song finished but slider dragged - turn timers back on.")
                playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updatePlayButton), userInfo: nil, repeats: true)
                sliderTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
            }
        } else {
            self.appRemote.playerAPI?.seek(toPosition: newPosition, callback: nil)
        }
        //update timeElapsed in song
        PlayerViewController.timeElapsed = progressSlider.value * Float(durationInSeconds!)
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
             isPlaying = true
             playPauseButton?.setImage(UIImage(named: "round-pause-button-white"), for: .normal)
             if !playTimer.isValid && !sliderTimer.isValid {
                print("Turn timers on after play button tapped.")
                playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayButton), userInfo: nil, repeats: true)
                sliderTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
            }
             
         } else {
             print("About to pause")
             pausePlayback()
             isPlaying = false
             playPauseButton?.setImage(UIImage(named: "play-button-round-white"), for: .normal)
             if playTimer.isValid && sliderTimer.isValid {
                print("Turn timers off after pause button tapped.")
                playTimer?.invalidate()
                sliderTimer?.invalidate()
            
         }
      }
    }
    
    //takes in seconds and formats the time to show the remaining minutes and seconds of a song
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
    
   
    private func startPlayback() {
        appRemote.playerAPI?.resume(defaultCallback)
         //appRemote.playerAPI?.play(trackIdentifier, callback: defaultCallback)
    }
    
    private func pausePlayback() {
        appRemote.playerAPI?.pause(defaultCallback)
    }
    
   
    
    /*private func playTrack() {
        appRemote.playerAPI?.play(trackIdentifier, callback: defaultCallback)
        print("Position vom Player im Play Track: \(PlayerViewController.myPlayerState!.playbackPosition)")
      
        print("That's the uri of the track currently played: \(trackIdentifier)")
        NotificationCenter.default.post(name: NSNotification.Name("trackChanged"), object: nil)
        //NotificationCenter.default.post(name: NSNotification.Name("colorTitle"), object: nil)
        //print("Neue Warteschlange: \(PlayerViewController.queue)")
        //Noti//ficationCenter.default.post(name: NSNotification.Name("playerStateChanged"), object: nil)
    }*/
    
    private func playTrackWithIdentifier(_ identifier: String) {
        if let result = appRemote.playerAPI?.play(identifier, callback: defaultCallback){
            if oldTrackIdentifier == nil || oldAudioBook != PlayerViewController.audiobook!.uri {
                let seconds = 0.1
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { //WHAT IF NETWORK TOO SLOW? TODO
                    self.checkNotFirstSongWasClicked()
                }
           
            }
         NotificationCenter.default.post(name: NSNotification.Name("trackChanged"), object: nil)
        }
        
    }
    
    func animateCover(){
        if isPlaying! {
            UIView.animate(withDuration: 0.3) {
                self.coverImage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: { //andere Schreibweise
                self.coverImage.transform = CGAffineTransform.identity
            })
        }
        isPlaying! = !isPlaying!
    }
    
    func adjustBackground(){
        view.layer.cornerRadius = 20.0
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
//       if #available(iOS 13.0, *) {
//            let statusBar = view.window?.windowScene?.statusBarManager
//        statusBar?.prefers
//
//        } else {
//            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
//            statusBar?.isHidden = true
//        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //statusBar?.isHidden = false
    }
    
    
    @IBAction func didPressSkipForward15Button(_ sender: UIButton) {
        PlayerViewController.timeElapsed! += 15
        progressSlider.value = Float(PlayerViewController.timeElapsed!) / Float(durationInSeconds!)
        let remainingTimeInSeconds = durationInSeconds! - PlayerViewController.timeElapsed!
        timeRemainingLabel.text = "-\(getFormattedTime(timeInterval: Double(remainingTimeInSeconds)))"
        timeElapsedLabel.text = getFormattedTime(timeInterval: Double(PlayerViewController.timeElapsed!))
        self.appRemote.playerAPI?.seek(toPosition: Int(progressSlider.value * duration_ms!), callback: { (result, error) in
            guard error == nil else {
                print(error)
                return
            }
        })
    }
    
    @IBAction func didPressSkipBackward15Button(_ sender: UIButton) {
        if ((PlayerViewController.timeElapsed! - 15) > 0) {
            PlayerViewController.timeElapsed! -= 15
            progressSlider.value = Float(PlayerViewController.timeElapsed!) / Float(durationInSeconds!)
            let remainingTimeInSeconds = durationInSeconds! - PlayerViewController.timeElapsed!
            timeRemainingLabel.text = "-\(getFormattedTime(timeInterval: Double(remainingTimeInSeconds)))"
            timeElapsedLabel.text = getFormattedTime(timeInterval: Double(PlayerViewController.timeElapsed!))
            self.appRemote.playerAPI?.seek(toPosition: Int(progressSlider.value * duration_ms!), callback: { (result, error) in
                guard error == nil else {
                    print(error)
                    return
                }
            })
        }
        
    }
    
    @IBAction func didPressPreviousButton(_ sender: AnyObject) {
        skipPrevious()
        configurePreviousSong()
        PlayerViewController.wasSelectedOrSkipped = true
    }
    
    @IBAction func didPressNextButton(_ sender: AnyObject) {
        skipNext()
        configureNextSong()
        PlayerViewController.wasSelectedOrSkipped = true
     
    }
    
    func configurePreviousSong(){
        if PlayerViewController.indexOfTrackInTracklist! - 1 >= 0 {
        PlayerViewController.currentTrack = PlayerViewController.helperTracklist![PlayerViewController.indexOfTrackInTracklist! - 1 ]
            AppDelegate.sharedInstance.currentTrack = PlayerViewController.currentTrack
            PlayerViewController.timeElapsed = 0
            AppDelegate.sharedInstance.timeElapsed = PlayerViewController.timeElapsed
            PlayerViewController.indexOfTrackInTracklist! -= 1
            progressSlider?.value = 0
            PlayerViewController.newIndexOfTrackInAlbum! -= 1
            PlayerViewController.oldIndexOfTrackInAlbum! -= 1
            NotificationCenter.default.post(name: NSNotification.Name("trackChanged"), object: nil)
        }
        DispatchQueue.main.async {
            self.updateTrackInfo()
        }
    }
    
    func configureNextSong(){
        print("Inside configureNextSong")
        if PlayerViewController.helperTracklist!.count > PlayerViewController.indexOfTrackInTracklist! + 1 {
        PlayerViewController.currentTrack = PlayerViewController.helperTracklist![PlayerViewController.indexOfTrackInTracklist! + 1]
            AppDelegate.sharedInstance.currentTrack = PlayerViewController.currentTrack
            PlayerViewController.timeElapsed = 0
            AppDelegate.sharedInstance.timeElapsed = PlayerViewController.timeElapsed
            PlayerViewController.indexOfTrackInTracklist! += 1
            PlayerViewController.newIndexOfTrackInAlbum! += 1
            PlayerViewController.oldIndexOfTrackInAlbum! += 1
            print("The new index is: \(PlayerViewController.newIndexOfTrackInAlbum!)")
            print("The old index is: \(PlayerViewController.oldIndexOfTrackInAlbum!)")
            progressSlider?.value = 0
            NotificationCenter.default.post(name: NSNotification.Name("trackChanged"), object: nil)
        }
        DispatchQueue.main.async {
            self.updateTrackInfo()
        }
    }
    
    private func skipPrevious() {
        appRemote.playerAPI?.skip(toPrevious: defaultCallback)
        
    }
    
    private func skipNext() {
        appRemote.playerAPI?.skip(toNext: defaultCallback)
    }
    
    
    private func enqueueTrack() {
         appRemote.playerAPI?.enqueueTrackUri(newIdentifier!, callback: defaultCallback)
        
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
        print("IndexOFTrackInTracklist: \(PlayerViewController.indexOfTrackInTracklist)")
       
        
        guard let helperTrackList = PlayerViewController.helperTracklist else { return }
       
        print(PlayerViewController.currentTrack!.title)
        print(playerState.track.name)
        
        if playerState.track.uri != PlayerViewController.currentTrack?.uri && PlayerViewController.currentTrack!.title != playerState.track.name && !PlayerViewController.wasSelectedOrSkipped { //TODO: wie unterscheiden, ob neuer Song geklickt oder automatisch geskipped
            print("Inside player state changed")
            var index = 0
            for track in helperTrackList {
                index += 1
                if track!.uri == playerState.track.uri {
                    print("Index: \(index)")
                    if index < PlayerViewController.indexOfTrackInTracklist! { //probably not gonna happen anyway
                        configurePreviousSong()
                    } else if index > PlayerViewController.indexOfTrackInTracklist! {
                        configureNextSong()
                    }
                    DispatchQueue.main.async {
                        self.updateTrackInfo()
                    }
                }
            }
        }
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
