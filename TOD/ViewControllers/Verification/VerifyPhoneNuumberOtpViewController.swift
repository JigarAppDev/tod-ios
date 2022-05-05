//
//  VerifyPhoneNuumberOtpViewController.swift
//  TOD
//
//  Created by iMac on 24/05/21.
//

import UIKit
import Firebase

class VerifyPhoneNuumberOtpViewController: UIViewController,UITextFieldDelegate {
    //MARK:- IbOutlet
    
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var otpTextField5: UITextField!
    @IBOutlet weak var otpTextField6: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var linkPhoneNumberBUtton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var lctTxtFeildOtp1Width: NSLayoutConstraint!
    //MARK:- Variable Declaration
    var strMobileNumber = ""
    var count = 60
    var timer : Timer?
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    //MARK:- Function
    private func setUpUI() {
        setUpButton()
        setUpLabel()
        setUTextFiledl()
        setUpView()
        setupConstraint()
    }
    
    private func setUpView() {
        self.view.backgroundColor = AppColor.APP_THEME_COLOR
    }
    
    private func setUpButton() {
        self.linkPhoneNumberBUtton.backgroundColor = AppColor.APP_THEME_COLOR
        self.linkPhoneNumberBUtton.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
        
    }
    
    private func setUpLabel() {
        self.timeLabel.textColor = AppColor.APP_THEME_COLOR
        self.mobileNumberLabel.text = strMobileNumber
    }
    
    private func setupConstraint() {
        if UIDevice.IS_IPHONE_5 {
            self.lctTxtFeildOtp1Width.constant = 40.0
        }
    }
    
    private func setUTextFiledl() {
        otpTextField1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField5.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField6.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(otpTimer), userInfo: nil, repeats: true)
    }
    
    @objc func otpTimer() {
        if(count > 0) {
            count -= 1
            
            timeLabel.text = count <= 10 ?  "00:0\(count)" :  "00:\(count)"
            resendButton.isEnabled = false
            
           } else {
            timeLabel.textColor = .lightGray
            resendButton.setTitleColor(AppColor.APP_THEME_COLOR ,for: .normal)
            resendButton.isEnabled = true
        }
    }
   
    
    //MARK:- TextField Action
    @objc func textFieldDidChange(textField: UITextField){
        let text = textField.text
        if  text?.count == 1 {
            switch textField{
            case otpTextField1:
                otpTextField2.becomeFirstResponder()
            case otpTextField2:
                otpTextField3.becomeFirstResponder()
            case otpTextField3:
                otpTextField4.becomeFirstResponder()
            case otpTextField4:
                otpTextField5.becomeFirstResponder()
            case otpTextField5:
                otpTextField6.becomeFirstResponder()
            case otpTextField6:
                otpTextField6.resignFirstResponder()
            default:
                break
            }
        }
        if  text?.count == 0 {
            switch textField{
            case otpTextField1:
                otpTextField1.becomeFirstResponder()
            case otpTextField2:
                otpTextField1.becomeFirstResponder()
            case otpTextField3:
                otpTextField2.becomeFirstResponder()
            case otpTextField4:
                otpTextField3.becomeFirstResponder()
            case otpTextField5:
                otpTextField4.becomeFirstResponder()
            case otpTextField6:
                otpTextField5.becomeFirstResponder()
            default:
                break
            }
        }
        else{
            
        }
    }
    
    private func setupValidation(otp1: String, otp2: String, otp3: String, otp4: String, otp5: String, otp6: String) -> Bool {
        if otp1.isEmpty || otp2.isEmpty || otp3.isEmpty || otp4.isEmpty || otp5.isEmpty || otp6.isEmpty {
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.ENTER_CORRECT_OTP, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else {
            return true
        }
    }
    
    // MARK: - API Call
    private func verifyOTP(from otp: String) {
        
        let verificatinId = TODDefaultsManager.shared.verificationID
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificatinId, verificationCode: otp)
        showLoader()
        
        if ReachabilityManager.shared.isNetworkReachable {
            APIHandler.shared.verifyOtp(credential: credential){ [weak self] (authResult, error) in
                guard let self = self else { return }
                
                if error == nil {
                    hideLoader()
                    TODDefaultsManager.shared.mobileNumber = "\(self.mobileNumberLabel.text ?? "")"
                    let addressVC = AddressPageViewController.instantiate(fromAppStoryboard: .Main)
                    self.navigationController?.pushViewController(addressVC, animated: true)
                } else if error?._code == 17025 {
                    hideLoader()
                    DLog(error?.localizedDescription)
                    let nextVC = VerifyMobileNumberViewController.instantiate(fromAppStoryboard: .Verification)
                    self.navigationController?.pushViewController(nextVC, animated: true)
                    Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.THIS_NUMBER_ALREADY_USE, withOkButtonTitle: StringConstants.OKAY)
                }
                else if error?._code == 17044 {
                    hideLoader()
                    DLog(error?.localizedDescription)
                    Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.COULD_NOT_GENERATE_OTP, withOkButtonTitle: StringConstants.OKAY)
                }
                else {
                    hideLoader()
                    DLog(error?.localizedDescription)
                    Utility.showMessageAlert(title: Bundle.appName(), andMessage: error?.localizedDescription ?? "", withOkButtonTitle: StringConstants.OKAY)
                }
            }
        } else {
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.NETWORK_NOT_AVAILABLE, withOkButtonTitle: StringConstants.OKAY)
        }
        
        
    }
    
    private func resendOTP() {
        showLoader()

        APIHandler.shared.verifyPhoneNumber(phoneNumber:strMobileNumber) { [weak self] (verificationID, error) in
            
            guard let self = self else { return }
            
            if let verificationID = verificationID {
                hideLoader()
                TODDefaultsManager.shared.verificationID = verificationID
                self.resendButton.setTitleColor(.lightGray ,for: .normal)
                self.timeLabel.textColor = AppColor.APP_THEME_COLOR
                self.count = 60
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.otpTimer), userInfo: nil, repeats: true)
            }
            else {
                hideLoader()
                DLog(error?.localizedDescription)
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error?.localizedDescription ?? "", withOkButtonTitle: StringConstants.OKAY)
                return
            } 
            
        }
    }
    
    //MARK:- IbButton Action
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnTermsAndConditionsAction(_ sender: UIButton) {
        let nextVC = TermsAndPrivacyViewController.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func linkPhoneNumberButtonAction(_ sender: Any) {
        guard let otp1 = otpTextField1.text else { return }
        guard let otp2 = otpTextField2.text else { return }
        guard let otp3 = otpTextField3.text else { return }
        guard let otp4 = otpTextField4.text else { return }
        guard let otp5 = otpTextField5.text else { return }
        guard let otp6 = otpTextField6.text else { return }
    
        if self.setupValidation(otp1: otp1, otp2: otp2, otp3: otp3, otp4: otp4, otp5: otp5, otp6: otp6) {
            let otp = "\(otp1)\(otp2)\(otp3)\(otp4)\(otp5)\(otp6)"
            self.verifyOTP(from: otp)
        }
        
        /*let addressVC = AddressPageViewController.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(addressVC, animated: true)*/
        
    }
    
    @IBAction func resendButtonAction(_ sender: Any) {
        self.resendOTP()
    }
    
}
