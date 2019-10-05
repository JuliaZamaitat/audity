//
//  AudiobookDetailViewController.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 06.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

class AudiobookDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    typealias JSONStandard = [String : AnyObject]
    private var pageViewController: UIPageViewController!
    var audiobook: Audiobook!
    var previousOffset: CGFloat = 0
    var trackNames: [Track] = []
    var totalMinutes = 0
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var accessToken: String?
    @IBOutlet weak var containerView: UIView!
    
    var firstIntroViewController: DetailCoverViewController?
    var secondIntroViewController: DetailDescriptionViewController?

    lazy var viewControllers: [UIViewController] = {
        var viewControllers = [UIViewController]()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        firstIntroViewController = storyboard.instantiateViewController(withIdentifier: "cover") as? DetailCoverViewController
        secondIntroViewController = storyboard.instantiateViewController(withIdentifier: "description") as? DetailDescriptionViewController
        viewControllers.append(firstIntroViewController!)
        viewControllers.append(secondIntroViewController!)
        firstIntroViewController!.audiobook = audiobook
        secondIntroViewController!.audiobook = audiobook
        return viewControllers
    }()
    
    
    
    @IBOutlet weak var tableView: UITableView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustStyle()
        //self.view.bringSubviewToFront(containerView)
        //self.view.sendSubviewToBack(containerView)
        //tableView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        //self.tableView.contentInset = UIEdgeInsets(top: containerView.bounds.size.height+40, left: 0, bottom: 0, right: 0)
        
        //to inform about title color change
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name("trackChanged"), object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func getTracks(audiobook: Audiobook, offset: Int, trackNamesCompletionHandler: @escaping ([Track]?, Error?) -> Void) {
        accessToken = AppDelegate.sharedInstance.accessToken
        let baseURL = URL(string: "https://api.spotify.com/v1/albums/\(audiobook.id)/tracks")!
        let query: [String: String] = [
            "limit": "50",
            "offset": "\(offset)"
        ]
        
        let url = baseURL.withQueries(query)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    var readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! JSONStandard
                    if let items = readableJSON["items"] as? [JSONStandard] {
                        for i in 0..<items.count {
                            let item = items[i]
                            var artistsNames: [String] = []
                            if let artists = item["artists"] as? [JSONStandard]{
                                for a in 0..<artists.count{
                                    let artist = artists[a]
                                    let name = artist["name"] as! String
                                    artistsNames.append(name)
                                }
                            }
                            let chapterName = item["name"] as! String
                            //let id = item["id"] as! String
                            let uri = item["uri"] as! String
                            let duration = item["duration_ms"] as! Int
                            self.trackNames.append(Track.init(title: chapterName, artists: artistsNames, duration: duration, uri: uri))
                        }
                        trackNamesCompletionHandler(self.trackNames, nil)
                    }
                }
                catch {
                    print(error)
                    trackNamesCompletionHandler(nil, error)
                }
            }
        }
        task.resume()
    }


func asyncTracks(audiobook: Audiobook, offset: Int){
    self.getTracks(audiobook: audiobook,offset: offset, trackNamesCompletionHandler: { names, error in
        if let trackNames = names {
            if (trackNames.count < audiobook.totalTracks){
                self.asyncTracks(audiobook: audiobook, offset: offset + 50)
            }
             DispatchQueue.main.async {
                self.audiobook.trackList = self.trackNames
                self.tableView.reloadData()
                self.audiobook.getTotalDuration()
                self.firstIntroViewController?.audiobook?.duration = self.audiobook.duration
                self.secondIntroViewController?.audiobook?.duration = self.audiobook.duration
        }
        }
    })
}

    override func viewWillAppear(_ animated: Bool) {
        if trackNames.isEmpty {
            DispatchQueue.main.async {
                self.asyncTracks(audiobook: self.audiobook, offset: 0)
            }
        }
        tableView.reloadData()
    }
    
    private func adjustStyle() {
        //Sets up header
        title = ""
        //Sets up content view
        //tableView.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.SpotifyColor.Black
        view.backgroundColor = UIColor.SpotifyColor.Black
        tableView.separatorStyle = .none
        
        //Sets up tab bar
        tabBarController?.tabBar.barTintColor = UIColor.SpotifyColor.Black
        tabBarController?.tabBar.tintColor = .white
    }
    
    
    //MARK: - Swipe Indication
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = UIColor.SpotifyColor.Black
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        setupPageControl()
        return self.viewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UIPageViewController {
            pageViewController = vc
            pageViewController.dataSource = self
            pageViewController.delegate = self
            pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: true, completion: nil)
            
        }
      
        if let destinationVC = segue.destination as? PlayerViewController {
            if let cell = sender as? UITableViewCell,
                let indexPath = self.tableView.indexPath(for: cell){
                    PlayerViewController.audiobook = self.audiobook
                    PlayerViewController.currentTrack = self.audiobook.trackList[indexPath.row]
                    PlayerViewController.queue = []
                    for i in indexPath.row+1..<audiobook.trackList.count{
                        PlayerViewController.queue?.append(audiobook.trackList[i])
                        print("Added: \(audiobook.trackList[i])")
                    }
            }
        }
    }
    
    
    
    //MARK: - Table View
    
    @objc func reloadTable() {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audiobook.trackList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as? TrackTableViewCell else {
            return UITableViewCell()
        }
        cell.titelLabel.text = audiobook.trackList[indexPath.row].title
        let artistNames = audiobook.trackList[indexPath.row].artists
        let joinedArtistNames = artistNames.joined(separator: ", ")
        cell.descriptionLabel.text = joinedArtistNames
      
        
        //Make the title of the currently playing track green
        if(AppDelegate.sharedInstance.currentTrack != nil){
            if (trackNames[indexPath.row].title == AppDelegate.sharedInstance.currentTrack?.title) {
                 cell.titelLabel.textColor = UIColor.SpotifyColor.Green
            } else {
                  cell.titelLabel.textColor = .white
            }
    
        }
        cell.titelLabel.highlightedTextColor = UIColor.SpotifyColor.Green
        //cell.lengthLabel.text = audiobook.trackList[indexPath.row].length
        
        //To make titels of cells green but selection style same color as table view
        let customColorView = UIView()
        customColorView.backgroundColor = UIColor.SpotifyColor.Black
        cell.selectedBackgroundView = customColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
    }
    
   /* func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        if(offset > 300){
            self.containerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 0)
        }else{
            
            self.containerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 300 - offset)
            
        }
        
    }*/
    
}

// MARK: UIPageViewControllerDataSource
extension AudiobookDetailViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard viewControllers.count > previousIndex else {
            return nil
        }
        return viewControllers[previousIndex]
    }
    
   
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let viewControllersCount = viewControllers.count
        guard viewControllersCount != nextIndex else {
            return nil
        }
        guard viewControllersCount > nextIndex else {
            return nil
        }
        
        return viewControllers[nextIndex]
    }
}
    

// MARK: UIPageViewControllerDelegate
extension AudiobookDetailViewController: UIPageViewControllerDelegate {
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return viewControllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
