//
//  AudiobookDetailViewController.swift
//  Audiobooks
//
//  Created by Julia Zamaitat on 06.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

class AudiobookDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var oldContentOffset = CGPoint(x: 0,y: 0)
    let topConstraintRange = (CGFloat(120)..<CGFloat(300))
    
    
    private var pageViewController: UIPageViewController!
    var audiobook: AudiobookTemporary!
    var previousOffset: CGFloat = 0
   
    @IBOutlet weak var containerView: UIView!
    
    lazy var viewControllers: [UIViewController] = {
        var viewControllers = [UIViewController]()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstIntroViewController = storyboard.instantiateViewController(withIdentifier: "cover") as! DetailCoverViewController
      
        let secondIntroViewController = storyboard.instantiateViewController(withIdentifier: "description") as! DetailDescriptionViewController
        viewControllers.append(firstIntroViewController)
        viewControllers.append(secondIntroViewController)
        firstIntroViewController.audiobook = audiobook
        secondIntroViewController.audiobook = audiobook
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
        tableView.delegate = self
        tableView.dataSource = self
        
        
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
    }
    
    
    //MARK: - Table View
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return audiobook.tracks.count
    return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*guard let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as? TrackTableViewCell else {
            return UITableViewCell()
        }
        cell.titelLabel.text = audiobook.tracks[indexPath.row].title
        cell.titelLabel.highlightedTextColor = UIColor.SpotifyColor.Green
        cell.lengthLabel.text = audiobook.tracks[indexPath.row].length
        
        //To make titels of cells green but selection style same color as table view
        let customColorView = UIView()
        customColorView.backgroundColor = UIColor.SpotifyColor.Black
        cell.selectedBackgroundView = customColorView
        return cell*/
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return 75
        return 75
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
