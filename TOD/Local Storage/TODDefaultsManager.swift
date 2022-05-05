//
//  TODDefaultsManager.swift
//  TOD
//
//  Created by My Mac on 21/05/21.
//

import Foundation

final class TODDefaultsManager: UserDefaults {
    
    private static let single: TODDefaultsManager = TODDefaultsManager()
    internal static var shared: TODDefaultsManager { return single }
    
    public struct TODSessionKeys {
        static let isUserLoggedIn: String = "isUserLoggedIn"
        static let userID: String = "userID"
        static let accessToken: String = "accessToken"
        static let isOnboardingScreenShown: String = "isOnboardingScreenShown"
        static let email: String = "email"
        static let name: String = "name"
        static let verificationID: String = "verificationID"
        static let mobileNumber: String = "mobileNumber"
        static let pinCode: String = "pinCode"
        static let latitude: String = "latitude"
        static let longitude: String = "longitude"
        static let cachedDeviceToken: String = "cachedDeviceToken"
        static let zipCode :String = "zipCode"
        static let activeTradies : String = "activeTradies"
        static let service_name:String = "servicename"
        static let checkSatus: String = "checkSatus"
        static let reOpenViewController:String = "reOpenViewController"
        static let address:String = "address"
        static let uploadPermit:String = "uploadPermit"
    }
    
    var isUserLoggedIn: Bool {
        get {
            guard let isUserLoggedInC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.isUserLoggedIn) as? Bool,isUserLoggedInC else { return false }
            return isUserLoggedInC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.isUserLoggedIn)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    var userID: String {
        get {
            guard let userIDC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.userID) as? String else { return " " }
            return userIDC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.userID)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    var accessToken: String {
        get {
            guard let accessTokenC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.accessToken) as? String else { return " " }
            return accessTokenC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.accessToken)
            TODDefaultsManager.shared.synchronize()
        }
    }

    var isOnboardingScreenShown: Bool {
        get {
            guard let isOnboardingScreenShownC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.isOnboardingScreenShown) as? Bool,isOnboardingScreenShownC else { return false }
            return isOnboardingScreenShownC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.isOnboardingScreenShown)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    var email: String {
        get {
            guard let emailC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.email) as? String else { return " " }
            return emailC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.email)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    var name: String {
        get {
            guard let nameC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.name) as? String else { return " " }
            return nameC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.name)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    var verificationID: String {
        get {
            guard let verificationIDC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.verificationID) as? String else { return " " }
            return verificationIDC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.verificationID)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    var mobileNumber: String {
        get {
            guard let mobileNumberC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.mobileNumber) as? String else { return " " }
            return mobileNumberC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.mobileNumber)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    var pinCode: String {
        get {
            guard let pinCodeC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.pinCode) as? String else { return " " }
            return pinCodeC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.pinCode)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    var latitude: String {
        get {
            guard let latitudeC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.latitude) as? String else { return " " }
            return latitudeC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.latitude)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    var voipCachedDeviceToken: Data {
        get {
            guard let cachedDeviceTokenC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.cachedDeviceToken) as? Data else { return Data() }
            return cachedDeviceTokenC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.cachedDeviceToken)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    var longitude: String {
        get {
            guard let longitudeC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.longitude) as? String else { return " " }
            return longitudeC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.longitude)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    func removeValue(for key: String) {
        TODDefaultsManager.shared.removeObject(forKey: key)
    }
    
    func setSwitchStatus(checkStatusButton: [String:Bool]) {
        TODDefaultsManager.shared.set(checkStatusButton, forKey: TODSessionKeys.checkSatus)
        TODDefaultsManager.shared.synchronize()
    }
    
    func getSwitchStatus() -> [String:Bool] {
        return TODDefaultsManager.shared.value(forKey: TODSessionKeys.checkSatus) as? [String:Bool] ?? [:]
    }
    
    
    var reOpenViewController: String {
        get {
            guard let reOpenViewControllerC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.reOpenViewController) as? String else { return " " }
            return reOpenViewControllerC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.reOpenViewController)
            TODDefaultsManager.shared.synchronize()
        }
    }
    var address: String {
        get {
            guard let addressC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.address) as? String else { return " " }
            return addressC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.address)
            TODDefaultsManager.shared.synchronize()
        }
    }
    
    var uploadPermit: String {
        get {
            guard let uploadPermitC = TODDefaultsManager.shared.object(forKey: TODSessionKeys.uploadPermit) as? String else { return " " }
            return uploadPermitC
        }
        set(newValue) {
            TODDefaultsManager.shared.set(newValue, forKey: TODSessionKeys.uploadPermit)
            TODDefaultsManager.shared.synchronize()
        }
    }

   
}

