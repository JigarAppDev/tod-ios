//
//  LoginViewController.swift
//  TOD
//
//  Created by iMac on 21/05/21.
//

import UIKit
import PushKit
import CallKit
import TwilioVoice

class LoginViewController: UIViewController, UIGestureRecognizerDelegate,UINavigationControllerDelegate {
    
    //MARK:- IbOutlet
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var termsAndPrivacyButton: UIButton!
    @IBOutlet weak var registerHereButton: UIButton!
    @IBOutlet weak var emailAlretButton: UIButton!
    @IBOutlet weak var passwordAlretButton: UIButton!
    @IBOutlet weak var lctViewSignTop: NSLayoutConstraint!
    @IBOutlet weak var lctImgLogoTop: NSLayoutConstraint!
    @IBOutlet weak var lctTopSignInLabel: NSLayoutConstraint!
    @IBOutlet weak var passwordEyeButton: UIButton!
    //MARK:- Variable
    var iconClick = false
    private var userProfileData:TradiesProfileParam?
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        TODDefaultsManager.shared.isOnboardingScreenShown = true
        TODDefaultsManager.shared.reOpenViewController = "1234"
    }
    
    // MARK:- Function
    private func setUpUI() {
        setUpButton()
        setUTextFiledl()
        //setUpView()
        setUpConstraint()
    }
    
    private func setUpConstraint() {
        if UIDevice.IS_IPHONE_5 {
            lctTopSignInLabel.constant = 0.0
            lctImgLogoTop.constant = 0.0
            lctViewSignTop.constant = 0.0
        }
        else if UIDevice.IS_IPHONE_LESS_THAN_OR_EQUAL_6 {
            lctTopSignInLabel.constant = 30.0
            lctImgLogoTop.constant = 40.0
            lctViewSignTop.constant = 32.0
        }
        
        
    }
    private func setUpView() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func setUpButton() {
        self.signInButton.backgroundColor = AppColor.APP_THEME_COLOR
        self.forgotPasswordButton.setTitleColor(AppColor.APP_THEME_COLOR, for: UIControl.State.normal)
        self.termsAndPrivacyButton.setTitleColor(AppColor.APP_THEME_COLOR, for: UIControl.State.normal)
        self.registerHereButton.setTitleColor(AppColor.APP_THEME_COLOR, for: UIControl.State.normal)
        self.signInButton.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
        self.emailAlretButton.isHidden = true
        self.passwordAlretButton.isHidden = true
        self.passwordEyeButton.setBackgroundImage(UIImage(named: "invisible")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.passwordEyeButton.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
    private func setUTextFiledl(){
        self.emailTextField.cornerRadius = 12
        self.passwordTextField.cornerRadius = 12
        let atrribute = NSAttributedString(string: "· · · · · · ·", attributes:  [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: .bold) as Any])
        self.passwordTextField.addTarget(self, action: #selector(passwordValueChange), for: .editingChanged)
        self.passwordTextField.attributedPlaceholder = atrribute
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    private func setupValidation(email: String, password: String) -> Bool {
        if email.isEmpty && password.isEmpty {
            self.emailAlretButton.isHidden = false
            self.passwordAlretButton.isHidden = false
            self.passwordEyeButton.isHidden = true
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.EMAIL_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if email.isEmpty {
            self.emailAlretButton.isHidden = false
            self.passwordEyeButton.isHidden = true
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.EMAIL_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if password.isEmpty {
            self.emailAlretButton.isHidden = true
            self.passwordEyeButton.isHidden = true
            self.passwordAlretButton.isHidden = false
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PASSWORD_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else {
            
            self.emailAlretButton.isHidden = true
            self.passwordAlretButton.isHidden = true
            self.passwordEyeButton.isHidden = false
            return true
        }
    }
    
    // MARK: - APICall
    private func callSignInAPI(email: String, password: String) {
        
        showLoader()
        
        APIHandler.shared.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            hideLoader()
            TODDefaultsManager.shared.userID = authResult?.user.uid ?? ""
            TODDefaultsManager.shared.email = authResult?.user.email ?? ""
            TODDefaultsManager.shared.mobileNumber = authResult?.user.phoneNumber ?? ""
        
            let phoneNumber  = TODDefaultsManager.shared.mobileNumber
            if let authResult = authResult {
                DLog(authResult)
                DLog(self)
                if phoneNumber != "" {
                    self.getUserDetails(userId: authResult.user.uid)
                } else {
                    let nextVC = VerifyMobileNumberViewController.instantiate(fromAppStoryboard: .Verification)
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            } else {
                DLog(error?.localizedDescription)
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.USER_DOES_NOT_EXIST, withOkButtonTitle: StringConstants.OKAY)
                return
            }
        }
    }
    
    private func getUserDetails(userId:String) {
        showLoader()
        APIHandler.shared.getProfileData(userID: userId, completion: { [weak self] (response, error) in
            guard let self = self else { return }
            if let response = response {
                let model = TradiesProfileParam(dict: response)
                self.userProfileData = model
                TODDefaultsManager.shared.address = self.userProfileData?.buisness_name ?? ""
                TODDefaultsManager.shared.uploadPermit = self.userProfileData?.user_dl.url ?? ""
                let address = TODDefaultsManager.shared.address
                let uploadPermit = TODDefaultsManager.shared.uploadPermit
                if address  != "" {
                    if uploadPermit != "" {
                        TODDefaultsManager.shared.isUserLoggedIn = true
                        AppDelegate.shared.initializeTabBar()
                    } else{
                        let nextVC = UploadLicsnseViewController.instantiate(fromAppStoryboard: .Main)
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
                } else{
                    let addressVC = AddressPageViewController.instantiate(fromAppStoryboard: .Main)
                    self.navigationController?.pushViewController(addressVC, animated: true)
                }
                hideLoader()
            } else {
                hideLoader()
            }
        })
    }
    //MARK:- Action
    @objc func passwordValueChange() {
        if self.passwordTextField.text?.count ?? 0 > 0 {
            self.passwordAlretButton.isHidden = true
            self.passwordEyeButton.isHidden = false
        } else {
            self.passwordAlretButton.isHidden = false
            self.passwordEyeButton.isHidden = true
        }
    }
    
    // MARK:- IbButton Action
    @IBAction func forgotPasswordButtonAction(_ sender: Any) {
        let forgotVc = ResetPasswordViewController.instantiate(fromAppStoryboard: .Login)
        self.navigationController?.pushViewController(forgotVc, animated: true)
    }
    
    @IBAction func signInButtonAction(_ sender: Any) {
        if ReachabilityManager.shared.isNetworkReachable {
            guard let email = self.emailTextField.text else { return }
            guard let password = self.passwordTextField.text else { return }
            
            if self.setupValidation(email: email, password: password) {
                self.callSignInAPI(email: email, password: password)
            }
        } else {
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.NETWORK_NOT_AVAILABLE, withOkButtonTitle: StringConstants.OKAY)
        }
    }
    
    @IBAction func termsAndPrivacyButtonAction(_ sender: Any) {
        let termVc = TermsAndPrivacyViewController.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(termVc, animated: true)
    }
    
    @IBAction func registerHereButtonAction(_ sender: Any) {
        let registerVc = RegisterViewController.instantiate(fromAppStoryboard: .Register)
        self.navigationController?.pushViewController(registerVc, animated: true)
    }
    @IBAction func emailAlretButtonAction(_ sender: Any) {
    }
    
    @IBAction func passwordAlretButtonAction(_ sender: Any) {
    }
    @IBAction func passwordEyeButtonAction(_ sender: Any) {
        iconClick = !iconClick
        if iconClick {
            self.passwordTextField.isSecureTextEntry = false
            self.passwordEyeButton.setBackgroundImage(UIImage(named: "view")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            self.passwordTextField.isSecureTextEntry = true
            self.passwordEyeButton.setBackgroundImage(UIImage(named: "invisible")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        self.passwordEyeButton.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        
    }
}


extension LoginViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            self.emailAlretButton.isHidden = true
        }else {
            self.passwordAlretButton.isHidden = true
        }
        if textField == emailTextField || textField == passwordTextField {
            animateViewMoving(up: true, moveValue: 100)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField || textField == passwordTextField  {
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
