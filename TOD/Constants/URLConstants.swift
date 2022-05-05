//
//  URLConstants.swift
//  TOD
//
//  Created by My Mac on 27/05/21.
//

import Foundation

struct URLConstants {
    
    static let V1 = "v1"
    static let TRADIES = "tradies"
    static let TRADIES_PROFILE = "tradies_profile"
    static let USERS = "users"
    static let DL = "DL"
    static let SERVICES_LIST = "services_list"
    static let TRADIES_SERVICES = "tradies_services"
    static let SERVICES = "services"
    static let FAQS = "faqs"
    static let ACTIVE_TRADIES = "active_tradies"
    static let AU = "au"
    static let QUERIES = "queries"
    static let JOBS = "job"
    static let TRADIES_TWILIO_CLIENT = "tradies_twilio_client"
    static let OPPORTUNITY = "opportunity"
    static let GET_TWILIO_ACCESS_TOKEN = "getTwilioAccessToken"
    
    static func getMakeCallURL(with AccountSID: String) -> String {
        return "https://api.twilio.com/2010-04-01/Accounts/\(AccountSID)/Calls.json"
    }
    
    static func getAudioURL() -> String {
        return "http://demo.twilio.com/docs/voice.xml"
    }
    
    static func getTwilioAccessTokenURL() -> String {
        return "https://wisteria-lyrebird-8898.twil.io/generate-twilio-access-token-v1"
    }
    
}
