//
//  QueriesParam.swift
//  TOD
//
//  Created by My Mac on 02/06/21.
//

import Foundation

struct QueriesParam {
    
    let message: String
    let subject: String
    let user_email: String
    let user_id: String
    let user_mobile: String
    let user_name: String
    
    init(message: String, subject: String, user_email: String, user_id: String, user_mobile: String, user_name: String) {
        self.message = message
        self.subject = subject
        self.user_email = user_email
        self.user_id = user_id
        self.user_mobile = user_mobile
        self.user_name = user_name
    }
    
}

extension QueriesParam: ModelToParameters {
    
    var dbParamRequest: [String : Any] {
        return [ApiParameterStatics.message: self.message,
                ApiParameterStatics.subject: self.subject,
                ApiParameterStatics.user_email: self.user_email,
                ApiParameterStatics.user_id: self.user_id,
                ApiParameterStatics.user_mobile: self.user_mobile,
                ApiParameterStatics.user_name: self.user_name]
    }
    
}
