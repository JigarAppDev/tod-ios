//
//  GenerateAccessTokenParam.swift
//  TOD
//
//  Created by My Mac on 24/06/21.
//

import Foundation

struct GenerateAccessTokenParam {
    
    let access_token: String
    let access_token_android: String
    let access_token_ios: String
    let expires_on: Int
    let twilio_client: String
    
    
    init(data: [String: Any]) {
        
        if let access_token = data[ApiParameterStatics.access_token] as? String, !access_token.isEmpty {
            self.access_token = access_token
        } else {
            self.access_token = ""
        }
        
        if let access_token_android = data[ApiParameterStatics.access_token_android] as? String, !access_token_android.isEmpty {
            self.access_token_android = access_token_android
        } else {
            self.access_token_android = ""
        }
        
        if let access_token_ios = data[ApiParameterStatics.access_token_ios] as? String, !access_token_ios.isEmpty {
            self.access_token_ios = access_token_ios
        } else {
            self.access_token_ios = ""
        }
        
        if let expires_on = data[ApiParameterStatics.expires_on] as? Int, expires_on != 0 {
            self.expires_on = expires_on
        } else {
            self.expires_on = 0
        }
        
        if let twilio_client = data[ApiParameterStatics.twilio_client] as? String, !twilio_client.isEmpty {
            self.twilio_client = twilio_client
        } else {
            self.twilio_client = ""
        }
       
    }
    
}
