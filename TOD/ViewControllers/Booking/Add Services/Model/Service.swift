//
//  Service.swift
//  TOD
//
//  Created by My Mac on 28/05/21.
//

import Foundation

struct Service {
    
    let permitNeeded: [Permit]
    let service_code: Int
    let service_name: String
    let service_option_code: Int
    let service_type: String
    let status: Bool
    let available_pincodes: [Int]
    
    init(permitNeeded: [Permit], service_code: Int, service_name: String, service_option_code: Int, service_type: String, status: Bool = false, available_pincodes: [Int] = []) {
        self.permitNeeded = permitNeeded
        self.service_code = service_code
        self.service_name = service_name
        self.service_option_code = service_option_code
        self.service_type = service_type
        self.status = status
        self.available_pincodes = available_pincodes
    }
    
    init(dict: [String: Any]) {
         
        if let permitNeeded = dict[ApiParameterStatics.permit_needed] as? [String: Any], !permitNeeded.isEmpty {
            
            let arrOfKeys = permitNeeded.keys.sorted()
            var permitResponse: [Permit] = []
            
            if arrOfKeys.count > 0, !arrOfKeys.isEmpty {
                
                arrOfKeys.forEach({ (str) in
                    if let permit = permitNeeded["\(str)"] as? [String: Any], !permit.isEmpty {
                        permitResponse.append(Permit(dict: permit))
                    }
                })
                
            }
            self.permitNeeded = permitResponse
            
        } else {
            self.permitNeeded = []
        }
        
        if let service_code = dict[ApiParameterStatics.service_code] as? Int {
            self.service_code = service_code
        } else {
            self.service_code = 0
        }
        
        if let service_name = dict[ApiParameterStatics.service_name] as? String, !service_name.isEmpty {
            self.service_name = service_name
        } else {
            self.service_name = ""
        }
        
        if let service_option_code = dict[ApiParameterStatics.service_option_code] as? Int {
            self.service_option_code = service_option_code
        } else {
            self.service_option_code = 0
        }
        
        if let service_type = dict[ApiParameterStatics.service_type] as? String, !service_type.isEmpty {
            self.service_type = service_type
        } else {
            self.service_type = ""
        }
        
        if let status = dict[ApiParameterStatics.status] as? Bool, status {
            self.status = status
        } else {
            self.status = false
        }
        
        if let available_pincodes = dict[ApiParameterStatics.available_pincodes] as? [Int], available_pincodes.count > 0 {
            self.available_pincodes = available_pincodes
        } else {
            self.available_pincodes = []
        }
        
    }
    
    func with(activeStatus: Bool) -> Service {
        return Service(permitNeeded: permitNeeded, service_code: service_code, service_name: service_name, service_option_code: service_option_code, service_type: service_type, status: activeStatus, available_pincodes: available_pincodes)
    }
    
    func with(pincodes: [Int]) -> Service {
        return Service(permitNeeded: permitNeeded, service_code: service_code, service_name: service_name, service_option_code: service_option_code, service_type: service_type, status: status, available_pincodes: pincodes)
    }
    
}

struct Permit {
    
    let permit_description: String
    let permit_example: String
    let permit_name: String
    
    init(permit_description: String, permit_example: String, permit_name: String) {
        self.permit_description = permit_description
        self.permit_example = permit_example
        self.permit_name = permit_name
    }
    
    init(dict: [String: Any]) {
        
        if let permit_description = dict[ApiParameterStatics.permit_description] as? String, !permit_description.isEmpty {
            self.permit_description = permit_description
        } else {
            self.permit_description = ""
        }
        
        if let permit_example = dict[ApiParameterStatics.permit_example] as? String, !permit_example.isEmpty {
            self.permit_example = permit_example
        } else {
            self.permit_example = ""
        }
        
        if let permit_name = dict[ApiParameterStatics.permit_name] as? String, !permit_name.isEmpty {
            self.permit_name = permit_name
        } else {
            self.permit_name = ""
        }
        
    }
}
