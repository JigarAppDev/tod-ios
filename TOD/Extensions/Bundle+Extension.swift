//
//  Bundle+Extension.swift
//  TOD
//
//  Created by My Mac on 26/05/21.
//

import Foundation
import UIKit

extension Bundle {
    
    static func appName() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return ""
        }
        if let version : String = dictionary["CFBundleDisplayName"] as? String {
            return version
        } else {
            return ""
        }
    }
    
    static func appVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        } else {
            return ""
        }
    }
    
}
