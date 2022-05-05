//
//  UIViewController+Extension.swift
//  TOD
//
//  Created by My Mac on 21/05/21.
//

import Foundation
import UIKit

extension UIViewController {
    
    // Not using static as it wont be possible to override to provide custom storyboardID then
    class public var storyboardID: String {
        return "\(self)"
    }
    
    static public func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
    
    // MARK: - Methods
    func showTabBar() {
        let customTabBarController = self.tabBarController as? CustomTabbarViewController
        customTabBarController?.setTabBarHidden(tabBarHidden: false, vc: self)
    }
    
    func hideTabBar() {
        let customTabBarController = self.tabBarController as? CustomTabbarViewController
        customTabBarController?.setTabBarHidden(tabBarHidden: true, vc: self)
    }
    
    func goToHomePage(animated: Bool) {
        let customTabBarVc = CustomTabbarViewController()
        customTabBarVc.tabSelectedAtIndex(tabIndex: 0)
        customTabBarVc.selectedIndex = 0
        customTabBarVc.selectedTabIndex = 0
        if customTabBarVc.customTabBarView.btnTabs.count > 0 {
            customTabBarVc.customTabBarView.selectTabAt(index: 0)
        }
        navigationController?.pushViewController(customTabBarVc, animated: animated)
    }
    
    func goToSettingsPage(animated: Bool) {
        let customTabBarVc = CustomTabbarViewController()
        customTabBarVc.tabSelectedAtIndex(tabIndex: 4)
        customTabBarVc.selectedIndex = 4
        customTabBarVc.selectedTabIndex = 4
        if customTabBarVc.customTabBarView.btnTabs.count > 4 {
            customTabBarVc.customTabBarView.selectTabAt(index: 4)
        }
        navigationController?.pushViewController(customTabBarVc, animated: animated)
    }
    
    func presentAlert(title: String, andMessage message: String, withOkButtonTitle okButtonTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: okButtonTitle, style: .default) { action in
            print("YOU_HAVE_PRESSED_OK_BUTTON")
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func topMostUIController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
}


