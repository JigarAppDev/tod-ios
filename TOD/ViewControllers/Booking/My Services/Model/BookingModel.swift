//
//  BookingModel.swift
//  TOD
//
//  Created by iMac on 02/06/21.
//

import FirebaseFirestore
struct BookingModel {
    let available_tradies_twilio_client : [String]
    let called_tradies : [String:Any]
    let jobId: String
    let requested_service: String
    let job_scheduled_time: Date
    let job_completion_status: String
    let sp_id: String
    let callerNumber:String
    let clientId:String
    let completed :String
    let feedbackRating:String
    let jobLocationPincode :String
    let opportunityId :String
    let requestServiceCode:String
    let requestServiceOptionCode:String
    let calledAt:Date
    init(jobId: String, requested_service: String, job_scheduled_time: Date, job_completion_status: String, sp_id: String,calledAt:Date,callerNumber:String,clientId:String,completed :String,feedbackRating:String,jobLocationPincode :String,opportunityId :String,requestServiceCode:String,requestServiceOptionCode:String,available_tradies_twilio_client:[String],called_tradies : [String:Any]) {
        self.jobId = jobId
        self.requested_service = requested_service
        self.job_scheduled_time = job_scheduled_time
        self.job_completion_status = job_completion_status
        self.sp_id = sp_id
        self.calledAt = calledAt
        self.callerNumber = callerNumber
        self.clientId = clientId
        self.completed = completed
        self.feedbackRating = feedbackRating
        self.jobLocationPincode = jobLocationPincode
        self.opportunityId = opportunityId
        self.requestServiceCode = requestServiceCode
        self.requestServiceOptionCode = requestServiceOptionCode
        self.available_tradies_twilio_client = available_tradies_twilio_client
        self.called_tradies = called_tradies
    }
    
    init(dict: [String: Any]) {
        
        if let jobId = dict[ApiParameterStatics.job_id] as? String, !jobId.isEmpty {
            self.jobId = jobId
        } else {
            self.jobId = ""
        }
        
        if let requested_service = dict[ApiParameterStatics.requested_service] as? String, !requested_service.isEmpty {
            self.requested_service = requested_service
        } else {
            self.requested_service = ""
        }
        
        if let job_scheduled_time = dict[ApiParameterStatics.job_scheduled_time] as? Timestamp {
            self.job_scheduled_time = job_scheduled_time.dateValue()
            
        } else {
            self.job_scheduled_time = Date()
        }
        
        if let job_completion_status = dict[ApiParameterStatics.job_completion_status] as? String, !job_completion_status.isEmpty {
            self.job_completion_status = job_completion_status
        } else {
            self.job_completion_status = ""
        }
        
        if let sp_id = dict[ApiParameterStatics.sp_id] as? String, !sp_id.isEmpty {
            self.sp_id = sp_id
        } else {
            self.sp_id = ""
        }
        
        if let calledAt = dict[ApiParameterStatics.called_at] as? Timestamp  {
            self.calledAt = calledAt.dateValue()
        } else {
            self.calledAt = Date()
        }
        
        if let callerNumber = dict[ApiParameterStatics.caller_number] as? String, !callerNumber.isEmpty {
            self.callerNumber = callerNumber
        } else {
            self.callerNumber = ""
        }
        
        if let clientId = dict[ApiParameterStatics.client_id] as? String, !clientId.isEmpty {
            self.clientId = clientId
        } else {
            self.clientId = ""
        }
        
        if let completed = dict[ApiParameterStatics.completed] as? String, !completed.isEmpty {
            self.completed = completed
        } else {
            self.completed = ""
        }
        
        if let feedbackRating = dict[ApiParameterStatics.feedback_rating] as? String, !feedbackRating.isEmpty {
            self.feedbackRating = feedbackRating
        } else {
            self.feedbackRating = ""
        }
        
        if let jobLocationPincode = dict[ApiParameterStatics.job_location_pincode] as? String, !jobLocationPincode.isEmpty {
            self.jobLocationPincode = jobLocationPincode
        } else {
            self.jobLocationPincode = ""
        }
        
        if let opportunityId = dict[ApiParameterStatics.opportunity_id] as? String, !opportunityId.isEmpty {
            self.opportunityId = opportunityId
        } else {
            self.opportunityId = ""
        }
        
        if let requestServiceCode = dict[ApiParameterStatics.requested_service_code] as? String, !requestServiceCode.isEmpty {
            self.requestServiceCode = requestServiceCode
        } else {
            self.requestServiceCode = ""
        }
        
        if let requestServiceOptionCode = dict[ApiParameterStatics.requested_service_option_code] as? String, !requestServiceOptionCode.isEmpty {
            self.requestServiceOptionCode = requestServiceOptionCode
        } else {
            self.requestServiceOptionCode = ""
        }
        
        if let available_tradies_twilio_client = dict[ApiParameterStatics.available_tradies_twilio_client] as? [String] {
            self.available_tradies_twilio_client = available_tradies_twilio_client
        } else {
            self.available_tradies_twilio_client = []
        }
        
        if let called_tradies = dict[ApiParameterStatics.called_tradies] as? [String:Any] {
            self.called_tradies = called_tradies
        } else {
            self.called_tradies = [:]
        }
    }
    
}

//struct called_tradies {
//
//    let callSid:String
//    let call_finished:Date
//    let call_started:Date
//    let call_status:String
//    let job_acceptance_status:String
//    let sp_id:String
//    let tradie_email:String
//    let tradie_name:String
//    let tradie_twilio_client:String
//
//    init(callSid:String,call_finished:Date,call_started:Date,call_status:String,job_acceptance_status:String,sp_id:String,tradie_email:String,tradie_name:String,tradie_twilio_client:String) {
//        self.callSid = callSid
//        self.call_finished = call_finished
//        self.call_started = call_started
//        self.call_status = call_status
//        self.job_acceptance_status = job_acceptance_status
//        self.sp_id = sp_id
//        self.tradie_email = tradie_email
//        self.tradie_name = tradie_name
//        self.tradie_twilio_client = tradie_twilio_client
//    }
//}






extension BookingModel: ModelToParameters {
    var dbParamRequest: [String : Any] {
        return [ApiParameterStatics.job_id: jobId ,
                ApiParameterStatics.requested_service: requested_service,
                ApiParameterStatics.job_scheduled_time: job_scheduled_time,
                ApiParameterStatics.job_completion_status: job_completion_status,
                ApiParameterStatics.sp_id: sp_id,
                ApiParameterStatics.called_at:calledAt,
                ApiParameterStatics.caller_number:callerNumber,
                ApiParameterStatics.client_id:clientId,
                ApiParameterStatics.completed:completed,
                ApiParameterStatics.opportunity_id:opportunityId,
                ApiParameterStatics.requested_service:requestServiceCode,
                ApiParameterStatics.requested_service_option_code:requestServiceOptionCode,
                ApiParameterStatics.feedback_rating:feedbackRating,
                ApiParameterStatics.job_location_pincode:jobLocationPincode,
                ApiParameterStatics.available_tradies_twilio_client:available_tradies_twilio_client,
                ApiParameterStatics.called_tradies:called_tradies
                
               ]
    }
}
