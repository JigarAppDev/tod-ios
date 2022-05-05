//
//  IncomingViewController.swift
//  TOD
//
//  Created by My Mac on 05/06/21.
//

import UIKit
import AVFoundation
import PushKit
import CallKit
import GoogleMaps
import Alamofire
import FirebaseFirestore
import TwilioVoice
import ESTimePicker

class IncomingViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet internal weak var btnBack: UIButton!
    @IBOutlet internal weak var lblTradiesOnDemand: UILabel!
    @IBOutlet internal weak var btnSmartPhone: UIButton!
    @IBOutlet internal weak var viwMain: UIView!
    @IBOutlet internal weak var viwLocation: GMSMapView!
    @IBOutlet internal weak var viwLocationDetails: UIView!
    @IBOutlet internal weak var viwCallDetails: UIView!
    @IBOutlet internal weak var viwCallDuration: UIView!
    @IBOutlet internal weak var lblCallDuration: UILabel!
    @IBOutlet internal weak var lblServiceName: UILabel!
    @IBOutlet internal weak var lblServicePincode: UILabel!
    @IBOutlet internal weak var lblOpportunityNumber: UILabel!
    @IBOutlet internal weak var lblPincodeNumber: UILabel!
    @IBOutlet internal weak var btnAccept: UIButton!
    @IBOutlet internal weak var btnScheduled: UIButton!
    @IBOutlet internal weak var btnReject: UIButton!
    @IBOutlet internal weak var viwTimePicker: UIView!
    @IBOutlet internal weak var viwSetTime: UIView!
    @IBOutlet internal weak var txtHour: UITextField!
    @IBOutlet internal weak var txtMinute: UITextField!
    @IBOutlet internal weak var btnClock: UIButton!
    @IBOutlet internal weak var btnTimeViewCancel: UIButton!
    @IBOutlet internal weak var btnTimeViewOk: UIButton!
    @IBOutlet internal weak var viwClock: UIView!
    @IBOutlet internal weak var timerView: ESTimePicker!
    @IBOutlet internal weak var btnHour: UIButton!
    @IBOutlet internal weak var btnMinute: UIButton!
    @IBOutlet internal weak var btnCancel: UIButton!
    @IBOutlet internal weak var btnOK: UIButton!
    @IBOutlet internal weak var btnKeyboard: UIButton!
    @IBOutlet internal weak var viwSetTimeLabel: UIView!
    @IBOutlet internal weak var viwTimeLabel: UIView!
    
    // MARK: - Variables
    internal var timer = Timer()
    internal var minutesCount = 00
    internal var secondsCount = 00
    internal let locationManager = CLLocationManager()
    internal var job_completion_status = ""
    internal var call_status = ""

    // MARK: - View Life Cycle
    deinit {
        // CallKit has an odd API contract where the developer must call invalidate or the CXProvider is leaked.
        if let provider = callKitProvider {
            provider.invalidate()
        }
        timer.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
        setupLabel()
        setupTimerView()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTimerView()
        setupClockView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // CallKit has an odd API contract where the developer must call invalidate or the CXProvider is leaked.
        if let provider = callKitProvider {
            provider.invalidate()
        }
        timer.invalidate()
    }

    // MARK: - Methods
    private func setupUI() {
        setupView()
        setupButton()
        setupLabel()
        setupGoogleMapsView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.endActiveCallAction), name: UIApplication.willTerminateNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.endActiveCallAction), name: UIApplication.willResignActiveNotification, object: nil)
        //setupCallKitProvider()
    }
    
    private func setupButton() {
        self.btnReject.addCornerRadius(self.btnReject.frame.size.height / 2.0)
        self.btnAccept.addCornerRadius(self.btnAccept.frame.size.height / 2.0)
        self.btnScheduled.addCornerRadius(self.btnScheduled.frame.size.height / 2.0)
    }
    
    private func setupView() {
        viwLocation.addCornerRadius(16.0)
        viwLocation.clipsToBounds = true
        
        viwCallDetails.addCornerRadius(16.0)
        viwCallDetails.clipsToBounds = true
        
        viwLocationDetails.setGradientBackground(colorTop: UIColor.black.withAlphaComponent(0.2), colorBottom: UIColor.black)
    }
    
    private func setupGoogleMapsView() {
        let latitude: Double = Double(TODDefaultsManager.shared.latitude) ?? 0.0
        let longitude: Double = Double(TODDefaultsManager.shared.longitude) ?? 0.0
        let location = CLLocation(latitude: latitude, longitude: longitude)
        GoogleMapsHelper.didUpdateLocations([location], locationManager: self.locationManager, mapView: self.viwLocation)
    }
    
    private func setupTimerView() {
        timerView.delegate = self
        timerView.isNotation24Hours = true
        timerView.wheelColor = AppColor.PROFILE_BACKGROUND_COLOR
        timerView.textColor = .black
        timerView.selectColor = .white
        timerView.font = AppFont.ROBOTO_REGULAR_12
        timerView.highlightColor = AppColor.APP_THEME_COLOR
    }
    
    private func setupClockView() {
        self.viwSetTime.addCornerRadius(8.0)
        self.viwClock.addCornerRadius(8.0)
        self.viwSetTimeLabel.roundCorners([.topLeft, .topRight], radius: 8.0)
        self.viwTimeLabel.roundCorners([.topLeft, .topRight], radius: 8.0)
    }
    
    internal func setupTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.refreshTimerLabel), userInfo: nil, repeats: true)
    }
    
    private func setupLabel() {
        DLog(pushParamModel)
        self.secondsCount = 0
        self.minutesCount = 0
        self.lblCallDuration.text = "00:00"
        self.lblServiceName.text = pushParamModel.twi_params.service_type
        self.lblOpportunityNumber.text = pushParamModel.twi_params.opportunity_id
        self.lblServicePincode.text = String(pushParamModel.twi_params.pincode)
        self.lblPincodeNumber.text = String(pushParamModel.twi_params.pincode)
    }
    
    @objc private func refreshTimerLabel() {
        secondsCount = secondsCount + 1
        DispatchQueue.main.async {
            if self.secondsCount == 59 {
                self.minutesCount = self.minutesCount + 1
                self.secondsCount = 0
            }
            
            if self.minutesCount > 9 && self.secondsCount > 9 {
                self.lblCallDuration.text = "\(self.minutesCount):\(self.secondsCount)"
            } else if self.minutesCount > 9 && self.secondsCount < 9 {
                self.lblCallDuration.text = "\(self.minutesCount):0\(self.secondsCount)"
            } else if self.minutesCount < 9 && self.secondsCount > 9 {
                self.lblCallDuration.text = "0\(self.minutesCount):\(self.secondsCount)"
            } else if self.minutesCount < 9 && self.secondsCount < 9 {
                self.lblCallDuration.text = "0\(self.minutesCount):0\(self.secondsCount)"
            } else {
                self.lblCallDuration.text = "0\(self.minutesCount):0\(self.secondsCount)"
            }
        }
    }

    @objc private func endActiveCallAction() {
        NSLog("********************* End Active Call Action Called *********************")
        if isCallDidConnect {
            job_completion_status = ApiParameterStatics.rejected
            call_status = ApiParameterStatics.rejected
            if let activeCall = activeCall {
                NSLog("********************* End Active Call Action Called 2 *********************")

                if let uuid = activeCall.uuid {
                    NSLog("********************* End Active Call Action Called 3 *********************")

                    performEndCallAction(uuid: uuid)
                }
            }
        }
    }
    
    func setupCallKitProvider() {
        let configuration = CXProviderConfiguration(localizedName: "Voice Quickstart")
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        callKitProvider = CXProvider(configuration: configuration)
        if let provider = callKitProvider {
            provider.setDelegate(self, queue: nil)
        }
        TwilioVoiceSDK.audioDevice = audioDevice
    }
    
    private func setCurrentData() {
        let calendar = Calendar.current
        let currentTime = calendar.dateComponents([.hour,.minute,.second], from: Date())
        let currentHour = Int32(currentTime.hour ?? 0)
        let currentMinute = Int32(currentTime.minute ?? 0)
        let currentSecond = Int32(currentTime.second ?? 0)
        self.timerView.hours = currentHour
        self.timerView.minutes = currentMinute
        self.timerView.seconds = currentSecond
        self.timerView.type = .hours

        if currentHour > 9 {
            self.btnHour.setTitle("\(currentHour)", for: .normal)
            self.txtHour.text = "\(currentHour)"
        } else {
            self.btnHour.setTitle("0\(currentHour)", for: .normal)
            self.txtHour.text = "0\(currentHour)"
        }
    
        if currentMinute > 9 {
            self.btnMinute.setTitle("\(currentMinute)", for: .normal)
            self.txtMinute.text = "\(currentMinute)"
        } else {
            self.btnMinute.setTitle("0\(currentMinute)", for: .normal)
            self.txtMinute.text = "0\(currentMinute)"
        }
    }
    
    // MARK: - IBActions
    @IBAction func onBtnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnRejectAction(_ sender: UIButton) {
        if isCallDidConnect {
            job_completion_status = ApiParameterStatics.rejected
            call_status = ApiParameterStatics.rejected
            if let activeCall = activeCall {
                if let uuid = activeCall.uuid {
                    performEndCallAction(uuid: uuid)
                }
            }
        }
    }
    
    @IBAction func onBtnAcceptAction(_ sender: UIButton) {
        if isCallDidConnect {
            job_completion_status = ApiParameterStatics.inprogress
            call_status = ApiParameterStatics.accepted
            if let activeCall = activeCall {
                if let uuid = activeCall.uuid {
                    performEndCallAction(uuid: uuid)
                }
            }
        }
    }
    
    @IBAction func onBtnScheduledAction(_ sender: UIButton) {
        if isCallDidConnect {
            setCurrentData()
            self.viwTimePicker.isHidden = false
            self.viwClock.isHidden = false
            self.viwSetTime.isHidden = true
        }
    }
    
    @IBAction func onBtnBackToClockViewAction(_ sender: UIButton) {
        self.viwSetTime.isHidden = true
        self.viwClock.isHidden = false
    }
    
    @IBAction func onBtnTimeViewCancelAction(_ sender: UIButton) {
        self.viwTimePicker.isHidden = true
    }
    
    @IBAction func onBtnTimeViewOkAction(_ sender: UIButton) {
        job_completion_status = ApiParameterStatics.scheduled
        call_status = ApiParameterStatics.scheduled
        
        let calendar = Calendar.current
        let currentTime = calendar.dateComponents([.hour,.minute,.second], from: Date())
        let currentHour = currentTime.hour ?? 0
        let currentMinute = currentTime.minute ?? 0
        
        let hour = Int(self.txtHour.text ?? "") ?? currentHour
        let minute = Int(self.txtMinute.text ?? "") ?? currentMinute
        selectedScheduledDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
        
        DLog(selectedScheduledDate)
        
        self.viwTimePicker.isHidden = true
        
        if let activeCall = activeCall {
            if let uuid = activeCall.uuid {
                performEndCallAction(uuid: uuid)
            }
        }
        
    }
    
    @IBAction func onBtnHourAction(_ sender: UIButton) {
        timerView.setType(.hours, animated: true)
    }
    
    @IBAction func onBtnMinutesAction(_ sender: UIButton) {
        timerView.setType(.minutes, animated: true)
    }
    
    @IBAction func onBtnCancelAction(_ sender: UIButton) {
        self.viwTimePicker.isHidden = true
    }
    
    @IBAction func onBtnOKAction(_ sender: UIButton) {
        job_completion_status = ApiParameterStatics.scheduled
        call_status = ApiParameterStatics.scheduled
        
        let calendar = Calendar.current
        let currentTime = calendar.dateComponents([.hour,.minute,.second], from: Date())
        let currentHour = currentTime.hour ?? 0
        let currentMinute = currentTime.minute ?? 0
        
        let hour = Int(self.btnHour.currentTitle ?? "") ?? currentHour
        let minute = Int(self.btnMinute.currentTitle ?? "") ?? currentMinute
        selectedScheduledDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
        
        DLog(selectedScheduledDate)
        self.viwTimePicker.isHidden = true
        
        if let activeCall = activeCall {
            if let uuid = activeCall.uuid {
                performEndCallAction(uuid: uuid)
            }
        }
    }
    
    @IBAction func onBtnKeyboardAction(_ sender: UIButton) {
        self.viwSetTime.isHidden = false
        self.viwClock.isHidden = true
    }
    
    // MARK: AVAudioSession
    func toggleAudioRoute(toSpeaker: Bool) {
        audioDevice.block = {
            DefaultAudioDevice.DefaultAVAudioSessionConfigurationBlock()
            
            do {
                if toSpeaker {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                } else {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                }
            } catch {
                NSLog(error.localizedDescription)
            }
        }
        
        audioDevice.block()
    }
    
    func incomingPushHandled() {
        guard let completion = incomingPushCompletionCallback else { return }
        
        incomingPushCompletionCallback = nil
        completion()
    }
    
    // MARK: Call Kit Actions
    func performStartCallAction(uuid: UUID, handle: String) {
        guard let provider = callKitProvider else {
            NSLog("CallKit provider not available")
            return
        }
        
        let callHandle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: uuid, handle: callHandle)
        let transaction = CXTransaction(action: startCallAction)

        callKitCallController.request(transaction) { error in
            if let error = error {
                NSLog("StartCallAction transaction request failed: \(error.localizedDescription)")
                return
            }

            NSLog("StartCallAction transaction request successful")

            let callUpdate = CXCallUpdate()
            
            callUpdate.remoteHandle = callHandle
            callUpdate.supportsDTMF = true
            callUpdate.supportsHolding = true
            callUpdate.supportsGrouping = false
            callUpdate.supportsUngrouping = false
            callUpdate.hasVideo = false

            provider.reportCall(with: uuid, updated: callUpdate)
        }
    }

    func reportIncomingCall(from: String, uuid: UUID) {
        
        guard let provider = callKitProvider else {
            NSLog("CallKit provider not available")
            return
        }

        let callHandle = CXHandle(type: .generic, value: from)
        let callUpdate = CXCallUpdate()
        
        callUpdate.remoteHandle = callHandle
        callUpdate.supportsDTMF = true
        callUpdate.supportsHolding = true
        callUpdate.supportsGrouping = false
        callUpdate.supportsUngrouping = false
        callUpdate.hasVideo = false

        provider.reportNewIncomingCall(with: uuid, update: callUpdate) { error in
            if let error = error {
                NSLog("Failed to report incoming call successfully: \(error.localizedDescription).")
            } else {
                NSLog("Incoming call successfully reported.")
            }
        }
    }

    func performEndCallAction(uuid: UUID) {

        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)

        callKitCallController.request(transaction) { error in
            if let error = error {
                NSLog("EndCallAction transaction request failed: \(error.localizedDescription).")
            } else {
                NSLog("EndCallAction transaction request successful")
            }
        }
    }
    
    func performAnswerVoiceCall(uuid: UUID, completionHandler: @escaping (Bool) -> Void) {
        guard let callInvite = activeCallInvites[uuid.uuidString] else {
            NSLog("No CallInvite matches the UUID")
            return
        }
        
        let acceptOptions = AcceptOptions(callInvite: callInvite) { builder in
            builder.uuid = callInvite.uuid
        }
        
        let call = callInvite.accept(options: acceptOptions, delegate: self)
        activeCall = call
        activeCalls[call.uuid!.uuidString] = call
        callKitCompletionCallback = completionHandler
        
        activeCallInvites.removeValue(forKey: uuid.uuidString)
        
        guard #available(iOS 13, *) else {
            incomingPushHandled()
            return
        }
    }
    
    func qualityWarningsUpdatePopup(_ warnings: Set<NSNumber>, isCleared: Bool) {
        var popupMessage: String = "Warnings detected: "
        if isCleared {
            popupMessage = "Warnings cleared: "
        }
        
        let mappedWarnings: [String] = warnings.map { number in warningString(Call.QualityWarning(rawValue: number.uintValue)!)}
        popupMessage += mappedWarnings.joined(separator: ", ")
    }
    
    func warningString(_ warning: Call.QualityWarning) -> String {
        switch warning {
        case .highRtt: return "high-rtt"
        case .highJitter: return "high-jitter"
        case .highPacketsLostFraction: return "high-packets-lost-fraction"
        case .lowMos: return "low-mos"
        case .constantAudioInputLevel: return "constant-audio-input-level"
        default: return "Unknown warning"
        }
    }
    
    
    // MARK: Ringtone
    
    func playRingback() {
        let ringtonePath = URL(fileURLWithPath: Bundle.main.path(forResource: "ringtone", ofType: "wav")!)
        
        do {
            ringtonePlayer = try AVAudioPlayer(contentsOf: ringtonePath)
            ringtonePlayer?.delegate = self
            ringtonePlayer?.numberOfLoops = -1
            
            ringtonePlayer?.volume = 1.0
            ringtonePlayer?.play()
        } catch {
            NSLog("Failed to initialize audio player")
        }
    }
    
    func stopRingback() {
        guard let ringtonePlayer = ringtonePlayer, ringtonePlayer.isPlaying else { return }
        
        ringtonePlayer.stop()
    }
    
}

