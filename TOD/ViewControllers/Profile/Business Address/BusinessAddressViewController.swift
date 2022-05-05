//
//  BusinessAddressViewController.swift
//  TOD
//
//  Created by My Mac on 25/05/21.
//

import UIKit

class BusinessAddressViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var viwNavigation: UIView!
    @IBOutlet private weak var btnBack: UIButton!
    @IBOutlet private weak var lblBusinessAddress: UILabel!
    @IBOutlet private weak var viwMain: UIView!
    @IBOutlet private weak var viwAddress: UIView!
    @IBOutlet private weak var lblAddress: UILabel!
    @IBOutlet private weak var lblAddressDescription: UILabel!
    @IBOutlet private weak var viwHome: UIView!
    @IBOutlet private weak var imgHome: UIImageView!
    
    // MARK: - Variables
    private var profileDetails: TradiesProfileParam = TradiesProfileParam(dict: [:])

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
        setupImageView()
        getAddressFromProfileDetails()
    }
    
    // MARK: - Methods
    private func setupUI() {
        setupView()
        setupLabel() 
    }
    
    private func setupView() {
        viwAddress.addCornerRadius(10.0)
        viwAddress.clipsToBounds = true
        viwAddress.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
        
        viwHome.addCornerRadius(8.0)
        viwHome.clipsToBounds = true
        viwHome.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
    }

    private func setupLabel() {
        let formattedAddress = !profileDetails.address.completeAddress.isEmpty ? profileDetails.address.completeAddress : "\(profileDetails.address.doorNumber), \(profileDetails.address.street), \(profileDetails.address.city), \(profileDetails.address.state), \(profileDetails.address.pincode), \(profileDetails.address.country)"
        self.lblAddressDescription.text = formattedAddress
    }
    
    private func setupImageView() {
        imgHome.image = imgHome.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgHome.tintColor = AppColor.GREEN_COLOR
        imgHome.tintColorDidChange()
    }
    
    // MARK: - API Call
    private func getAddressFromProfileDetails() {
        
        let userID: String = TODDefaultsManager.shared.userID
        showLoader()
        APIHandler.shared.getProfileDetails(for: userID) { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                DLog(error.localizedDescription)
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            }
            
            if let documentSnapshot = documentSnapshot {
                if let documentData = documentSnapshot.data() {
                    let profileDetails: TradiesProfileParam = TradiesProfileParam(dict: documentData)
                    self.profileDetails = profileDetails
                    hideLoader()
                    self.setupLabel()
                }
            }
            
        }
    }
    
    // MARK: - IBActions
    @IBAction func onBtnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
