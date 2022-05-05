//
//  ResetPasswordViewController.swift
//  TOD
//
//  Created by iMac on 22/05/21.
//

import UIKit
import SkyFloatingLabelTextField

class ResetPasswordViewController: UIViewController {
    //MARK:- IbOutlet
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var resetPasswordBUtton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextFieldWithIcon!
    
    //MARK:- Variable Declaration
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    //MARK:- Function
    
    private func setUpUI() {
        setUpButton()
    }
    
    private func setUpButton() {
        self.resetPasswordBUtton.backgroundColor = AppColor.APP_THEME_COLOR
        self.resetPasswordBUtton.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
        
    }
    
    private func setupValidation(email: String) -> Bool {
        if email.isEmpty {
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.EMAIL_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        }
        return true
    }
    
    
    // MARK: - API Call
    private func resetPassword(withEmail: String) {
        
        showLoader()
        
        APIHandler.shared.resetPassword(withEmail: withEmail) { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                DLog(error.localizedDescription)
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            } else {
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.SENT_RESET_PASSWORD_LINK, withOkButtonTitle: StringConstants.OKAY)
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
        
    }
    
    //MARK:- IbButton Action
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetPasswordButtonAction(_ sender: Any) {
        
        guard let email = self.txtEmail.text else { return }
        
        if self.setupValidation(email: email) {
            self.resetPassword(withEmail: email)
        }

    }
    
    
}
