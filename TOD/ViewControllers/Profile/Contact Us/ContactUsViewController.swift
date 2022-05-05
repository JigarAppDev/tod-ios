//
//  ContactUsViewController.swift
//  TOD
//
//  Created by My Mac on 25/05/21.
//

import UIKit

class ContactUsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var btnBack: UIButton!
    @IBOutlet private weak var lblContactUs: UILabel!
    @IBOutlet private weak var viwSubject: UIView!
    @IBOutlet private weak var txtSubject: UITextView!
    @IBOutlet private weak var viwWriteYourMessage: UIView!
    @IBOutlet private weak var txtWriteYourMessage: UITextView!
    @IBOutlet private weak var btnSubmit: UIButton!
    @IBOutlet private weak var viwBottom: UIView!
    @IBOutlet private weak var lblYouCanCallUs: UILabel!
    @IBOutlet private weak var btnCall: UIButton!
    @IBOutlet weak var txtSubjectAlertButton: UIButton!
    @IBOutlet weak var txtWriteAlertButton: UIButton!
    // MARK: - Variables
    var profileDetails: TradiesProfileParam?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
    }
    
    // MARK: - Methods
    private func setupUI() {
        setupButton()
        setupTextView()
        setupView()
        setupPlaceholder()
    }
    
    private func setupPlaceholder() {
        txtSubject.setPlaceholder(message: "Subject & Topic", tag: 100)
        txtWriteYourMessage.setPlaceholder(message: "Write your message...", tag: 101)
    }

    private func setupTextView() {
        [txtSubject, txtWriteYourMessage].forEach { (textview) in
            textview?.delegate = self
        }
        
    }
    
    private func setupView() {
        viwSubject.addCornerRadius(12.0)
        viwSubject.clipsToBounds = true
        viwSubject.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.2, offset: CGSize(width: 0.0, height: 0.0), radius: 1)
        
        viwWriteYourMessage.addCornerRadius(12.0)
        viwWriteYourMessage.clipsToBounds = true
        viwWriteYourMessage.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.2, offset: CGSize(width: 0.0, height: 0.0), radius: 1)
        
        viwBottom.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.2, offset: CGSize(width: 0.0, height: -1.0), radius: 1)
    }
    
    private func setupButton() {
        btnSubmit.addCornerRadius(10.0)
        btnSubmit.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
        
        btnCall.addCornerRadius(10.0)
        btnCall.applyBorder(0.3, borderColor: UIColor.black)
        self.txtWriteAlertButton.isHidden = true
        self.txtSubjectAlertButton.isHidden = true
    }
    
    private func setupValidation(subject: String, description: String) -> Bool {
        if subject.isEmpty && description.isEmpty {

            self.txtSubjectAlertButton.isHidden = false
            self.txtWriteAlertButton.isHidden = false
            return false
        }
        else if subject.isEmpty {
            self.txtSubjectAlertButton.isHidden = true
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.SUBJECT_TOPIC_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if description.isEmpty {
            self.txtSubjectAlertButton.isHidden = true
            self.txtWriteAlertButton.isHidden = false
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.MESSAGE_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else {
            self.txtSubjectAlertButton.isHidden = true
            self.txtWriteAlertButton.isHidden = true
            return true
        }
        
        
    }
    
    private func getDocumentData(subject: String, description: String) -> [String: Any] {
        let userID: String = TODDefaultsManager.shared.userID
        if let profileDetail = self.profileDetails {
            let queriesParam: QueriesParam = QueriesParam(message: description,
                                                          subject: subject,
                                                          user_email: profileDetail.email,
                                                          user_id: userID,
                                                          user_mobile: profileDetail.phoneNumber,
                                                          user_name: profileDetail.displayName)
            return queriesParam.dbParamRequest
        }
        
        return [:]
    }
    
    // MARK: - API Call
    private func addQueries(subject: String, description: String) { 
        
        showLoader()
        let documentData: [String: Any] = getDocumentData(subject: subject, description: description)
        let randomStr: String = randomString(length: 20)
        APIHandler.shared.addQueries(forUserID: randomStr, with: documentData) { [weak self] (error) in
            guard let self = self else { return }
            
            if let error = error {
                DLog(error.localizedDescription)
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            } else {
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.SUCCESSFULLY_SUBMITTED, withOkButtonTitle: StringConstants.OKAY)
                self.navigationController?.popViewController(animated: true)
                return
            }
            
        }
    }
    
    
    // MARK: - IBActions
    @IBAction func onBtnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnCallAction(_ sender: UIButton) {
        guard let url: URL = URL(string: "tel://1234567890") else { return }
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func onBtnSubmitAction(_ sender: UIButton) {
        guard let subject = self.txtSubject.text else { return }
        guard let description = self.txtWriteYourMessage.text else { return }
        
        if self.setupValidation(subject: subject, description: description) {
            self.addQueries(subject: subject, description: description)
        }
    }
    
}

// MARK: - UITextViewDelegate
extension ContactUsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == txtSubject {
            textView.checkPlaceholder(tag: 100)
        } else if textView == txtWriteYourMessage {
            textView.checkPlaceholder(tag: 101)
        }
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == txtSubject {
            self.txtSubjectAlertButton.isHidden = true
        }else {
            self.txtWriteAlertButton.isHidden = true
        }
    }
    
}


