//
//  ProfileViewController.swift
//  TOD
//
//  Created by My Mac on 22/05/21.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class ProfileViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var viwNavigation: UIView!
    @IBOutlet private weak var imgNavigation: UIImageView!
    @IBOutlet private weak var lblProfile: UILabel!
    @IBOutlet private weak var viwMain: UIView!
    @IBOutlet private weak var viwUser: UIView!
    @IBOutlet private weak var viwUserProfile: UIView!
    @IBOutlet private weak var imgUserProfile: UIImageView!
    @IBOutlet private weak var lblUsername: UILabel!
    @IBOutlet private weak var lblEmail: UILabel!
    @IBOutlet private weak var lblPhonenumber: UILabel!
    @IBOutlet private weak var lblCredit: UILabel!
    @IBOutlet private weak var lblCreditLeft: UILabel!
    @IBOutlet private weak var btnAddService: UIButton!
    @IBOutlet private weak var btnEditProfile: UIButton!
    @IBOutlet private weak var viwOptions: UIView!
    @IBOutlet private weak var imgManageAddress: UIImageView!
    @IBOutlet private weak var imgContactUs: UIImageView!
    @IBOutlet private weak var imgShare: UIImageView!
    @IBOutlet private weak var imgTermsConditions: UIImageView!
    @IBOutlet private weak var imgSignOut: UIImageView!
    
    // MARK: - Variables
    private var userProfileData:TradiesProfileParam?
    private var userService : [String] = []
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showTabBar()
        getProfileData()
    } 
    
    // MARK: - Methods
    private func setupUI() {
        getProfileData()
        setupView()
        setupButton()
        setupImageView()
        checkService()
       
    }
    
    private func setupView() {
        viwUser.addCornerRadius(16.0)
        viwUser.clipsToBounds = true
        viwUser.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
        
        viwUserProfile.addCornerRadius(16.0)
        viwUserProfile.clipsToBounds = true
        viwUserProfile.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
        
        viwOptions.addCornerRadius(16.0)
        viwOptions.clipsToBounds = true
        viwOptions.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
    }
    
    private func setupButton() {
        self.btnAddService.addCornerRadius(self.btnAddService.frame.size.height / 2.0)
        self.btnAddService.applyBorder(1.0, borderColor: AppColor.COLOR_PRIMARY_RED)
        
        self.btnEditProfile.addCornerRadius(self.btnEditProfile.frame.size.height / 2.0)
        self.btnEditProfile.applyBorder(1.0, borderColor: AppColor.COLOR_PRIMARY_RED)
    }
    
    private func setupImageView() {
        imgUserProfile.addCornerRadius(16.0)
        imgManageAddress.tintColor = AppColor.APP_THEME_COLOR
        imgContactUs.tintColor = AppColor.APP_THEME_COLOR
        imgShare.tintColor = AppColor.APP_THEME_COLOR
        imgTermsConditions.tintColor = AppColor.APP_THEME_COLOR
        imgSignOut.tintColor = AppColor.APP_THEME_COLOR
    }
    
    private func setUpData() {
        self.lblUsername.text = self.userProfileData?.displayName
        self.lblEmail.text = self.userProfileData?.email
        self.lblPhonenumber.text = "\(self.userProfileData?.phoneNumber ?? "")"
        //self.imgUserProfile.sd_setImage(with: URL(string: self.userProfileData?.imageUrl ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
    }
    
//MARK:- Api Call
    private func getProfileData () {
        showLoader()
        let userId = TODDefaultsManager.shared.userID
        APIHandler.shared.getProfileData(userID: userId, completion: { [weak self] (response, error) in
            guard let self = self else { return }
            
            if let response = response {
                let model = TradiesProfileParam(dict: response)
                self.userProfileData = model
                self.setUpData()
                hideLoader()
            } else {
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: "\(error?.localizedDescription ?? "")", withOkButtonTitle: StringConstants.OKAY)
                hideLoader()
            }
        })
    }
    private func checkService() {
        showLoader()
        let userID = TODDefaultsManager.shared.userID
        self.userService.removeAll()
        
        APIHandler.shared.getTradiesService(userID: userID, completion:  { [weak self] (response, error) in
            guard let self = self else { return }
            hideLoader()
            if let response = response {
                if response.keys.count > 0 {
                   
                    for key in response.keys {
                        self.userService.append(key)
                    }
                } else {
                    
                }
            } else {
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: "\(error?.localizedDescription ?? "")", withOkButtonTitle: StringConstants.OKAY)
                return
            }
        })
    }
    private func userServicesOff(index:Int,services:[String]) {
        let userID = TODDefaultsManager.shared.userID
        if ReachabilityManager.shared.isNetworkReachable {
        if index < services.count {
            APIHandler.shared.updateActiveTradiesServices(forDocumentID: services[index], forUserID: userID, with: [ApiParameterStatics.status:false]) {  (error) in
                if let error = error {
                    hideLoader()
                    Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                    return
                } else {
                    self.userServicesOff(index: index + 1, services: self.userService)
                   
                }
        }
        
        } else {
                if APIHandler.shared.signOut() {
                    hideLoader()
                    TODDefaultsManager.shared.isUserLoggedIn = false
                    TODDefaultsManager.shared.userID = ""
                    let loginVc = LoginViewController.instantiate(fromAppStoryboard: .Login)
                    self.navigationController?.pushViewController(loginVc, animated: true)
                }
        }
        } else {
            hideLoader()
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.NETWORK_NOT_AVAILABLE, withOkButtonTitle: StringConstants.OKAY)
            
        }
     
    }
    
    // MARK: - IBActions
    @IBAction func onBtnEditProfileAction(_ sender: UIButton) {
        let nextVC = EditProfileViewController.instantiate(fromAppStoryboard: .Profile)
        nextVC.userProfileData = userProfileData
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onBtnAddServicesAction(_ sender: UIButton) {
        let nextVC = MyServicesViewController.instantiate(fromAppStoryboard: .Bookings)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onBtnManageAddressAction(_ sender: UIButton) {
        let nextVC = BusinessAddressViewController.instantiate(fromAppStoryboard: .Profile)
        //nextVC.userProfileData = userProfileData
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onBtnContactUsAction(_ sender: UIButton) {
        let nextVC = ContactUsViewController.instantiate(fromAppStoryboard: .Profile)
        nextVC.profileDetails = self.userProfileData
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onBtnShareItWithFriendAction(_ sender: UIButton) {
        let linkShare = [StringConstants.SHARE_DESCRIPTION_TEXT]
        let activityViewController = UIActivityViewController(activityItems: linkShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onBtnTermsConditionsAction(_ sender: UIButton) {
        let nextVC = TermsAndPrivacyViewController.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onBtnSignOutAction(_ sender: UIButton) {
        showLoader()
        self.userServicesOff(index: 0, services: self.userService)
    }
}
