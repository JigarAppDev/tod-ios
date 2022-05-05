//
//  VoipPushParam.swift
//  TOD
//
//  Created by My Mac on 11/06/21.
//

import Foundation
import TwilioVoice

struct VoipPushParam {
    
    let twi_account_sid: String
    let twi_bridge_token: String
    let twi_from: String
    let twi_to: String
    let twi_message_id: String
    let twi_call_sid: String
    let aps: [String: Any]
    let twi_message_type: String
    let twi_params: TwiParams
    
    
    init(data: [AnyHashable: Any]) {
        
        if let twi_account_sid = data[ApiParameterStatics.twi_account_sid] as? String, !twi_account_sid.isEmpty {
            self.twi_account_sid = twi_account_sid
        } else {
            self.twi_account_sid = ""
        }
        
        if let twi_bridge_token = data[ApiParameterStatics.twi_bridge_token] as? String, !twi_bridge_token.isEmpty {
            self.twi_bridge_token = twi_bridge_token
        } else {
            self.twi_bridge_token = ""
        }
        
        if let twi_from = data[ApiParameterStatics.twi_from] as? String, !twi_from.isEmpty {
            self.twi_from = twi_from
        } else {
            self.twi_from = ""
        }
        
        if let twi_to = data[ApiParameterStatics.twi_to] as? String, !twi_to.isEmpty {
            self.twi_to = twi_to
        } else {
            self.twi_to = ""
        }
        
        if let twi_message_id = data[ApiParameterStatics.twi_message_id] as? String, !twi_message_id.isEmpty {
            self.twi_message_id = twi_message_id
        } else {
            self.twi_message_id = ""
        }
        
        if let aps = data[ApiParameterStatics.aps] as? [String: Any], !aps.isEmpty {
            self.aps = aps
        } else {
            self.aps = [:]
        }
        
        if let twi_message_type = data[ApiParameterStatics.twi_message_type] as? String, !twi_message_type.isEmpty {
            self.twi_message_type = twi_message_type
        } else {
            self.twi_message_type = ""
        }
        
        if let twi_call_sid = data[ApiParameterStatics.twi_call_sid] as? String, !twi_call_sid.isEmpty {
            self.twi_call_sid = twi_call_sid
        } else {
            self.twi_call_sid = ""
        }
        
        if let twi_params = data[ApiParameterStatics.twi_params] as? String, !twi_params.isEmpty {
            let arrOfStrings = twi_params.components(separatedBy: "&")
            if arrOfStrings.count > 0 {
                self.twi_params = TwiParams(data: arrOfStrings)
            } else {
                self.twi_params = TwiParams(data: [])
            }
        } else {
            self.twi_params = TwiParams(data: [])
        }
        
    }
    
}


struct TwiParams {
    
    var opportunity_id: String
    var service_type: String
    var pincode: Int
    var service_code: Int
    var service_option_code: Int
    
    init(data: [String]) {
        
        self.opportunity_id = ""
        self.service_type = ""
        self.pincode = 0
        self.service_code = 0
        self.service_option_code = 0
        
        for str in data {
            let arrOfSubStrings = str.components(separatedBy: "=")
            
            if arrOfSubStrings.count > 1 {
                
                if arrOfSubStrings[0] == ApiParameterStatics.opportunity_id {
                    let opportunity_id = arrOfSubStrings[1]
                    self.opportunity_id = opportunity_id
                } else if arrOfSubStrings[0] == ApiParameterStatics.service_type {
                    let service_type = arrOfSubStrings[1]
                    self.service_type = service_type
                } else if arrOfSubStrings[0] == ApiParameterStatics.pincode {
                    let pincode = arrOfSubStrings[1]
                    self.pincode = Int(pincode) ?? 0
                } else if arrOfSubStrings[0] == ApiParameterStatics.service_code {
                    let service_code = arrOfSubStrings[1]
                    self.service_code = Int(service_code) ?? 0
                } else if arrOfSubStrings[0] == ApiParameterStatics.service_option_code {
                    let service_option_code = arrOfSubStrings[1]
                    self.service_option_code = Int(service_option_code) ?? 0
                }
                
            }
        }
    }
    
}

