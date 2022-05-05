//
//  Storyboard+Extension.swift
//  TOD
//
//  Created by My Mac on 21/05/21.
//

import Foundation
import UIKit

public enum AppStoryboard: String {
    
    case Main
    case Bookings
    case Help
    case Profile
    case Login
    case Register
    case Verification
    
    public var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    public func viewController<T: UIViewController>(viewControllerClass: T.Type, function: String = #function, line: Int = #line, file: String = #file) -> T {
        
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        return scene
    }
    
    public func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
    
}



