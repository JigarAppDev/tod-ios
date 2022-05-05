//
//  CustomTabbarViewController.swift
//  TOD
//
//  Created by My Mac on 21/05/21.
//

import Foundation
import UIKit

class CustomTabbarViewController: UITabBarController,CustomTabBarViewDelegate {
    
    // MARK: - Variables
    var customTabBar = CustomTabBar()
    var customTabBarView: CustomTabBar!
    var forceHideTabBar = false
    let kBarHeight: CGFloat = 60
    var selectedTabIndex: Int = 0
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbarView()
        setupViewControllers()
    }
    
    override func viewWillLayoutSubviews() {
        var tabFrame: CGRect = tabBar.frame
        tabFrame.size.height = kBarHeight
        tabFrame.origin.y = view.frame.size.height - kBarHeight
        tabBar.frame = tabFrame
    }
    
    // MARK: - Methods
    private func setupTabbarView() {
        customTabBarView = (Bundle.main.loadNibNamed("CustomTabBar", owner: nil, options: nil)!.first as! CustomTabBar)
        
        customTabBarView.delegate = self
        
        var tabBarHeight = self.tabBar.frame.size.height + 11.0
        
        if #available(iOS 11.0, *) {
            if ((UIApplication.shared.keyWindow?.safeAreaInsets.top)! > CGFloat(0.0)) {
                tabBarHeight = tabBarHeight + UIApplication.shared.keyWindow!.safeAreaInsets.bottom
            }
        }
        
        customTabBarView.frame = CGRect(x: 0.0, y: self.view.frame.size.height - tabBarHeight, width: self.view.frame.size.width, height: tabBarHeight)
        
        self.view.addSubview(customTabBarView)
        
        customTabBarView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = NSLayoutConstraint(item: customTabBarView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: tabBarHeight)
        customTabBarView.addConstraints([heightConstraint])
        
        self.view.addConstraint(NSLayoutConstraint(item: customTabBarView!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: customTabBarView!, attribute: .bottom, relatedBy: .equal, toItem:self.view, attribute: .bottom, multiplier: 1, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: customTabBarView!, attribute: .right, relatedBy: .equal, toItem: self.view , attribute: .right, multiplier: 1, constant:0))
        
        self.view.layoutIfNeeded()
        
        if forceHideTabBar {
            self.tabBar.isHidden = true
            self.customTabBarView.isHidden = true
        }
    }
    
    private func setupViewControllers() {
        
        var viewControllers = [AnyObject]()
        
        let BookingsStoryboard = UIStoryboard(name: "Bookings", bundle: nil)
        let navController1: UINavigationController = BookingsStoryboard.instantiateViewController(withIdentifier: "BookingsNavigationController") as! UINavigationController
        
        let HelpStoryboard = UIStoryboard(name: "Help", bundle: nil)
        let navController2: UINavigationController = HelpStoryboard.instantiateViewController(withIdentifier: "HelpNavigationController") as! UINavigationController
        
        let ProfileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let navController3: UINavigationController = ProfileStoryboard.instantiateViewController(withIdentifier: "ProfileNavigationViewController") as! UINavigationController
        
        viewControllers = [navController1, navController2, navController3]
        
        self.viewControllers = viewControllers as? [UIViewController]
        
        if let vcs = self.viewControllers, vcs.count > self.selectedTabIndex {
            tabSelectedAtIndex(tabIndex: self.selectedTabIndex)
            if customTabBarView.btnTabs.count > self.selectedTabIndex {
                customTabBarView.selectTabAt(index: self.selectedTabIndex)
            }
        }
        
        //tabSelectedAtIndex(tabIndex: 0)
    }
    
    func tabSelectedAtIndex(tabIndex: Int) {
        
        if let vcs = self.viewControllers, vcs.count > self.selectedTabIndex {
            let selectedVC =  vcs[tabIndex]
            selectedIndex = tabIndex
            if (self.selectedViewController == selectedVC) {
                let navVc = self.selectedViewController as! UINavigationController
                navVc.popToRootViewController(animated: false)
            }
        }
        
        super.selectedViewController = selectedViewController
    }
    
    func tabBarHidden() -> Bool {
        return customTabBarView.isHidden && self.tabBar.isHidden
    }
    
    /*
    func setBadge(arrayCount: Int, isHidden: Bool) {
        
        if isHidden {
            self.customTabBarView.viwBadge.isHidden = true
            self.customTabBarView.lblBadge.isHidden = true
        } else {
            self.customTabBarView.viwBadge.isHidden = false
            self.customTabBarView.lblBadge.isHidden = false
            self.customTabBarView.lblBadge.text = "\(arrayCount)"
        }
    }
    */
    
    func setTabBarHidden(tabBarHidden: Bool, vc: UIViewController?) {
        if(tabBarHidden) {
            self.tabBar.isHidden = true
            self.customTabBarView.isHidden = tabBarHidden
            vc?.edgesForExtendedLayout = UIRectEdge.bottom
        } else {
            if !forceHideTabBar {
                self.tabBar.isHidden = true
                self.customTabBarView.isHidden = tabBarHidden
                vc?.edgesForExtendedLayout = UIRectEdge.top
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


