//
//  IncomingViewController+DelegateMethods.swift
//  TOD
//
//  Created by My Mac on 14/06/21.
//

import Foundation
import CallKit
import AVKit
import PushKit
import TwilioVoice
import ESTimePicker

// MARK: - PushKitEventDelegate
extension IncomingViewController: PushKitEventDelegate {
    func credentialsUpdated(credentials: PKPushCredentials, token: String) {
        let cachedDeviceToken = credentials.token
        TwilioVoiceSDK.register(accessToken: token, deviceToken: cachedDeviceToken) { error in
            if let error = error {
                NSLog("An error occurred while registering: \(error.localizedDescription)")
                if error._code == 20104 {
                    print("TOKEN EXPIRED WITH ERROR: \(error.localizedDescription)")
                    self.generateNewToken(credentials: credentials)
                }
            } else {
                NSLog("Successfully registered for VoIP push notifications.")
                TODDefaultsManager.shared.voipCachedDeviceToken = cachedDeviceToken
                print(token)
                /*let expiredToken: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTSzIxMzZjMzc2ZjIxZDdlNTBmZTRiYzM2MWZjOTdmMWZmLTE2MjMzODU0MjAiLCJncmFudHMiOnsiaWRlbnRpdHkiOiIybXNSWklxY0VmVXE1bzFvNkVRYlJvSzB0bnQxMSIsInZvaWNlIjp7Im91dGdvaW5nIjp7ImFwcGxpY2F0aW9uX3NpZCI6IkFQMTNiNjE4N2FmYWI5YmRkYzNhOGE2YmMyODBiMjU1NGEifSwicHVzaF9jcmVkZW50aWFsX3NpZCI6IkNSNGQ4MzljZmU5ZGI4OGZlYWExYmJlMTI0ZjFjMDZmNjgifX0sImlhdCI6MTYyMzM4NTQyMCwiZXhwIjoxNjIzNDcxODIwLCJpc3MiOiJTSzIxMzZjMzc2ZjIxZDdlNTBmZTRiYzM2MWZjOTdmMWZmIiwic3ViIjoiQUM2MjlhNTYyZjc4NWZjMWRkNmIyNjY5NGJiZjRiMDNmOSJ9.HdfQol-q5JeQAKGE0JhtSRSfjWbYKNhoRsujM4hgxYE"
                TODDefaultsManager.shared.accessToken = expiredToken*/
                TODDefaultsManager.shared.accessToken = token
            }
        }
    }

    func credentialsInvalidated() {
        let deviceToken = TODDefaultsManager.shared.voipCachedDeviceToken
        let accessToken = TODDefaultsManager.shared.accessToken
        TwilioVoiceSDK.unregister(accessToken: accessToken, deviceToken: deviceToken) { error in
            if let error = error {
                NSLog("An error occurred while unregistering: \(error.localizedDescription)")
            } else {
                NSLog("Successfully unregistered from VoIP push notifications.")
            }
        }
        
        TODDefaultsManager.shared.removeValue(for: TODDefaultsManager.TODSessionKeys.cachedDeviceToken)
    }
    
    func incomingPushReceived(payload: PKPushPayload) {
        TwilioVoiceSDK.handleNotification(payload.dictionaryPayload, delegate: self, delegateQueue: nil)
    }
    
    func incomingPushReceived(payload: PKPushPayload, completion: @escaping () -> Void) {
        TwilioVoiceSDK.handleNotification(payload.dictionaryPayload, delegate: self, delegateQueue: nil)
        
        if let version = Float(UIDevice.current.systemVersion), version < 13.0 {
            incomingPushCompletionCallback = completion
        }
    }

    func generateNewToken(credentials: PKPushCredentials) {
        /*let userID: String = TODDefaultsManager.shared.userID
        fetchAccessToken(for: userID) { [weak self] (accessToken) in
            guard let self = self else { return }
            
            guard let accessToken = accessToken else { return }
            self.credentialsUpdated(credentials: credentials, token: accessToken)
        }*/
        fetchAccessTokenFromCloudFunction { [weak self] (httpScallableResult, error) in
            guard let self = self else { return }
            if let httpScallableResult = httpScallableResult {
                if let data = httpScallableResult.data as? [String: Any] {
                    let generateAccessTokenParam: GenerateAccessTokenParam = GenerateAccessTokenParam(data: data)
                    self.credentialsUpdated(credentials: credentials, token: generateAccessTokenParam.access_token_ios)
                }
            }
        }
        
    }
    
}


