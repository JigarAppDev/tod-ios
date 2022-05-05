//
//  Utility.swift
//  TOD
//
//  Created by My Mac on 21/05/21.
//

import Foundation
import UIKit
import CoreLocation
import LocalAuthentication
import UserNotifications

class Utility {
    
    //MARK: - Variables
    static let shared = Utility()
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var loaderCount = 0
    
    
    var timeStampInterval: TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    var timeStampString: String {
        return "\(Date().timeIntervalSince1970)"
    }
    
    //MARK: - Functions
    
    class func appDelegate() -> AppDelegate {
        return self.shared.appDelegate
    }
    
    class func windowMain() -> UIWindow? {
        return self.appDelegate().window
    }
    
    class func rootViewControllerMain() -> UIViewController? {
        return self.windowMain()?.rootViewController
    }
    
    class func applicationMain() -> UIApplication {
        return UIApplication.shared
    }
    
    class func getMajorSystemVersion() -> Int {
        let systemVersionStr = UIDevice.current.systemVersion   //Returns 7.1.1
        let mainSystemVersion = Int((systemVersionStr.split(separator: "."))[0])
        
        return mainSystemVersion!
    }
    
    class func getAppUniqueId() -> String {
        let uniqueId: UUID = UIDevice.current.identifierForVendor! as UUID
        
        return uniqueId.uuidString
    }
    
    class func isLocationServiceEnable() -> Bool {
        var locationOn:Bool = false
        
        if(CLLocationManager.locationServicesEnabled()) {
            
            if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
                locationOn = true
            } else if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
                locationOn = true
            }
        } else {
            locationOn = false
        }
        
        return locationOn
    }
    
    class func showAlertForAppSettings(title: String, message: String, completion: @escaping (Bool) -> ()) {
        let alertWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        
        let alertController: UIAlertController = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { (action) -> Void in
            
            alertWindow.isHidden = true
            
            let settingURL = URL(string: UIApplication.openSettingsURLString)!
            
            UIApplication.shared.open(settingURL, options: [:], completionHandler: { (success) in
                DLog(success)
            })
            
            completion(true)
            
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: { (action) -> Void in
            
            alertWindow.isHidden = true
            completion(false)
            
        }))
        
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    class func askPermissionFormLocation() {
        let alertController = UIAlertController(title: "We Can't Get Your Location", message: "Turn on location services on your device.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel)
        { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Settings", style: .default)
        { (action) in
            if let url = URL(string:UIApplication.openSettingsURLString)
            {
                if #available(iOS 10.0, *) {
                    self.applicationMain().open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    self.applicationMain().openURL(url)
                }
            }
        }
        alertController.addAction(openAction)
        
        self.rootViewControllerMain()?.present(alertController, animated: true, completion: nil)
    }
    
    class func getJsonObject(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let error {
            DLog("Error!! = \(error)")
        }
        
        return nil
    }
    
    class func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
    
    class func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    class func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    class func stringFromTimeInterval(interval: TimeInterval) -> String {
        let time = Int(interval)
        
        let ms: Int = Int(fmod(interval, 1) * 1000)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }
    
    class func showMessageAlert(title: String, andMessage message: String, withOkButtonTitle okButtonTitle: String) {
        let alertWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okButtonTitle, style: .default, handler: { (action) -> Void in
            
            alertWindow.isHidden = true
            
        }))
        
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    
    class func formatNumberStringToShortForm(numberStr: String) -> String {
        var numberStr = numberStr
        numberStr = numberStr.replacingOccurrences(of: ",", with: "")
        
        
        if let numberDouble = Double(numberStr)// (numberStr as NSString).doubleValue
        {
            
            var shortNumber = numberDouble
            var suffixStr = ""
            
            if(numberDouble >= 1000000000.0)
            {
                suffixStr = "Arab"
                shortNumber = numberDouble / 1000000000.0
            }
            else if(numberDouble >= 10000000.0)
            {
                suffixStr = "Cr"
                shortNumber = numberDouble / 10000000.0
            }
            else if(numberDouble >= 100000.0)
            {
                suffixStr = "Lac"
                shortNumber = numberDouble / 100000.0
            }
            else if(numberDouble >= 1000.0)
            {
                suffixStr = "K"
                shortNumber = numberDouble / 1000.0
            }
            
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let numberAsString = numberFormatter.string(from: NSNumber(value: shortNumber as Double))
            let finalString = String(format: "%@ %@", numberAsString!, suffixStr)
            
            return finalString
        }
        
        return numberStr
    }
    
    func isPushNotificationPermissionAsked(completion: @escaping (Bool) -> Void) {
        let current = UNUserNotificationCenter.current()
        
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                // Notification permission has not been asked yet, go for it!
                completion(false)
            } else {
                // Notification permission was already granted
                completion(true)
            }
        })
    }
    
    func isPushNotificationEnabled(completion: @escaping (Bool) -> Void) {
        let current = UNUserNotificationCenter.current()
        
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                // Notification permission has not been asked yet, go for it!
                completion(false)
            } else if settings.authorizationStatus == .denied {
                // Notification permission was previously denied, go to settings & privacy to re-enable
                completion(false)
            } else if settings.authorizationStatus == .authorized {
                // Notification permission was already granted
                completion(true)
            }
        })
    }
    
    var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}

//MARK: - Structs
struct IOS_VERSION {
    static var IS_IOS7 = Utility.getMajorSystemVersion() >= 7 && Utility.getMajorSystemVersion() < 8
    static var IS_IOS8 = Utility.getMajorSystemVersion() >= 8 && Utility.getMajorSystemVersion() < 9
    static var IS_IOS9 = Utility.getMajorSystemVersion() >= 9
}

struct ScreenSize {
    static let SCREEN_BOUNDS = UIScreen.main.bounds
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    
    static let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    //static let IS_TV = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.TV
    
    static let IS_IPHONE_4_OR_LESS =  IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 1125.0
    static let IS_IPHONE_LESS_THAN_6 =  IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH < 667.0
    static let IS_IPHONE_LESS_THAN_OR_EQUAL_6 =  IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH <= 667.0
}

