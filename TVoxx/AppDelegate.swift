//
//  AppDelegate.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 20/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        self.configureSearchTab()
        
        if let options = launchOptions, url = options[UIApplicationLaunchOptionsURLKey] as? NSURL, opt = options[UIApplicationLaunchOptionsURLKey] as? [String: AnyObject]{
            self.application(application, openURL: url, options: opt)
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if url.host == "talks" {
            if let components = url.pathComponents where components.count > 1 {
                let talkId = components[1]
                
                if let tabController = self.window?.rootViewController as? UITabBarController {
                    tabController.selectedIndex = 0
                    if let tracksController = tabController.childViewControllers[0] as? TracksViewController {
                        tracksController.openTalkWithTalkId(talkId, play: (components.count > 2 && components[2] == "play"))
                    }
                }
            }
        }
        return true
    }
    
    private func configureSearchTab() {
        let tabBarController = self.window?.rootViewController as! UITabBarController
        let resultsController = tabBarController.storyboard?.instantiateViewControllerWithIdentifier("SearchResultsViewController") as! SearchResultsViewController
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = resultsController
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.placeholder = NSLocalizedString("Search talks", comment: "")
        let grayColor = UIColor(red: 47.0/255.0, green: 47.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        searchController.searchBar.tintColor = grayColor
        searchController.searchBar.barTintColor = grayColor
        searchController.searchBar.searchBarStyle = .Minimal
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        /*searchController.searchBar.scopeButtonTitles = [
            NSLocalizedString("Talks", comment: ""),
            NSLocalizedString("Speakers", comment: "")
        ]
        searchController.searchBar.selectedScopeButtonIndex = 0
        searchController.searchBar.showsScopeBar = true*/
        
        let searchContainerViewController = UISearchContainerViewController(searchController: searchController)
        let navigationController = UINavigationController(rootViewController: searchContainerViewController)
        navigationController.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Search, tag: 0)
        if var viewControllers = tabBarController.viewControllers {
            viewControllers.append(navigationController)
            tabBarController.viewControllers = viewControllers
            self.window?.rootViewController = tabBarController
            self.window?.makeKeyAndVisible()
        }
    }
}