// MARK: - CXProviderDelegate
extension IncomingViewController: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        NSLog("providerDidReset:")
        audioDevice.isEnabled = false
    }

    func providerDidBegin(_ provider: CXProvider) {
        NSLog("providerDidBegin")
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        NSLog("provider:didActivateAudioSession:")
        audioDevice.isEnabled = true
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        NSLog("provider:didDeactivateAudioSession:")
        audioDevice.isEnabled = false
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        NSLog("provider:timedOutPerformingAction:")
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        NSLog("provider:performStartCallAction:")
        
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        NSLog("provider:performAnswerCallAction:")
        
        gotoIncomingCallScreen()
        
        performAnswerVoiceCall(uuid: action.callUUID) { success in
            if success {
                NSLog("performAnswerVoiceCall() successful")
            } else {
                NSLog("performAnswerVoiceCall() failed")
            }
        }
        
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        NSLog("provider:performEndCallAction:")
        
        if let invite = activeCallInvites[action.callUUID.uuidString] {
            invite.reject()
            activeCallInvites.removeValue(forKey: action.callUUID.uuidString)
            job_completion_status = ApiParameterStatics.call_inprogress
            call_status = ApiParameterStatics.no_answer
            self.updateOpportunity()
        } else if let call = activeCalls[action.callUUID.uuidString] {
            
            self.updateJobAcceptanceStatus { [weak self] (error) in
                guard let self = self else { return }
                if let error = error {
                    hideLoader()
                    if error._code != 14 {
                        Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                    }
                    return
                } else {
                    call.disconnect()
                    self.updateOpportunity()
                }
            }
            
        } else {
            NSLog("Unknown UUID to perform end-call action with")
        }

        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        NSLog("provider:performSetHeldAction:")
        
        if let call = activeCalls[action.callUUID.uuidString] {
            call.isOnHold = action.isOnHold
            action.fulfill()
        } else {
            action.fail()
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        NSLog("provider:performSetMutedAction:")

        if let call = activeCalls[action.callUUID.uuidString] {
            call.isMuted = action.isMuted
            action.fulfill()
        } else {
            action.fail()
        }
    }
    
}

// MARK: - TVOCallDelegate
extension IncomingViewController: CallDelegate {
    func callDidStartRinging(call: Call) {
        NSLog("callDidStartRinging:")
        
        if playCustomRingback {
            playRingback()
        }
    }
    
    func callDidConnect(call: Call) {
        NSLog("callDidConnect:")
        
        if playCustomRingback {
            stopRingback()
        }
        
        if let callKitCompletionCallback = callKitCompletionCallback {
            callKitCompletionCallback(true)
        }
        isCallDidConnect = true
        
        setupTimer()
        
        toggleAudioRoute(toSpeaker: true)
    }
    
    private func gotoIncomingCallScreen() {
        if let topVC = self.topMostUIController() as? UINavigationController {
            topVC.pushViewController(incomingVC, animated: true)
        }
    }
    
    func call(call: Call, isReconnectingWithError error: Error) {
        NSLog("call:isReconnectingWithError:")
    }
    
    func callDidReconnect(call: Call) {
        NSLog("callDidReconnect:")
    }
    
    func callDidFailToConnect(call: Call, error: Error) {
        NSLog("Call failed to connect: \(error.localizedDescription)")
        
        if let completion = callKitCompletionCallback {
            completion(false)
        }
        
        if let provider = callKitProvider {
            provider.reportCall(with: call.uuid!, endedAt: Date(), reason: CXCallEndedReason.failed)
        }

        callDisconnected(call: call)
    }
    
    func callDidDisconnect(call: Call, error: Error?) {
        if let error = error {
            NSLog("Call failed: \(error.localizedDescription)")
        } else {
            NSLog("Call disconnected")
            self.navigationController?.popViewController(animated: true)
        }
        
        if !userInitiatedDisconnect {
            var reason = CXCallEndedReason.remoteEnded
            
            if error != nil {
                reason = .failed
            }
            
            if let provider = callKitProvider {
                provider.reportCall(with: call.uuid!, endedAt: Date(), reason: reason)
            }
        }

        callDisconnected(call: call)
    }
    
