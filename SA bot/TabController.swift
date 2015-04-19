//
//  TabController.swift
//  SA bot
//
//  Created by Kyle Bashour on 4/17/15.
//
//

import UIKit
import Parse

class TabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTabbar()
    }

    func setUpTabbar() {

        for tabItem in tabBar.items! as! [UITabBarItem] {

            tabItem.imageInsets = UIEdgeInsetsMake(4, 0, -4, 0)
            tabItem.title = nil
        }

        var tabItem: UITabBarItem!
        tabItem = tabBar.items![0] as! UITabBarItem
        tabItem.image = Assets.imageOfPrintertabgrey.imageWithRenderingMode(.AlwaysOriginal)
        tabItem.selectedImage = Assets.imageOfPrintertabselected.imageWithRenderingMode(.AlwaysOriginal)
        tabItem = tabBar.items![1] as! UITabBarItem
        tabItem.image = Assets.imageOfScheduletabgrey.imageWithRenderingMode(.AlwaysOriginal)
        tabItem.selectedImage = Assets.imageOfScheduletabselected.imageWithRenderingMode(.AlwaysOriginal)

    }
}
