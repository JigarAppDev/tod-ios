//
//  BookingsViewController.swift
//  TOD
//
//  Created by My Mac on 22/05/21.
//

import UIKit
import PushKit
import CallKit
import Alamofire
import TwilioVoice
import CoreLocation
import FirebaseFirestore
import AdvancedPageControl

class BookingsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var viwNavigation: UIView!
    @IBOutlet private weak var viwMain: UIView!
    @IBOutlet private weak var lblBookings: UILabel!
    @IBOutlet private weak var lblLocation: UILabel!
    @IBOutlet private weak var btnServices: UIButton!
    @IBOutlet private weak var btnOpen: UIButton!
    @IBOutlet private weak var viwOpen: UIView!
    @IBOutlet private weak var btnScheduled: UIButton!
    @IBOutlet private weak var viwScheduled: UIView!
    @IBOutlet private weak var btnCompleted: UIButton!
    @IBOutlet private weak var viwCompleted: UIView!
    @IBOutlet private weak var tblBookings: UITableView!
    @IBOutlet private weak var lblEmpty: UILabel!
    @IBOutlet private weak var pageControl: AdvancedPageControlView!
    @IBOutlet private weak var lctPageControlWidth: NSLayoutConstraint!
    @IBOutlet private weak var lctPageControlCenterY: NSLayoutConstraint!
    
    // MARK: - Variables
    var pushKitEventDelegate: PushKitEventDelegate?
    private var selectedTab: Int = 0
    private let locationManager = CLLocationManager()
    private var arrInPogressJobs = [BookingModel]()
    private var arrCompletedJobs = [BookingModel]()
    private var arrScheduledJobs = [BookingModel]()
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        isFirstTime = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lblEmpty.isHidden = true
        self.arrCompletedJobs.removeAll()
        self.arrInPogressJobs.removeAll()
        self.arrScheduledJobs.removeAll()
        showTabBar()
        self.getProfileData()
        self.getJobDetails()
        
    }
    // MARK: - Methods
    private func setupUI() {
        setupView()
        setupOptionView()
        setupLocation()
        setupTableView()
        setupPageControl()
        setupDelegate()
    }
    
    private func setupView() {
        DispatchQueue.main.async {
            self.viwMain.roundCorners([.topLeft, .topRight], radius: 20.0)
        }
        viwOpen.addCornerRadius(viwOpen.frame.size.height / 2.0)
        viwScheduled.addCornerRadius(viwScheduled.frame.size.height / 2.0)
        viwCompleted.addCornerRadius(viwCompleted.frame.size.height / 2.0)
    }
    
    private func setupTableView() {
        tblBookings.delegate = self
        tblBookings.dataSource = self
        tblBookings.tableFooterView = UIView()
        tblBookings.backgroundColor = .clear
        tblBookings.register(BookingsDetailCell.nib, forCellReuseIdentifier: BookingsDetailCell.identifier)
        tblBookings.reloadData()
    }
    
    private func setupDelegate() {
        incomingVC.setupCallKitProvider()
        self.pushKitEventDelegate = incomingVC
    }
    
    private func setupOptionView() {
        
        if selectedTab == 0 {
            btnOpen.setTitleColor(AppColor.BLACK_COLOR, for: .normal)
            btnScheduled.setTitleColor(AppColor.OPTION_GRAY_COLOR, for: .normal)
            btnCompleted.setTitleColor(AppColor.OPTION_GRAY_COLOR, for: .normal)
        } else if selectedTab == 1 {
            btnOpen.setTitleColor(AppColor.OPTION_GRAY_COLOR, for: .normal)
            btnScheduled.setTitleColor(AppColor.BLACK_COLOR, for: .normal)
            btnCompleted.setTitleColor(AppColor.OPTION_GRAY_COLOR, for: .normal)
        } else if selectedTab == 2 {
            btnOpen.setTitleColor(AppColor.OPTION_GRAY_COLOR, for: .normal)
            btnScheduled.setTitleColor(AppColor.OPTION_GRAY_COLOR, for: .normal)
            btnCompleted.setTitleColor(AppColor.BLACK_COLOR, for: .normal)
        }
        
        pageControl.setPage(selectedTab)
        
        self.tblBookings.reloadData()
    }
    
    private func setupPageControl() {
        let width: CGFloat = ScreenSize.SCREEN_WIDTH
        let height: CGFloat = 8.0
        let space: CGFloat = (width / 3.0) - 6.0
        lctPageControlWidth.constant = (space * 3) + (width / 2.0)
        let originX: CGFloat = 0.0
        self.pageControl.layoutIfNeeded()
        let rect: CGRect = CGRect(x: originX, y: 0.0, width: lctPageControlWidth.constant, height: height)
        let drawer = ThinWormDrawer(numberOfPages: 0, height: 6, width: 6, space: space, raduis: 3, currentItem: 0, indicatorColor: AppColor.APP_THEME_COLOR, dotsColor: AppColor.APP_THEME_COLOR, isBordered: false, borderColor: .clear, borderWidth: 0, indicatorBorderColor: .clear, indicatorBorderWidth: 0)
        drawer.draw(rect)
        pageControl.drawer = drawer
        
        if Utility.shared.hasTopNotch {
            self.lctPageControlCenterY.constant = 141.0
        } else {
            if DeviceType.IS_IPHONE_6P {
                self.lctPageControlCenterY.constant = 137.0
            } else {
                self.lctPageControlCenterY.constant = 128.0
            }
        }
    }
    
    private func setupLocation() {
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        switch status {
        
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            return
            
        case .denied, .restricted:
            
            Utility.showAlertForAppSettings(title: StringConstants.LOCATION_SERVICES_DISABLED, message: StringConstants.PLEASE_ENABLE_LOCATION_SERVICES) { (isSuccess) in
                DLog("Alert Shown")
            }
            
            return
        case .authorizedAlways, .authorizedWhenInUse:
            break
            
        default:
            break
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
            locationManager.requestAlwaysAuthorization()
        }
        
    }
    
    
    func getAddressFromLatLong(latitude: String, withLongitude longitude: String) {
        isFirstTime = false
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        guard let lat: Double = Double("\(latitude)") else { return }
        guard let lon: Double = Double("\(longitude)") else { return }
        
        let geoCoder: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let location: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        geoCoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if (error != nil) {
                //print("reverse geodcode fail: \(error?.localizedDescription ?? "")")
            }
            
            if let placemarks = placemarks, placemarks.count > 0  {
                let placemark = placemarks[0]
                DispatchQueue.main.async {
                    if let zipCode = placemark.postalCode {
                        self.lblLocation.text = "You're at \(zipCode)"
                        TODDefaultsManager.shared.pinCode = zipCode
                    }
                }
            }
            
        }
        
    }
    
    private func getHeaders() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            ApiParameterStatics.authorization: "\(ApiParameterStatics.basic) \(KeyConstants.TWILIO_AUTHORIZATION_TOKEN)",
            ApiParameterStatics.content_type: ApiParameterStatics.x_www_form_urlencoded]
        return headers
    }
    
    private func getParameters(to number: String) -> [String: Any] {
        let parameters: [String: Any] = [ApiParameterStatics.Url: URLConstants.getAudioURL(),
                                         ApiParameterStatics.to: number,
                                         ApiParameterStatics.from: KeyConstants.FROM_VERIFIED_NUMBER]
        return parameters
    }
    
    // MARK: - API Call
    private func makeCallToThePerson(to number: String) {
        
        showLoader()
        
        let urlString = URLConstants.getMakeCallURL(with: KeyConstants.ACCOUNT_SID)
        let parameters: [String: Any] = getParameters(to: number)
        let headers: HTTPHeaders = getHeaders()
        guard let url = URL(string: urlString) else { return }
        
        APIHandler.shared.makeCall(with: url, parameters: parameters, headers: headers) { [weak self] (responseDict, error) in
            guard let self = self else { return }
            
            if let error = error {
                DLog(error.localizedDescription)
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            }
        
            if let responseDict = responseDict {
                hideLoader()
                DLog(responseDict)
                let nextVC = VoiceCallViewController()
                nextVC.callerName = number
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
        
    }
    
    private func checkArrauCount() {
        switch selectedTab {
        case 0:
            if self.arrInPogressJobs.count < 1 {
                self.lblEmpty.isHidden = false
                self.lblEmpty.text = StringConstants.ALL_ACTIVE_JOBS_HERE
                self.lblEmpty.textColor = AppColor.APP_THEME_COLOR
            } else {
                self.lblEmpty.isHidden = true
            }
        case 1:
            if self.arrScheduledJobs.count < 1 {
                self.lblEmpty.isHidden = false
                self.lblEmpty.text = StringConstants.ALL_SCHEDULED_JOBS_HERE
                self.lblEmpty.textColor = AppColor.APP_THEME_COLOR
            } else {
                self.lblEmpty.isHidden = true
            }
        case 2 :
            if self.arrCompletedJobs.count < 1 {
                self.lblEmpty.isHidden = false
                self.lblEmpty.text = StringConstants.ALL_COMPLETED_JOBS_HERE
                self.lblEmpty.textColor = AppColor.APP_THEME_COLOR
            } else {
                self.lblEmpty.isHidden = true
            }
        default:
            break
        }
    }

    private func getJobDetails() {
        //let userID = "jjiLOQwMVPVRhvMSDRvHJZDv2su2" //::Development testing userID
        //let userID = "2msRZIqcEfUq5o1o6EQbRoK0tnt11" //::Production testing userID
         let userID = TODDefaultsManager.shared.userID
        showLoader()
        APIHandler.shared.getJobDetail(userID: userID,
                                       completion: { (value, error) in
                                        hideLoader()
                                        value?.documents.forEach({ (data) in
                                            if let sp_id = data.data()["\(ApiParameterStatics.sp_id)"] as? String {
                                                if sp_id == userID {
                                                    if let jobcompletionstatus = data.data()["\(ApiParameterStatics.job_completion_status)"] as? String {
                                                        if jobcompletionstatus == ApiParameterStatics.inprogress {
                                                            let value = BookingModel(dict: data.data())
                                                            self.arrInPogressJobs.append(value)
                                                        } else if jobcompletionstatus == ApiParameterStatics.completed {
                                                            let value = BookingModel(dict: data.data())
                                                            self.arrCompletedJobs.append(value)
                                                        } else if jobcompletionstatus == ApiParameterStatics.scheduled {
                                                            let value = BookingModel(dict: data.data())
                                                            self.arrScheduledJobs.append(value)
                                                        } else if jobcompletionstatus == ApiParameterStatics.call_inprogress {
                                                            let value = BookingModel(dict: data.data())
                                                            self.arrInPogressJobs.append(value)
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                            
                                        })
                                        
                                        self.checkArrauCount()
                                        self.tblBookings.reloadData()
                                        
                                       })
    }
    
    private func getProfileData() {
        let userId = TODDefaultsManager.shared.userID
        APIHandler.shared.getProfileData(userID: userId, completion: { [weak self] (response, error) in
            guard let self = self else { return }
            
            if let response = response {
                let model = TradiesProfileParam(dict: response)
                TODDefaultsManager.shared.email = model.email
                TODDefaultsManager.shared.mobileNumber = model.phoneNumber
                TODDefaultsManager.shared.name = model.displayName
                return
            } else {
                DLog(self)
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: "\(error?.localizedDescription ?? "")", withOkButtonTitle: StringConstants.OKAY)
                return
            }
        })
    }
    
    // MARK: - IBActions
    @IBAction func onBtnServicesAction(_ sender: UIButton) {
        let nextVC = MyServicesViewController.instantiate(fromAppStoryboard: .Bookings)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onBtnOpenAction(_ sender: UIButton) {
        selectedTab = 0
        setupOptionView()
        if arrInPogressJobs.count <= 0 {
            self.lblEmpty.isHidden = false
            self.lblEmpty.text = StringConstants.ALL_ACTIVE_JOBS_HERE
            self.lblEmpty.textColor = AppColor.APP_THEME_COLOR
        } else {
            self.tblBookings.reloadData()
            self.lblEmpty.isHidden = true
        }
        
    }
    
    @IBAction func onBtnScheduledAction(_ sender: UIButton) {
        selectedTab = 1
        setupOptionView()
        if arrScheduledJobs.count <= 0 {
            self.lblEmpty.isHidden = false
            self.lblEmpty.text = StringConstants.ALL_SCHEDULED_JOBS_HERE
            self.lblEmpty.textColor = AppColor.APP_THEME_COLOR
        } else {
            self.tblBookings.reloadData()
            self.lblEmpty.isHidden = true
        }
        
    }
    
    @IBAction func onBtnCompletedAction(_ sender: UIButton) {
        selectedTab = 2
        setupOptionView()
        if arrCompletedJobs.count <= 0 {
            self.lblEmpty.isHidden = false
            self.lblEmpty.text = StringConstants.ALL_COMPLETED_JOBS_HERE
            self.lblEmpty.textColor = AppColor.APP_THEME_COLOR
        } else {
            self.tblBookings.reloadData()
            self.lblEmpty.isHidden = true
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BookingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTab == 0 {
            return arrInPogressJobs.count
        } else if selectedTab == 1 {
            return arrScheduledJobs.count
        } else if selectedTab == 2 {
            return arrCompletedJobs.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tblBookings.dequeueReusableCell(withIdentifier: BookingsDetailCell.identifier, for: indexPath) as? BookingsDetailCell else { return UITableViewCell() }
        switch selectedTab {
        case 0:
            if arrInPogressJobs.count > indexPath.row {
                cell.setupData(data: arrInPogressJobs[indexPath.row], selectedTab: selectedTab)
            }
        case 1 :
            if arrScheduledJobs.count > indexPath.row {
                cell.setupData(data: arrScheduledJobs[indexPath.row], selectedTab: selectedTab)
            }
        case 2 :
            if arrCompletedJobs.count > indexPath.row {
                cell.setupData(data: arrCompletedJobs[indexPath.row], selectedTab: selectedTab)
            }
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedTab {
        case 0:
            if arrInPogressJobs.count > indexPath.row {
                let nextVC = BookingDetailViewController.instantiate(fromAppStoryboard: .Bookings)
                nextVC.delegate = self
                nextVC.arrDetailsOfJobs = arrInPogressJobs[indexPath.row]
                nextVC.isDoneButtton = false
                self.presentPanModal(nextVC)
            }
        case 1 :
            if arrScheduledJobs.count > indexPath.row {
                let nextVC = BookingDetailViewController.instantiate(fromAppStoryboard: .Bookings)
                nextVC.delegate = self
                nextVC.arrDetailsOfJobs = arrScheduledJobs[indexPath.row]
                nextVC.isDoneButtton = false
                self.presentPanModal(nextVC)
            }
        case 2 :
            if arrCompletedJobs.count > indexPath.row {
                let nextVC = BookingDetailViewController.instantiate(fromAppStoryboard: .Bookings)
                nextVC.delegate = self
                nextVC.arrDetailsOfJobs = arrCompletedJobs[indexPath.row]
                nextVC.isDoneButtton = true
                self.presentPanModal(nextVC)
            }
        default:
            break
        }
    }
    
}

// MARK: - CLLocationManagerDelegate
extension BookingsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            latitude = "\(currentLocation.coordinate.latitude)"
            longitude = "\(currentLocation.coordinate.longitude)"
            
            TODDefaultsManager.shared.latitude = latitude
            TODDefaultsManager.shared.longitude = longitude
            if isFirstTime {
                self.getAddressFromLatLong(latitude: latitude, withLongitude: longitude)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted:
            break
        case .denied:
            break
        default:
            break
        }
    }
    
}

// MARK: - BookingDetailViewControllerDelegate
extension BookingsViewController: BookingDetailViewControllerDelegate {
    
    func didPressedCallButton(with phoneNumber: String) {
        //self.makeCallToThePerson(to: phoneNumber)
    }
    
    
}


// MARK: - PushKitEventDelegate
extension BookingsViewController: PushKitEventDelegate {
    
    func credentialsUpdated(credentials: PKPushCredentials, token: String) {
        if let delegate = self.pushKitEventDelegate {
            delegate.credentialsUpdated(credentials: credentials, token: token)
        }
    }

    func credentialsInvalidated() {
        if let delegate = self.pushKitEventDelegate {
            delegate.credentialsInvalidated()
        }
    }
    
    func incomingPushReceived(payload: PKPushPayload) {
        if let delegate = self.pushKitEventDelegate {
            delegate.incomingPushReceived(payload: payload)
        }
    }
    
    func incomingPushReceived(payload: PKPushPayload, completion: @escaping () -> Void) {
        //::self.gotoIncomingCallScreen()
        
        if let delegate = self.pushKitEventDelegate {
            delegate.incomingPushReceived(payload: payload, completion: completion)
        }
    }
    
    private func gotoIncomingCallScreen() {
        if let topVC = self.topMostUIController() as? UINavigationController {
            topVC.pushViewController(incomingVC, animated: true)
        }
    }
        
}
