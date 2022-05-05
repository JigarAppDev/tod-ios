//
//  UploadPermitViewController.swift
//  TOD
//
//  Created by My Mac on 24/05/21.
//

import UIKit
import MobileCoreServices

class UploadPermitViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var viwNavigation: UIView!
    @IBOutlet private weak var btnBack: UIButton!
    @IBOutlet private weak var lblUploadPermit: UILabel!
    @IBOutlet private weak var viwMain: UIView!
    @IBOutlet private weak var viwPermitNeeded: UIView!
    @IBOutlet private weak var lblPermitNeeded: UILabel!
    @IBOutlet private weak var viwSeparator: UIView!
    @IBOutlet private weak var btnSubmitForVerification: UIButton!
    @IBOutlet private weak var clvPermits: UICollectionView!
    
    @IBOutlet private weak var tblPermitNeeded: UITableView!
    @IBOutlet private weak var lctTableHeight: NSLayoutConstraint!
    
    // MARK: - Variables
    private let imagePicker: UIImagePickerController = UIImagePickerController()
    private var arrOfUploadedPermit: [UIImage] = []
    private var arrOfURLString: [String] = []
    private var defaultCellHeight: CGFloat = 150.0
    private var extraSpace: CGFloat = 87.0
    private var extraBottomSpace: CGFloat = 16.5
    private var selectedIndex: Int = -1
    public var selectedService: Service = Service(dict: [:])

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationView()
    }
    
    // MARK: - Methods
    private func setupUI() {
        setupView()
        setupButton()
        setupImagePicker()
        setupTableView()
        setupCollectionView()
        setupTableHeight()
    }
    
    private func setupView() {
        viwPermitNeeded.addCornerRadius(10.0)
    }
    
    private func setupButton() {
        btnSubmitForVerification.addCornerRadius(10.0)
        btnSubmitForVerification.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
    }
    
    private func setupNavigationView() {
        viwNavigation.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.5, offset: CGSize(width: 0.0, height: 1.0), radius: 1.0)
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    private func setupCollectionView() {
        clvPermits.delegate = self
        clvPermits.dataSource = self
        clvPermits.register(UploadPermitCell.nib, forCellWithReuseIdentifier: UploadPermitCell.identifier)
        clvPermits.reloadData()
    }
    
    private func setupTableView() {
        tblPermitNeeded.delegate = self
        tblPermitNeeded.dataSource = self
        tblPermitNeeded.register(PermitDetailCell.nib, forCellReuseIdentifier: PermitDetailCell.identifier)
        tblPermitNeeded.reloadData()
    }
    
    private func setupTableHeight() {
        var defaultTableCellHeight: CGFloat = 0.0
        
        for permit in selectedService.permitNeeded {
            let labelText: String = "\(permit.permit_name) : \(permit.permit_description)"
            let width: CGFloat = ScreenSize.SCREEN_WIDTH - extraSpace
            let tableRowHeight = self.computeHeight(text: labelText, width: width) + extraBottomSpace
            defaultTableCellHeight += tableRowHeight
        }
        
        self.lctTableHeight.constant = defaultTableCellHeight
    }
    
    private func selectedPermit(at index: Int) {
        selectedIndex = index
        showImagePicker()
    }
    
    private func showImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.modalPresentationStyle =  .fullScreen
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func getDocumentData() -> [String: Any] {
        
        var arrOfPermit: [PermitParam] = []

        for (index, urlString) in arrOfURLString.enumerated() {
            if selectedService.permitNeeded.count > index {
                let permit_description: String = selectedService.permitNeeded[index].permit_description
                let permit_example: String = selectedService.permitNeeded[index].permit_example
                let permit_name: String = selectedService.permitNeeded[index].permit_name
                let permit_verified: String = "rejected"
                let permitParam: PermitParam = PermitParam(permit_description: permit_description,
                                                           permit_example: permit_example,
                                                           permit_name: permit_name,
                                                           permit_file: urlString,
                                                           permit_verified: permit_verified)
                arrOfPermit.insert(permitParam, at: index)
            } 
        }
        
        let serviceType: ServiceType = ServiceType(permit_submitted: arrOfPermit,
                                                   service_code: selectedService.service_code,
                                                   service_name: selectedService.service_name,
                                                   service_option_code: selectedService.service_option_code,
                                                   service_type: selectedService.service_type,
                                                   verified: false)

        let serviceParam: ServiceParam = ServiceParam(serviceName: selectedService.service_type,
                                                      type: serviceType)
        let servicesDict: ServicesDict = ServicesDict(param: serviceParam)
        return servicesDict.dbParamRequest
    }
    
    
    // MARK: - API Call
    private func uploadPermitOnStorage() {
        showLoader()
        let userID: String = TODDefaultsManager.shared.userID
        for (index, image) in self.arrOfUploadedPermit.enumerated() {
            
            guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
            let imageName: String = "\(Date().timeIntervalSince1970).png"
            
            APIHandler.shared.uploadPermitOnStorage(for: userID, imageData: imageData, imageName: imageName, serviceName: selectedService.service_type) { [weak self] (metaData, error, url, downloadError) in
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
                    self.arrOfURLString.append(url.absoluteString)
                    
                    if index == self.arrOfUploadedPermit.count - 1 {
                        self.addService(userID: userID)
                    }
                }
                
            }
        }
        
    }
    
    private func addService(userID: String) {
        let documentData: [String: Any] = getDocumentData()
        
        APIHandler.shared.addService(for: userID, documentData: documentData) { [weak self] (error) in
            guard let self = self else { return }
            
            if let error = error {
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            } else {
                hideLoader()
                self.goBackToBookingsScreen()
            }
        }
        
    }
    
    private func goBackToBookingsScreen() {
        if let navVC = self.navigationController {
            for controller in navVC.viewControllers as Array {
                if controller.isKind(of: MyServicesViewController.self) {
                    navVC.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }
    
    private func computeHeight(text: String, width: CGFloat) -> CGFloat {
        
        let label = UILabel()

        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = AppFont.ROBOTO_LIGHT_14

        label.preferredMaxLayoutWidth = width
        label.text = text
        label.invalidateIntrinsicContentSize()

        let height = label.intrinsicContentSize.height
        return height
    }
    
    // MARK: - IBActions
    @IBAction func onBtnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnSubmitForVerification(_ sender: UIButton) {
        if self.arrOfUploadedPermit.count == self.selectedService.permitNeeded.count {
            self.uploadPermitOnStorage()
        } else {
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PLEASE_UPLAOD_ALL_THE_PERMITS, withOkButtonTitle: StringConstants.OKAY)
            return
        }
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension UploadPermitViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedService.permitNeeded.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = clvPermits.dequeueReusableCell(withReuseIdentifier: UploadPermitCell.identifier, for: indexPath) as? UploadPermitCell else { return UICollectionViewCell() }
        
        if selectedService.permitNeeded.count > indexPath.row {
            let permitName: String = selectedService.permitNeeded[indexPath.row].permit_name
            let image: UIImage? = arrOfUploadedPermit.count > indexPath.row ? arrOfUploadedPermit[indexPath.row] : nil
            cell.setData(permitName: permitName, image: image)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSpacing: CGFloat = 15.0
        let collectionViewWidth: CGFloat = ScreenSize.SCREEN_WIDTH - 20.0
        let width: CGFloat = (collectionViewWidth - cellSpacing) / 2.0
        let height: CGFloat = arrOfUploadedPermit.count > indexPath.row ? (defaultCellHeight + 80) : defaultCellHeight
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedPermit(at: indexPath.row)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension UploadPermitViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedService.permitNeeded.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tblPermitNeeded.dequeueReusableCell(withIdentifier: PermitDetailCell.identifier, for: indexPath) as? PermitDetailCell else { return UITableViewCell() }
        
        if selectedService.permitNeeded.count > indexPath.row {
            let permit: Permit = selectedService.permitNeeded[indexPath.row]
            cell.setData(for: permit)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedService.permitNeeded.count > indexPath.row {
            let permit: Permit = selectedService.permitNeeded[indexPath.row]
            let labelText: String = "\(permit.permit_name) : \(permit.permit_description)"
            let width: CGFloat = ScreenSize.SCREEN_WIDTH - extraSpace
            let tableRowHeight = self.computeHeight(text: labelText, width: width) + extraBottomSpace
            return tableRowHeight
        }
        
        return 40.0
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension UploadPermitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        dismiss(animated:true, completion: {
            let imageSizes = image.getSizeIn(.megabyte)
            print("Image size \(image.getSizeIn(.megabyte)) mb")
            if imageSizes > "50"  {
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.IMAGE_UPLOAD_SIZE, withOkButtonTitle: StringConstants.OKAY)
            } else {
                
            if self.selectedIndex != -1 {
                if self.arrOfUploadedPermit.count > self.selectedIndex {
                    self.arrOfUploadedPermit.remove(at: self.selectedIndex)
                }
                
                self.arrOfUploadedPermit.insert(image, at: self.selectedIndex)
                let indexPath: IndexPath = IndexPath(row: self.selectedIndex, section: 0)
                self.clvPermits.reloadItems(at: [indexPath])
            }
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
}
