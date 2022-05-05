//
//  ServicesParam.swift
//  TOD
//
//  Created by My Mac on 28/05/21.
//

import Foundation

struct ServicesDict {
    
    let param: ServiceParam
 
    init(param: ServiceParam) {
        self.param = param
    }
    
}

extension ServicesDict: ModelToParameters {
    var dbParamRequest: [String : Any] {
        return [ApiParameterStatics.services: param.dbParamRequest]
    }

}

struct ServiceParam {
    
    let serviceName: String
    let type: ServiceType
    
    init(serviceName: String, type: ServiceType) {
        self.serviceName = serviceName
        self.type = type
    }
    
}

extension ServiceParam: ModelToParameters {
    var dbParamRequest: [String : Any] {
        return [serviceName: type.dbParamRequest]
    }
}


struct ServiceType {
    
    let permit_submitted: [PermitParam]
    let service_code: Int
    let service_name: String
    let service_option_code: Int
    let service_type: String
    let verified: Bool
    
    init(permit_submitted: [PermitParam], service_code: Int, service_name: String, service_option_code: Int, service_type: String, verified: Bool) {
        self.permit_submitted = permit_submitted
        self.service_code = service_code
        self.service_name = service_name
        self.service_option_code = service_option_code
        self.service_type = service_type
        self.verified = verified
    }
    
    func getPermitDict() -> [String: Any] {
        var permitDict: [String: Any] = [:]
        
        for (index, permit) in permit_submitted.enumerated() {
            permitDict.updateValue(permit.dbParamRequest, forKey: "\(index)")
        }
        
        return permitDict
    }
     
    
}

extension ServiceType: ModelToParameters {
    var dbParamRequest: [String : Any] {
        return [ApiParameterStatics.permit_submitted: getPermitDict(),
                ApiParameterStatics.service_code: service_code,
                ApiParameterStatics.service_name: service_name,
                ApiParameterStatics.service_option_code: service_option_code,
                ApiParameterStatics.service_type: service_type,
                ApiParameterStatics.verified: verified
        ]
    }
}


struct PermitParam {
    
    let permit_description: String
    let permit_example: String
    let permit_name: String
    let permit_file: String
    let permit_verified: String
    
    init(permit_description: String, permit_example: String, permit_name: String, permit_file: String, permit_verified: String) {
        self.permit_description = permit_description
        self.permit_example = permit_example
        self.permit_name = permit_name
        self.permit_file = permit_file
        self.permit_verified = permit_verified
    }
    
    
}

extension PermitParam: ModelToParameters {
    var dbParamRequest: [String : Any] {
        return [ApiParameterStatics.permit_description: permit_description,
                ApiParameterStatics.permit_example: permit_example,
                ApiParameterStatics.permit_name: permit_name,
                ApiParameterStatics.permit_file: permit_file,
                ApiParameterStatics.permit_verified: permit_verified]
    }
}
