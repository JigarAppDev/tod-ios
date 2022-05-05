//
//  UploadLicsnseViewController.swift
//  TOD
//
//  Created by iMac on 25/05/21.
//

import UIKit

class UploadLicsnseViewController: UIViewController {
    //MARK:- Iboutlet
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveVerificationButton: UIButton!
    @IBOutlet weak var uploadLicesnseImageView: UIImageView!
    @IBOutlet weak var lctImgLicenseHeight: NSLayoutConstraint!
    @IBOutlet weak var lctViewLicenseHeight: NSLayoutConstraint!
    
    // MARK: - Variables
    private var licenseImage:UIImage?
    
    //MARK:-LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //MARK:- Functions
    
    private func setUpUI(){
        setUpButton()
        setupImageView(isImageSelected: false)
        TODDefaultsManager.shared.reOpenViewController = "UploadLicsnseViewController"
    }
    
    private func setUpButton() {
        self.saveVerificationButton.backgroundColor = AppColor.APP_THEME_COLOR
        self.saveVerificationButton.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
    }
    
    func showAlertCam() {
        
        let alert = UIAlertController(title: "Image Selection", message: "From where you want to pick this image?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func setupValidation() -> Bool {
        if licenseImage == nil {
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PLEASE_UPLOAD_DRIVING_LICENSE, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else {
            return true
        }
    }
    
    private func getDocumentData(with url: URL) -> [String: Any] {
        let user_dl: UserDL = UserDL(isUploaded: true,
                                     url: url.absoluteString)
        let parameters = [ApiParameterStatics.user_dl: user_dl.dbParamRequest]
        return parameters
    }
    
    private func setupImageView(isImageSelected: Bool) {
        if isImageSelected {
            lctImgLicenseHeight.constant = 80.0
            uploadLicesnseImageView.isHidden = false
            lctViewLicenseHeight.constant = 200.0
        } else {
            lctImgLicenseHeight.constant = 0.0
            uploadLicesnseImageView.isHidden = true
            lctViewLicenseHeight.constant = 100.0
        }
    }
    
    // MARK: - API Call
    private func uploadDrivingLicenseOnStorage() {
        showLoader()
        
        guard let imageData = self.licenseImage?.jpegData(compressionQuality: 1.0) else { return }
        let imageName: String = "\(Date().timeIntervalSince1970).png"
      
       
        APIHandler.shared.uploadDrivingLicenseOnStorage(for: TODDefaultsManager.shared.userID, imageData: imageData, imageName: imageName) { [weak self] (metaData, error, url, downloadError) in
            guard let self = self else { return }
            
            if let error = error {
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            }
            
            if let downloadError = downloadError {
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: downloadError.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            }
        
            if let url = url {
                self.uploadDrivingLicenseDetailsOnTradiesProfile(with: url)
            }
            
        }
        
    }
    
    private func uploadDrivingLicenseDetailsOnTradiesProfile(with url: URL) {
        
        let documentData: [String: Any] = getDocumentData(with: url)
        APIHandler.shared.uploadDrivingLicense(for: TODDefaultsManager.shared.userID, documentData: documentData) { [weak self] error in
            
            guard let self = self else { return }
            DLog(self)
            hideLoader()
            
            if let error = error {
                DLog(error.localizedDescription)
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            } else {
                TODDefaultsManager.shared.isUserLoggedIn = true
                TODDefaultsManager.shared.uploadPermit = "Done"
                AppDelegate.shared.initializeTabBar()
            }
            
        }
    }
    
    
    //MARK:- IBAction
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func uploadDLOnClickButtonAction(_ sender: Any) {
        showAlertCam()
    }
    
    @IBAction func saveVerificationButtonAction(_ sender: Any) {
        if setupValidation() {
            uploadDrivingLicenseOnStorage()
        }
    }
    
}
//MARK:- UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension UploadLicsnseViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    //MARK:- UIImagePickerViewDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.dismiss(animated: true) { [weak self] in
           
            guard let self = self else { return }
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            let imageSizes = image.getSizeIn(.megabyte)
            print("Image size \(image.getSizeIn(.megabyte)) mb")
            if imageSizes > "50" {
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.IMAGE_UPLOAD_SIZE, withOkButtonTitle: StringConstants.OKAY)
            } else {
                self.setupImageView(isImageSelected: true)
                self.uploadLicesnseImageView.image = image
                self.licenseImage = image
            }
            
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
