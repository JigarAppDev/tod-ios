//
//  TradiesProfileParam.swift
//  TOD
//
//  Created by My Mac on 27/05/21.
//

import Foundation
import FirebaseFirestore

struct TradiesProfileParam {
    let abn_number: ABNNumber
    let user_dl: UserDL
    let address: Address
    let createdAt: Timestamp
    let displayName: String
    let email: String
    let verified: Bool
    let imageUrl:String
    let phoneNumber:String
    let buisness_name :String
    init(abn_number: ABNNumber, user_dl: UserDL, address: Address, createdAt: Timestamp, displayName: String, email: String, verified: Bool ,imageUrl:String , phoneNumber:String,buisness_name:String) {
        self.abn_number = abn_number
        self.user_dl = user_dl
        self.address = address
        self.createdAt = createdAt
        self.displayName = displayName
        self.email = email
        self.verified = verified
        self.imageUrl = imageUrl
        self.phoneNumber = phoneNumber
        self.buisness_name = buisness_name
    }
    
    init(dict: [String: Any]) {
        
        if let abn_number = dict[ApiParameterStatics.abn_number] as? [String: Any], !abn_number.isEmpty {
            let abn_numberC: ABNNumber = ABNNumber(dict: abn_number)
            self.abn_number = abn_numberC
        } else {
            self.abn_number = ABNNumber(dict: [:])
        }
        
        if let user_dl = dict[ApiParameterStatics.user_dl] as? [String: Any], !user_dl.isEmpty {
            let user_dlC: UserDL = UserDL(dict: user_dl)
            self.user_dl = user_dlC
        } else {
            self.user_dl = UserDL(dict: [:])
        }
        
        if let address = dict[ApiParameterStatics.address] as? [String: Any], !address.isEmpty {
            let addressC: Address = Address(dict: address)
            self.address = addressC
        } else {
            self.address = Address(dict: [:])
        }
        
        if let createdAt = dict[ApiParameterStatics.createdAt] as? Timestamp {
            self.createdAt = createdAt
        } else {
            self.createdAt = Timestamp()
        }
        
        if let displayName = dict[ApiParameterStatics.displayName] as? String, !displayName.isEmpty {
            self.displayName = displayName
        } else if let displayName = dict[ApiParameterStatics.display_name] as? String, !displayName.isEmpty {
            self.displayName = displayName
        } else {
            self.displayName = ""
        }
        
        if let email = dict[ApiParameterStatics.email] as? String, !email.isEmpty {
            self.email = email
        } else {
            self.email = ""
        }
        
        if let verified = dict[ApiParameterStatics.verified] as? Bool, verified {
            self.verified = verified
        } else {
            self.verified = false
        }
        
        if let imageUrl = dict[ApiParameterStatics.url] as? String, !imageUrl.isEmpty {
            self.imageUrl = imageUrl
        } else {
            self.imageUrl = ""
        }
        
        if let phoneNumber = dict[ApiParameterStatics.phoneNumber] as? String, !phoneNumber.isEmpty {
            self.phoneNumber = phoneNumber
        } else if let phoneNumber = dict[ApiParameterStatics.phone_number] as? String, !phoneNumber.isEmpty {
            self.phoneNumber = phoneNumber
        } else {
            self.phoneNumber = ""
        }
        
        if let buisness_name = dict[ApiParameterStatics.buisness_name] as? String, !buisness_name.isEmpty {
            self.buisness_name = buisness_name
        } else {
            self.buisness_name = ""
        }
    }
    
}

extension TradiesProfileParam: ModelToParameters {
    var dbParamRequest: [String : Any] {
        return [ApiParameterStatics.abn_number: abn_number.dbParamRequest,
                ApiParameterStatics.user_dl: user_dl.dbParamRequest,
                ApiParameterStatics.address: address.dbParamRequest,
                ApiParameterStatics.createdAt: createdAt,
                ApiParameterStatics.display_name: displayName,
                ApiParameterStatics.email: email,
                ApiParameterStatics.verified: verified,
                ApiParameterStatics.phone_number: phoneNumber,
                ApiParameterStatics.buisness_name: buisness_name,
            ]
    }
}

struct Address {
    let city: String
    let country: String
    let doorNumber: String
    let completeAddress: String
    let isUploaded: Bool
    let pincode: String
    let street: String
    let state:String
    