    func callDisconnected(call: Call) {
        if call == activeCall {
            activeCall = nil
        }
        
        activeCalls.removeValue(forKey: call.uuid!.uuidString)
        
        userInitiatedDisconnect = false
        
        if playCustomRingback {
            stopRingback()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func call(call: Call, didReceiveQualityWarnings currentWarnings: Set<NSNumber>, previousWarnings: Set<NSNumber>) {
        var warningsIntersection: Set<NSNumber> = currentWarnings
        warningsIntersection = warningsIntersection.intersection(previousWarnings)
        
        var newWarnings: Set<NSNumber> = currentWarnings
        newWarnings.subtract(warningsIntersection)
        if newWarnings.count > 0 {
            qualityWarningsUpdatePopup(newWarnings, isCleared: false)
        }
        
        var clearedWarnings: Set<NSNumber> = previousWarnings
        clearedWarnings.subtract(warningsIntersection)
        if clearedWarnings.count > 0 {
            qualityWarningsUpdatePopup(clearedWarnings, isCleared: true)
        }
    }
    
}

// MARK: - AVAudioPlayerDelegate
extension IncomingViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            NSLog("Audio player finished playing successfully");
        } else {
            NSLog("Audio player finished playing with some error");
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            NSLog("Decode error occurred: \(error.localizedDescription)")
        }
    }
}


// MARK: - TVONotificaitonDelegate
extension IncomingViewController: NotificationDelegate {
    func callInviteReceived(callInvite: CallInvite) {
        NSLog("callInviteReceived:")

        let callerInfo: TVOCallerInfo = callInvite.callerInfo
        if let verified: NSNumber = callerInfo.verified {
            if verified.boolValue {
                NSLog("Call invite received from verified caller number!")
            }
        }

        let from = (callInvite.from ?? "Voice Bot").replacingOccurrences(of: "client:", with: "")

        // Always report to CallKit
        reportIncomingCall(from: from, uuid: callInvite.uuid)
        activeCallInvites[callInvite.uuid.uuidString] = callInvite
        
    }

    func cancelledCallInviteReceived(cancelledCallInvite: CancelledCallInvite, error: Error) {
        NSLog("cancelledCallInviteCanceled:error:, error: \(error.localizedDescription)")

        guard let activeCallInvite = activeCallInvites, !activeCallInvites.isEmpty else {
            NSLog("No pending call invite")
            return
        }

        let callInvite = activeCallInvite.values.first { invite in invite.callSid == cancelledCallInvite.callSid }

        if let callInvite = callInvite {
            performEndCallAction(uuid: callInvite.uuid)
            activeCallInvites.removeValue(forKey: callInvite.uuid.uuidString)
        }
    }
    
}

// MARK: - ESTimePickerDelegate
extension IncomingViewController: ESTimePickerDelegate {
    
    func timePickerHoursChanged(_ timePicker: ESTimePicker!, toHours hours: Int32) {
        if hours > 9 {
            self.btnHour.setTitle("\(hours)", for: .normal)
        } else {
            self.btnHour.setTitle("0\(hours)", for: .normal)
        }
    }
    
    func timePickerMinutesChanged(_ timePicker: ESTimePicker!, toMinutes minutes: Int32) {
        if minutes > 9 {
            self.btnMinute.setTitle("\(minutes)", for: .normal)
        } else {
            self.btnMinute.setTitle("0\(minutes)", for: .normal)
        }
        
        
    }
    
    func timePickerChangedType(_ timePicker: ESTimePicker!, toView type: ESTimePickerType) {
        let color = UIColor.white
        if type == .hours {
            self.btnHour.setTitleColor(color, for: .normal)
            self.btnMinute.setTitleColor(color.withAlphaComponent(0.6), for: .normal)
        } else if type == .minutes {
            self.btnHour.setTitleColor(color.withAlphaComponent(0.6), for: .normal)
            self.btnMinute.setTitleColor(color, for: .normal)
        }
    }
    
    
    
}
