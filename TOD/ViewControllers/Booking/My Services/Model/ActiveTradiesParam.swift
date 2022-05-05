//
//  ActiveTradiesParam.swift
//  TOD
//
//  Created by My Mac on 01/06/21.
//

import Foundation
import FirebaseFirestore

struct ActiveTradiesParam {
    
    let available_pincodes: [Int]
    let last_location_maps: GeoPoint
    let last_location_updated_on: Timestamp
    let last_pincode: Int
    let last_status_updated: Timestamp
    let service_code: Int
    let service_option_code: Int
    let service_type: String
    let sp_id: String
    let status: Bool
    let twilio_client_id: String
    
    
    init(available_pincodes: [Int], last_location_maps: GeoPoint, last_location_updated_on: Timestamp, last_pincode: Int, last_status_updated: Timestamp, service_code: Int, service_option_code: Int, service_type: String, sp_id: String, status: Bool, twilio_client_id: String) {
        self.available_pincodes = available_pincodes
        self.last_location_maps = last_location_maps
        self.last_location_updated_on = last_location_updated_on
        self.last_pincode = last_pincode
        self.last_status_updated = last_status_updated
        self.service_code = service_code
        self.service_option_code = service_option_code
        self.service_type = service_type
        self.sp_id = sp_id
        self.status = status
        self.twilio_client_id = twilio_client_id
    }
    
    init(data: [String: Any]) {
        
        if let available_pincodes = data[ApiParameterStatics.available_pincodes] as? [Int], available_pincodes.count > 0 {
            self.available_pincodes = available_pincodes
        } else {
            self.available_pincodes = []
        }
        
        if let last_location_maps = data[ApiParameterStatics.last_location_maps] as? GeoPoint {
            self.last_location_maps = last_location_maps
        } else {
            self.last_location_maps = GeoPoint(latitude: 0.0, longitude: 0.0)
        }
        
        if let last_location_updated_on = data[ApiParameterStatics.last_location_updated_on] as? Timestamp {
            self.last_location_updated_on = last_location_updated_on
        } else {
            self.last_location_updated_on = Timestamp()
        }
        
        if let last_pincode = data[ApiParameterStatics.last_pincode] as? Int {
            self.last_pincode = last_pincode
        } else {
            self.last_pincode = 0
        }
        
        if let last_status_updated = data[ApiParameterStatics.last_status_updated] as? Timestamp {
            self.last_status_updated = last_status_updated
        } else {
            self.last_status_updated = Timestamp()
        }
        
        if let service_code = data[ApiParameterStatics.service_code] as? Int {
            self.service_code = service_code
        } else {
            self.service_code = 0
        }
        
        if let service_option_code = data[ApiParameterStatics.service_option_code] as? Int {
            self.service_option_code = service_option_code
        } else {
            self.service_option_code = 0
        }
        
        if let service_type = data[ApiParameterStatics.service_type] as? String, !service_type.isEmpty {
            self.service_type = service_type
        } else {
            self.service_type = ""
        }
        
        if let sp_id = data[ApiParameterStatics.sp_id] as? String, !sp_id.isEmpty {
            self.sp_id = sp_id
        } else {
            self.sp_id = ""
        }
        
        if let status = data[ApiParameterStatics.status] as? Bool, status {
            self.status = status
        } else {
            self.status = false
        }
        
        if let twilio_client_id = data[ApiParameterStatics.twilio_client_id] as? String, !twilio_client_id.isEmpty {
            self.twilio_client_id = twilio_client_id
        } else {
            self.twilio_client_id = ""
        }
        
    }
    
}


extension ActiveTradiesParam: ModelToParameters {
    
    var dbParamRequest: [String : Any] {
        return [/*ApiParameterStatics.available_pincodes: self.available_pincodes,*/
                ApiParameterStatics.last_location_maps: self.last_location_maps,
                ApiParameterStatics.last_location_updated_on: self.last_location_updated_on,
                ApiParameterStatics.last_pincode: self.last_pincode,
                ApiParameterStatics.last_status_updated: self.last_status_updated,
                ApiParameterStatics.service_code: self.service_code,
                ApiParameterStatics.service_option_code: self.service_option_code,
                ApiParameterStatics.service_type: self.service_type,
                ApiParameterStatics.sp_id: self.sp_id,
                ApiParameterStatics.status: self.status,
                ApiParameterStatics.twilio_client_id: self.twilio_client_id]
    }
    
}
