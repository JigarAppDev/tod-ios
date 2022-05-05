//
//  VerifyMobileNumberViewController.swift
//  TOD
//
//  Created by iMac on 22/05/21.
//

import UIKit
import Firebase
class VerifyMobileNumberViewController: UIViewController {
    //MARK:- IbOutlet
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var numbeCodeTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var generateOtpButton: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var lctImageViewtop: NSLayoutConstraint!
    @IBOutlet weak var lctImageViewHieght: NSLayoutConstraint!
    @IBOutlet weak var lctPhoneCodeTop: NSLayoutConstraint!
    @IBOutlet weak var lctGenrateButtonTop: NSLayoutConstraint!
    @IBOutlet weak var alretLabel: UILabel!
    @IBOutlet weak var numberAlertBUtton: UIButton!
    @IBOutlet weak var countryCodeAlertButton: UIButton!
    
    //MARK:- Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setUpUI() {
        setUpView()
        setUpButton()
        constraintSetUP()
        setUpLabel()
        setUpTextView()
    }
    private func constraintSetUP() {
        if UIDevice.IS_IPHONE_5 {
            self.lctImageViewtop.constant = 15
            self.lctImageViewHieght.constant =  180
            self.lctPhoneCodeTop.constant = 15
            self.lctGenrateButtonTop.constant = 15
        }
        
    }
    private func setUpButton() {
        self.generateOtpButton.backgroundColor = AppColor.APP_THEME_COLOR
        self.generateOtpButton.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
        self.numberAlertBUtton.isHidden = true
        self.countryCodeAlertButton.isHidden = true
    }
    
    private func setUpView() {
        self.navigationView.backgroundColor = AppColor.APP_THEME_COLOR
        TODDefaultsManager.shared.reOpenViewController = "VerifyMobileNumberViewController"
    }
    private func setUpLabel() {
        self.alretLabel.isHidden = true
    }
    private func setUpTextView() {
        self.mobileNumberTextField.delegate = self
        self.numbeCodeTextField.delegate = self
        self.numbeCodeTextField.addTarget(self, action: #selector(textFiledValuChange), for: .editingChanged)
        self.mobileNumberTextField.addTarget(self, action: #selector(mobileNumberEditing), for: .editingDidBegin)
    }
    private func setupValidation(code: String, phoneNumber: String) -> Bool {
         if code.count <= 1 {
            self.countryCodeAlertButton.isHidden = false
            return false
        }
        else if phoneNumber.isEmpty {
            self.numberAlertBUtton.isHidden = false
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PHONE_NUMBER_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        }         else {
            
            self.countryCodeAlertButton.isHidden = true
            self.numberAlertBUtton.isHidden = true
            return true
        }
    }
    //MARK:- Action
    @objc func textFiledValuChange() {
        if self.numbeCodeTextField.text?.count == 0 {
            self.numbeCodeTextField.text = "+"
            self.countryCodeAlertButton.isHidden = true
        }
    }
    @objc func mobileNumberEditing() {
        self.numberAlertBUtton.isHidden = true
    }
    
    // MARK: - API Call
    private func verifyPhoneNumber(phoneNumber: String) {
        //showLoader()
        
        self.generateOtpButton.isUserInteractionEnabled = false
        APIHandler.shared.verifyPhoneNumber(phoneNumber: phoneNumber) { [weak self] (verificationID, error) in
            guard let self = self else { return }
            //hideLoader()
            self.generateOtpButton.isUserInteractionEnabled = true
            if let verificationID = verificationID {
                TODDefaultsManager.shared.verificationID = verificationID
                let otpVc = VerifyPhoneNuumberOtpViewController.instantiate(fromAppStoryboard: .Verification)
                otpVc.strMobileNumber = phoneNumber.trimmingCharacters(in: .whitespaces)
                self.navigationController?.pushViewController(otpVc, animated: true)
            }
            else if error?._code == 17042 {
               hideLoader()
               DLog(error?.localizedDescription)
//               let nextVC = VerifyMobileNumberViewController.instantiate(fromAppStoryboard: .Verification)
//               self.navigationController?.pushViewController(nextVC, animated: true)
               Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.DIFFERENT_NUMBER_OR_CODE, withOkButtonTitle: StringConstants.OKAY)
           }
            else {
                
                switch error {
                case .some(let error as NSError) where error.code == AuthErrorCode.invalidPhoneNumber.rawValue:
                    print("wrong password")
                    self.alretLabel.isHidden = false
                case .some(let error):
                    print("Login error: \(error.localizedDescription)")
                case .none: break
                }
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
    @IBAction func generateOtpButtonAction(_ sender: Any) {
        
        guard let code = numbeCodeTextField.text else { return }
        guard let phoneNumber = mobileNumberTextField.text else { return }
        
        if self.setupValidation(code: code, phoneNumber: phoneNumber) {
            let numberMobile = "\(code)\(phoneNumber)"
            self.verifyPhoneNumber(phoneNumber: numberMobile)
        }
        
        
        /*let otpVc = VerifyPhoneNuumberOtpViewController.instantiate(fromAppStoryboard: .Verification)
         otpVc.strMobileNumber = "\(code)\(phoneNumber)"
         self.navigationController?.pushViewController(otpVc, animated: true)*/
    }
    
}



extension VerifyMobileNumberViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == mobileNumberTextField {
            self.numberAlertBUtton.isHidden = true
        }else {
            self.countryCodeAlertButton.isHidden = true
        }
        if textField == mobileNumberTextField || textField == numbeCodeTextField {
            animateViewMoving(up: true, moveValue: 100)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == mobileNumberTextField || textField == numbeCodeTextField   {
            animateViewMoving(up: false, moveValue: 100)
        }
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    } 
}