    init(city: String, country: String, doorNumber: String, completeAddress: String, isUploaded: Bool, pincode: String, street: String,state:String) {
        self.city = city
        self.country = country
        self.doorNumber = doorNumber
        self.completeAddress = completeAddress
        self.isUploaded = isUploaded
        self.pincode = pincode
        self.street = street
        self.state = state
    }
    
    init(dict: [String: Any]) {
        
        if let city = dict[ApiParameterStatics.city] as? String, !city.isEmpty {
            self.city = city
        } else {
            self.city = ""
        }
        
        if let country = dict[ApiParameterStatics.country] as? String, !country.isEmpty {
            self.country = country
        } else {
            self.country = ""
        }
        
        if let doorNumber = dict[ApiParameterStatics.doorNumber] as? String, !doorNumber.isEmpty {
            self.doorNumber = doorNumber
        } else if let doorNumber = dict[ApiParameterStatics.door_number] as? String, !doorNumber.isEmpty {
            self.doorNumber = doorNumber
        } else {
            self.doorNumber = ""
        }
        
        if let completeAddress = dict[ApiParameterStatics.complete_address] as? String, !doorNumber.isEmpty {
            self.completeAddress = completeAddress
        } else {
            self.completeAddress = ""
        }
        
        if let isUploaded = dict[ApiParameterStatics.isUploaded] as? Bool, isUploaded {
            self.isUploaded = isUploaded
        } else {
            self.isUploaded = false
        }
        
        if let pincode = dict[ApiParameterStatics.pincode] as? String, !pincode.isEmpty {
            self.pincode = pincode
        } else {
            self.pincode = ""
        }
        
        if let street = dict[ApiParameterStatics.street] as? String, !street.isEmpty {
            self.street = street
        } else {
            self.street = ""
        }
        if let state = dict[ApiParameterStatics.state] as? String, !state.isEmpty {
            self.state = state
        } else {
            self.state = ""
        }
        
    }
    
}

extension Address: ModelToParameters {
    var dbParamRequest: [String : Any] {
        return [ApiParameterStatics.city: city,
                ApiParameterStatics.country: country,
                ApiParameterStatics.door_number: doorNumber,
                ApiParameterStatics.complete_address: completeAddress,
                ApiParameterStatics.isUploaded: isUploaded,
                ApiParameterStatics.pincode: pincode,
                ApiParameterStatics.street: street,
                ApiParameterStatics.state:state]
    }
}

struct ABNNumber {
    let isUploaded: Bool
    let value: String
    
    init(isUploaded: Bool, value: String) {
        self.isUploaded = isUploaded
        self.value = value
    }
    
    init(dict: [String: Any]) {
        
        if let isUploaded = dict[ApiParameterStatics.isUploaded] as? Bool, isUploaded {
            self.isUploaded = isUploaded
        } else {
            self.isUploaded = false
        }
        
        if let value = dict[ApiParameterStatics.value] as? String, !value.isEmpty {
            self.value = value
        } else {
            self.value = ""
        }
        
    }
    
}

extension ABNNumber: ModelToParameters {
    var dbParamRequest: [String : Any] {
        return [ApiParameterStatics.isUploaded: isUploaded,
                ApiParameterStatics.value : value]
    }
}

struct UserDL {
    let isUploaded: Bool
    let value: String
    let url: String
    
    init(isUploaded: Bool, value: String = "", url: String = "") {
        self.isUploaded = isUploaded
        self.value = value
        self.url = url
    }
    
    init(dict: [String: Any]) {
        
        if let isUploaded = dict[ApiParameterStatics.isUploaded] as? Bool, isUploaded {
            self.isUploaded = isUploaded
        } else {
            self.isUploaded = false
        }
        
        if let value = dict[ApiParameterStatics.value] as? String, !value.isEmpty {
            self.value = value
        } else {
            self.value = ""
        }
        
        if let url = dict[ApiParameterStatics.url] as? String, !url.isEmpty {
            self.url = url
        } else {
            self.url = ""
        }
        
    }
    
}

extension UserDL: ModelToParameters {
    var dbParamRequest: [String : Any] {
        var parameters: [String : Any] = [ApiParameterStatics.isUploaded: isUploaded]
        
        if !self.url.isEmpty {
            parameters.updateValue(url, forKey: ApiParameterStatics.url)
        } else {
            parameters.updateValue(value, forKey: ApiParameterStatics.value)
        }
        
        return parameters
    }
}
