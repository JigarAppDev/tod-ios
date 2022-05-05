//
//  RegisterViewController.swift
//  TOD
//
//  Created by iMac on 22/05/21.
//

import UIKit
import Firebase
class RegisterViewController: UIViewController {
    //MARK:- IbOutlet
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var termsAndPrivacyButton: UIButton!
    @IBOutlet weak var loginHereButton: UIButton!
    @IBOutlet weak var lctViewSignTop: NSLayoutConstraint!
    @IBOutlet weak var lctImgLogoTop: NSLayoutConstraint!
    @IBOutlet weak var lctTopSignInLabel: NSLayoutConstraint!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var passwordEyeButton: UIButton!
    @IBOutlet weak var emailAlretButton: UIButton!
    @IBOutlet weak var passwordAlretButton: UIButton!
    //MARK:- Variable
    var isCheckBox = false
    var iconClick = false
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Function
    private func setupUI () {
        constraintSetUP()
        setUpTextField()
        setUpBUtton()
    }
    private func constraintSetUP() {
        if UIDevice.IS_IPHONE_5 {
            lctTopSignInLabel.constant = 0.0
            lctImgLogoTop.constant = 0.0
            lctViewSignTop.constant = 0.0
        }
    }
    
    private func setUpBUtton() {
        self.signUpButton.backgroundColor = AppColor.APP_THEME_COLOR
        self.termsAndPrivacyButton.setTitleColor(AppColor.APP_THEME_COLOR, for: UIControl.State.normal)
        self.loginHereButton.setTitleColor(AppColor.APP_THEME_COLOR, for: UIControl.State.normal)
        self.signUpButton.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
        self.passwordEyeButton.setBackgroundImage(UIImage(named: "invisible")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.passwordEyeButton.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.checkBoxButton.tintColor = AppColor.APP_THEME_COLOR
        self.emailAlretButton.isHidden = true
        self.passwordAlretButton.isHidden = true
        
    }
    
    private func setUpTextField () {
        self.emailTextField.cornerRadius = 12
        self.passwordTextField.cornerRadius = 12
        let atrribute = NSAttributedString(string: "· · · · · · ·", attributes:  [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: .bold) as Any])
        self.passwordTextField.attributedPlaceholder = atrribute
        self.passwordTextField.addTarget(self, action: #selector(passwordValueChange), for: .editingChanged)
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
       
        NotificationCenter.default.addObserver(self,
                                                       selector: #selector(keyBordWillHide),
                                                       name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupValidation(email: String, password: String) -> Bool {
        if email.isEmpty && password.isEmpty {
            self.emailAlretButton.isHidden = false
            self.passwordAlretButton.isHidden = false
            self.passwordEyeButton.isHidden = true
            return false
        }
        if email.isEmpty {
            self.emailAlretButton.isHidden = false
            self.passwordEyeButton.isHidden = true
            // Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.EMAIL_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if password.isEmpty {
            self.passwordAlretButton.isHidden = false
            self.emailAlretButton.isHidden = true
            self.passwordEyeButton.isHidden = true
            //Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PASSWORD_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
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
            if let authResult = authResult {
                DLog(authResult)
                // User already exist
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.USER_ALREADY_EXIST, withOkButtonTitle: StringConstants.OKAY)
                return
            }
            if let error = error {
                DLog(error)
                // If user does not exist then create one
                self.callCreateUserAPI(email: email, password: password)
            }
        }
    }
    
    private func callCreateUserAPI(email: String, password: String) {
        APIHandler.shared.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let authResult = authResult {
                print(authResult)
                TODDefaultsManager.shared.email = email
                TODDefaultsManager.shared.userID = authResult.user.uid
                hideLoader()
                let nextVC = VerifyMobileNumberViewController.instantiate(fromAppStoryboard: .Verification)
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            
            if let error = error {
                hideLoader()
                DLog(error.localizedDescription)
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.COULD_NOT_CREATE_USER, withOkButtonTitle: StringConstants.OKAY)
            }
        }
    }
    
    func createUser() {
        Auth.auth().createUser(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { (result, error) in
            if error == nil {
                print("create User")
            }
            else {
                print("Unable to singh in ")
            }
        }
    }
    
    func  singUser(email:String,password:String)  {
        Auth.auth().signIn(withEmail: email, password: password) { (user, erroe) in
            if erroe == nil {
            } else if (erroe?._code == AuthErrorCode.userNotFound.rawValue){
            }
        }
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
    
    @objc func keyBordWillHide (notification : NSNotification) {
        DispatchQueue.main.async {
            self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
       
    }
    //MARK:- IbButton Action
    @IBAction func signUpButtonAction(_ sender: Any) {
        if ReachabilityManager.shared.isNetworkReachable {
            guard let email = self.emailTextField.text else { return }
            guard let password = self.passwordTextField.text else { return }
            if self.setupValidation(email: email, password: password) {
                if self.passwordTextField.text?.count ?? 0 < 7 {
                    Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PLEASE_ENTER_PASSWORD_MINIMUM, withOkButtonTitle: StringConstants.OKAY)
                    self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    self.passwordTextField.delegate = self
                    return
                }
                if isCheckBox == true {
                    self.callSignInAPI(email: email, password: password)
                }
                else {
                    Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PLEASE_AGREE_TO_OUR_TERMS_CONDITION, withOkButtonTitle: StringConstants.OKAY)
                }
            }
        } else {
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.NETWORK_NOT_AVAILABLE, withOkButtonTitle: StringConstants.OKAY)
        }
    }
    
    @IBAction func termsAndPrivacyButtonAction(_ sender: Any) {
        let termVc =  TermsAndPrivacyViewController.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(termVc, animated: true)
    }
    @IBAction func loginHereButtonAction(_ sender: Any) {
        
        let loginVc = LoginViewController.instantiate(fromAppStoryboard: .Login)
        self.navigationController?.pushViewController(loginVc, animated: true)
    }
    @IBAction func checkBoxButtonAction(_ sender: Any) {
        isCheckBox = !isCheckBox
        if isCheckBox {
            checkBoxButton.setImage(#imageLiteral(resourceName: "icons8-checked-checkbox-32"), for: .normal)
            print(isCheckBox)
        } else {
            checkBoxButton.setImage(#imageLiteral(resourceName: "icons8-unchecked-checkbox-32"), for: .normal)
            print(isCheckBox)
        }
        
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


extension RegisterViewController : UITextFieldDelegate {
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
