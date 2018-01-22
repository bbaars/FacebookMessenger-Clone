//
//  CustomTabBarController.swift
//  Facebook-Messenger
//
//  Created by Brandon Baars on 1/21/18.
//  Copyright © 2018 Brandon Baars. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let friendsController = FriendsController(collectionViewLayout: UICollectionViewFlowLayout())
        let recentMessagesNavController = UINavigationController(rootViewController: friendsController)
        recentMessagesNavController.tabBarItem.title = "Recent"
        recentMessagesNavController.tabBarItem.image = UIImage(named: "recent")
        
        viewControllers = [recentMessagesNavController, createDummy(title: "Calls", imageName: "calls"), createDummy(title: "Groups", imageName: "groups"), createDummy(title: "People", imageName: "people"), createDummy(title: "Settings", imageName: "settings")]
    }

    private func createDummy(title: String, imageName: String)-> UINavigationController {
        
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.navigationItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        
        return navController
    }
}
