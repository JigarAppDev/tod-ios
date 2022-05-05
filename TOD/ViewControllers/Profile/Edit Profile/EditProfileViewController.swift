//
//  EditProfileViewController.swift
//  TOD
//
//  Created by My Mac on 25/05/21.
//

import UIKit
import SDWebImage
class EditProfileViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var viwNavigation: UIView!
    @IBOutlet private weak var lblProfile: UILabel!
    @IBOutlet private weak var btnBack: UIButton!
    @IBOutlet private weak var viwMain: UIView!
    @IBOutlet private weak var viwUserProfile: UIView!
    @IBOutlet private weak var imgUserProfile: UIImageView!
    @IBOutlet private weak var lblFullName: UILabel!
    @IBOutlet private weak var viwFullName: UIView!
    @IBOutlet private weak var txtFullName: UITextField!
    @IBOutlet private weak var lblEmail: UILabel!
    @IBOutlet private weak var viwEmail: UIView!
    @IBOutlet private weak var txtEmail: UITextField!
    @IBOutlet private weak var lblMobileNumber: UILabel!
    @IBOutlet private weak var viwMobileNumber: UIView!
    @IBOutlet private weak var btnUpdate: UIButton!
    @IBOutlet weak var txtMobileNumber: UITextField!
    
    @IBOutlet weak var fullNameAlretButton: UIButton!
    // MARK: - Variables
    var userProfileData:TradiesProfileParam?
    
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
        setupView()
        setupImageView()
        setupButton()
        setupData()
        setUpTextField()
    }
    
    private func setupView() {
        DispatchQueue.main.async {
            self.viwMain.roundCorners([.topLeft, .topRight], radius: 20.0)
        }
        
        viwUserProfile.addCornerRadius(16.0)
        viwUserProfile.clipsToBounds = true
        viwUserProfile.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
        
        viwFullName.addCornerRadius(12.0)
        viwEmail.addCornerRadius(12.0)
        viwMobileNumber.addCornerRadius(12.0)
    }
    
    private func setUpTextField() {
        self.txtFullName.delegate = self
       // txtFullName.addTarget(self, action: #selector(textFillChange), for: .editingChanged)
    }
    
    private func setupImageView() {
        imgUserProfile.addCornerRadius(16.0)
        imgUserProfile.clipsToBounds = true
        imgUserProfile.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
    }
    
    private func setupButton() {
        self.fullNameAlretButton.isHidden = true
        btnUpdate.addCornerRadius(10.0)
        btnUpdate.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
    }
    
    private func getDocumentData(for username: String) -> [String: Any] {
        let param:[String: Any] = [ApiParameterStatics.display_name: username]
        return param
    }
    
    private func setupValidation(for displayName: String) -> Bool {
        if displayName.isEmpty  {
            fullNameAlretButton.isHidden = false
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.FULL_NAME_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        }
        
        if displayName.count <= 3  {
            fullNameAlretButton.isHidden = false
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PLEASE_ENTER_ONLY_CHARACTER_YOUR_NAME, withOkButtonTitle: StringConstants.OKAY)
            return false
        }
        if displayName.count >= 32 {
            fullNameAlretButton.isHidden = false
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PLEASE_ENTER_ONLY_CHARACTER_YOUR_NAME, withOkButtonTitle: StringConstants.OKAY)
            return false
        }
        return true
    }
    
    // MARK: - API Call
    private func editUserProfile(for username: String) {
        showLoader()
        let userID: String = TODDefaultsManager.shared.userID
        APIHandler.shared.editProfileDetails(for: userID, documentData: getDocumentData(for: username)) { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                DLog(error.localizedDescription)
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            } else {
                hideLoader()
                TODDefaultsManager.shared.name = username
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func setupData() {
        self.txtFullName.text = userProfileData?.displayName
        self.txtEmail.text = userProfileData?.email
        self.txtMobileNumber.text = userProfileData?.phoneNumber
        guard let url = self.userProfileData?.imageUrl else { return }
        guard let placeholderImage: UIImage = UIImage(named: "ic_user.png") else { return }
        self.imgUserProfile.sd_setImage(with: URL(string: url), placeholderImage: placeholderImage)
    }
//    private func showAlertCam() {
//
//        let alert = UIAlertController(title: "Image Selection", message: "From where you want to pick this image?", preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
//            self.getImage(fromSourceType: .camera)
//        }))
//        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
//            self.getImage(fromSourceType: .photoLibrary)
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//
//    }
    
    //MARK:- Action
    
//    @objc func textFillChange() {
//        if self.txtFullName.text?.count ?? 0 == 32 {
//            Utility.showMessageAlert(title: Bundle.appName(), andMessage:StringConstants.PLEASE_ENTER_ONLY_CHARACTER_YOUR_NAME , withOkButtonTitle: StringConstants.OKAY)
//        }
//    }
    // MARK: - IBActions
    @IBAction func onBtnUpdateAction(_ sender: UIButton) {
        guard let displayName = self.txtFullName.text else { return }
        if setupValidation(for: displayName) {
            self.editUserProfile(for: displayName)
        }
    }
    
    @IBAction func onBtnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    
}
//MARK:- UIImagePickerControllerDelegate, UINavigationControllerDelegate
//extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
//
//        //Check is source type available
//        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
//            let imagePickerController = UIImagePickerController()
//            imagePickerController.delegate = self
//            imagePickerController.sourceType = sourceType
//            self.present(imagePickerController, animated: true, completion: nil)
//        }
//    }
//
//    //MARK:- UIImagePickerViewDelegate
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        self.dismiss(animated: true) { [weak self] in
//            guard let self = self else { return }
//            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
//            //self.uploadLicesnseImageView.isHidden = false
//            self.imgUserProfile.image = image
//          // self.licenseImage = image
//        }
//
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//}

extension EditProfileViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        
        if textField == txtFullName {
            if string.count <= 3 || string.count >= 32 {
                fullNameAlretButton.isHidden = true
            } else {
                fullNameAlretButton.isHidden = false
            }
        }
        let invalidCharacters = CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ ")
        return string.rangeOfCharacter(from: invalidCharacters.inverted) == nil
    }
    
    
}
