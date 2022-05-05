//
//  TwilioClientParam.swift
//  TOD
//
//  Created by My Mac on 05/06/21.
//

import Foundation
import FirebaseFirestore

struct TwilioClientParam {
    
    let access_token: String
    let expires_on: Timestamp
    let sp_id: String
    let twilio_client: String
    
    init(access_token: String, expires_on: Timestamp, sp_id: String, twilio_client: String) {
        self.access_token = access_token
        self.expires_on = expires_on
        self.sp_id = sp_id
        self.twilio_client = twilio_client
    }
    
    init(data: [String: Any]) {
        if let access_token = data[ApiParameterStatics.access_token] as? String, !access_token.isEmpty {
            self.access_token = access_token
        } else {
            self.access_token = ""
        }
        
        if let expires_on = data[ApiParameterStatics.expires_on] as? Timestamp {
            self.expires_on = expires_on
        } else {
            self.expires_on = Timestamp()
        }
        
        if let sp_id = data[ApiParameterStatics.sp_id] as? String, !sp_id.isEmpty {
            self.sp_id = sp_id
        } else {
            self.sp_id = ""
        }
        
        if let twilio_client = data[ApiParameterStatics.twilio_client] as? String, !twilio_client.isEmpty {
            self.twilio_client = twilio_client
        } else {
            self.twilio_client = ""
        }
    }
    
}
