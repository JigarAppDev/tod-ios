//
//  IncomingViewController+APIMethods.swift
//  TOD
//
//  Created by My Mac on 14/06/21.
//

import Foundation
import FirebaseFirestore

extension IncomingViewController {
    
    // MARK: - API Methods
    internal func getDocumentDataForRejectInviteCall(with job_completion_status: String, call_status: String) -> [String: Any] {
        
        let parameters: [String: Any] = [ApiParameterStatics.call_ended_time: Timestamp(date: Date()),
                                         ApiParameterStatics.call_status: call_status,
                                         ApiParameterStatics.job_completion_status: job_completion_status]
        
        return parameters
    }
    
    
    internal func getDocumentDataForAcceptCallButRejectedOffer(with job_completion_status: String, call_status: String) -> [String: Any] {
        let date = Timestamp(date: Date())
        let calledTradiesParam: [String: Any] = [ApiParameterStatics.call_finished: date,
                                                 ApiParameterStatics.job_acceptance_status: ApiParameterStatics.rejected,
                                                 ApiParameterStatics.job_acceptance_time: date,
                                                 ApiParameterStatics.tradie_email: TODDefaultsManager.shared.email,
                                                 ApiParameterStatics.tradie_name: TODDefaultsManager.shared.name,
                                                 ApiParameterStatics.tradie_phone_number: TODDefaultsManager.shared.mobileNumber]
        
        let called_tradies_dict: [String: Any] = [pushParamModel.twi_call_sid: calledTradiesParam]
        
        let parameters: [String: Any] = [ApiParameterStatics.call_ended_time: date,
                                         ApiParameterStatics.call_status: call_status,
                                         ApiParameterStatics.job_completion_status: job_completion_status,
                                         ApiParameterStatics.called_tradies: called_tradies_dict,
                                         ApiParameterStatics.job_scheduled_time: date]
        
        return parameters
    }
    
    
    internal func getDocumentDataForAcceptCallAndAcceptedOffer(with job_completion_status: String, call_status: String) -> [String: Any] {
        let date = Timestamp(date: Date())
        let calledTradiesParam: [String: Any] = [ApiParameterStatics.call_finished: date,
                                                 ApiParameterStatics.job_acceptance_status: ApiParameterStatics.accepted,
                                                 ApiParameterStatics.job_acceptance_time: date,
                                                 ApiParameterStatics.tradie_email: TODDefaultsManager.shared.email,
                                                 ApiParameterStatics.tradie_name: TODDefaultsManager.shared.name,
                                                 ApiParameterStatics.tradie_phone_number: TODDefaultsManager.shared.mobileNumber]
        
        let called_tradies_dict: [String: Any] = [pushParamModel.twi_call_sid: calledTradiesParam]
        
        let parameters: [String: Any] = [ApiParameterStatics.call_ended_time: date,
                                         ApiParameterStatics.call_status: call_status,
                                         ApiParameterStatics.job_completion_status: job_completion_status,
                                         ApiParameterStatics.called_tradies: called_tradies_dict,
                                         ApiParameterStatics.job_scheduled_time: date]
        
        return parameters
    }
    
    internal func getDocumentDataForAcceptCallAndScheduledOffer(with job_completion_status: String, call_status: String, scheduledDate: Date) -> [String: Any] {
        let date = Timestamp(date: Date())
        let scheduledDate = Timestamp(date: scheduledDate)
        let calledTradiesParam: [String: Any] = [ApiParameterStatics.call_finished: date,
                                                 ApiParameterStatics.job_acceptance_status: ApiParameterStatics.scheduled,
                                                 ApiParameterStatics.job_acceptance_time: date,
                                                 ApiParameterStatics.tradie_email: TODDefaultsManager.shared.email,
                                                 ApiParameterStatics.tradie_name: TODDefaultsManager.shared.name,
                                                 ApiParameterStatics.tradie_phone_number: TODDefaultsManager.shared.mobileNumber]
        
        let called_tradies_dict: [String: Any] = [pushParamModel.twi_call_sid: calledTradiesParam]
        
        let parameters: [String: Any] = [ApiParameterStatics.call_ended_time: date,
                                         ApiParameterStatics.call_status: call_status,
                                         ApiParameterStatics.job_completion_status: job_completion_status,
                                         ApiParameterStatics.called_tradies: called_tradies_dict,
                                         ApiParameterStatics.job_scheduled_time: scheduledDate]
        
        return parameters
    }
    
    // MARK: - API Call
    internal func updateOpportunity() {
        
        showLoader()
        
        var documentData: [String: Any] = [:]
        
        if job_completion_status == ApiParameterStatics.call_inprogress && call_status == ApiParameterStatics.no_answer {
            documentData = getDocumentDataForRejectInviteCall(with: job_completion_status, call_status: call_status)
        } else if job_completion_status == ApiParameterStatics.rejected && call_status == ApiParameterStatics.rejected {
            documentData = getDocumentDataForAcceptCallButRejectedOffer(with: job_completion_status, call_status: call_status)
        } else if job_completion_status == ApiParameterStatics.inprogress && call_status == ApiParameterStatics.accepted {
            documentData = getDocumentDataForAcceptCallAndAcceptedOffer(with: job_completion_status, call_status: call_status)
        } else if job_completion_status == ApiParameterStatics.scheduled && call_status == ApiParameterStatics.scheduled {
            documentData = getDocumentDataForAcceptCallAndScheduledOffer(with: job_completion_status, call_status: call_status, scheduledDate: selectedScheduledDate)
        }
        
        DLog(documentData)
        
        APIHandler.shared.updateOpportunity(for: pushParamModel.twi_params.opportunity_id, documentData: documentData) { [weak self] (error) in
            guard let self = self else { return }
            
            if let error = error {
                hideLoader()
                if error._code != 14 {
                    Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                }
                return
            } else {
                hideLoader()
                self.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    
    internal func updateJobAcceptanceStatus(completion: @escaping (Error?) -> Void) {
        showLoader()
        var parameters: [String: Any] = [:]
        
        if job_completion_status == ApiParameterStatics.rejected && call_status == ApiParameterStatics.rejected {
            parameters = [ApiParameterStatics.job_acceptance_status: ApiParameterStatics.rejected]
        } else if job_completion_status == ApiParameterStatics.inprogress && call_status == ApiParameterStatics.accepted {
            parameters = [ApiParameterStatics.job_acceptance_status: ApiParameterStatics.accepted]
        } else if job_completion_status == ApiParameterStatics.scheduled && call_status == ApiParameterStatics.scheduled {
            parameters = [ApiParameterStatics.job_acceptance_status: ApiParameterStatics.scheduled]
        }
        
        let called_tradies_dict: [String: Any] = [pushParamModel.twi_call_sid: parameters]
        let documentData: [String: Any] = [ApiParameterStatics.called_tradies: called_tradies_dict]
        APIHandler.shared.updateOpportunity(for: pushParamModel.twi_params.opportunity_id, documentData: documentData) { [weak self] (error) in
            guard let self = self else { return }
            DLog(documentData)
            completion(error)
            DLog(self)
        }
    }
    
}
