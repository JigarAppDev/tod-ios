//
//  AppDelegate.swift
//  TOD
//
//  Created by My Mac on 21/05/21.
//

import UIKit
import PushKit
import Firebase
import GoogleMaps
import TwilioVoice
import FirebaseAuth
import CallKit
import FirebaseFirestore
import IQKeyboardManagerSwift

protocol PushKitEventDelegate: AnyObject {
    func credentialsUpdated(credentials: PKPushCredentials, token: String) -> Void
    func credentialsInvalidated() -> Void
    func incomingPushReceived(payload: PKPushPayload) -> Void
    func incomingPushReceived(payload: PKPushPayload, completion: @escaping () -> Void) -> Void
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var isNetworkAvailable = true
    var pushKitEventDelegate: PushKitEventDelegate?
    var voipRegistry = PKPushRegistry.init(queue: DispatchQueue.main)
    var lastLocation:CLLocation?
    var locationManager = CLLocationManager()
    internal var job_completion_status = ""
    internal var call_status = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupNotifications(application)
        setupBackgroundLocationFetchManager()
        setupInitialUIPrefrences()
        initializePushKit()
        initRootViewController()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        window?.endEditing(true)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        NSLog("********************* End Active Call Action Called Terminate With PARAMS ==> %@ *********************", pushParamModel.twi_params.opportunity_id)
        
        NSLog("********************* End Active Call Action Called Terminate *********************")
        
        if isCallDidConnect {
            self.job_completion_status = ApiParameterStatics.rejected
            self.call_status = ApiParameterStatics.rejected
            if let activeCall = activeCall {
                NSLog("********************* End Active Call Action Called 2 *********************")
                
                if let uuid = activeCall.uuid {
                    NSLog("********************* End Active Call Action Called 3 *********************")
                    self.updateJobAcceptanceStatus()
                    NSLog("********************* End Active Call Action Called 4 *********************")
                    self.performEndCallAction(uuid: uuid)
                    
                }
            }
        }
        
        
    }
        
    
    func performEndCallAction(uuid: UUID) {
        
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        callKitCallController.request(transaction) { error in
            if let error = error {
                NSLog("EndCallAction transaction request failed: \(error.localizedDescription).")
            } else {
                NSLog("EndCallAction transaction request successful")
            }
        }
    }
    
    // MARK: - Methods
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func initializeTabBar() {
        window = UIWindow()
        window?.makeKeyAndVisible()
        let customTabBarController: CustomTabbarViewController = CustomTabbarViewController()
        let navVC = UINavigationController(rootViewController: customTabBarController)
        window?.rootViewController = navVC
        if let viewControllers = customTabBarController.viewControllers {
            for view in viewControllers {
                if let rootNavVC = view as? UINavigationController {
                    if let bookingVC = rootNavVC.viewControllers.first as? BookingsViewController {
                        self.pushKitEventDelegate = bookingVC
                        break
                    }
                }
            }
            
        }
    }
    
    func gotoLaunchingScreen() {
        window = UIWindow()
        window?.makeKeyAndVisible()
        let lauchingVC: LaunchingViewController = LaunchingViewController.instantiate(fromAppStoryboard: .Login)
        let navVC = UINavigationController(rootViewController: lauchingVC)
        navVC.setNavigationBarHidden(false, animated: true)
        window?.rootViewController = navVC
    }
    
    func gotoLoginScreen() {
        window = UIWindow()
        window?.makeKeyAndVisible()
        let loginVC: LoginViewController = LoginViewController.instantiate(fromAppStoryboard: .Login)
        let navVC = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = navVC
    }
    
    func gotoMobileREgister() {
        window = UIWindow()
        window?.makeKeyAndVisible()
        let nextVC = VerifyMobileNumberViewController.instantiate(fromAppStoryboard: .Verification)
        let navVC = UINavigationController(rootViewController: nextVC)
        window?.rootViewController = navVC
    }
    
    func gotoAddressPage() {
        window = UIWindow()
        window?.makeKeyAndVisible()
        let nextVC = AddressPageViewController.instantiate(fromAppStoryboard: .Main)
        let navVC = UINavigationController(rootViewController: nextVC)
        window?.rootViewController = navVC
    }
    
    func gotouploadPermit() {
        window = UIWindow()
        window?.makeKeyAndVisible()
        let nextVC = UploadLicsnseViewController.instantiate(fromAppStoryboard: .Main)
        let navVC = UINavigationController(rootViewController: nextVC)
        window?.rootViewController = navVC
    }
    
    private func initRootViewController() {
        if TODDefaultsManager.shared.isOnboardingScreenShown {
            if TODDefaultsManager.shared.isUserLoggedIn {
                AppDelegate.shared.initializeTabBar()
                
            } else {
                let reOpenViewController = TODDefaultsManager.shared.reOpenViewController
                
                if (reOpenViewController == StringConstants.VERIFY_MOBILE_VIEWCONTROLLER) {
                    gotoMobileREgister()
                    return
                } else if (reOpenViewController == StringConstants.ADDRESS_PAGE_VIEWCONTROLLER) {
                    gotoAddressPage()
                    return
                } else if reOpenViewController == StringConstants.UPLOAD_VIEWCONTROLLER {
                    gotouploadPermit()
                    return
                }
                AppDelegate.shared.gotoLoginScreen()
            }
        } else {
            AppDelegate.shared.gotoLaunchingScreen()
        }
    }
    
    func initializePushKit() {
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
    }
    
    private func setupNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    private func setupBackgroundLocationFetchManager() {
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    private func setupInitialUIPrefrences() {
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        IQKeyboardManager.shared.enable = true
        
        FirebaseApp.configure()
        GMSServices.provideAPIKey(KeyConstants.GMS_SERVICES_API)
    }
    
    internal func updateOpportunity() {
        var documentData: [String: Any] = [:]
        documentData = getDocumentDataForAcceptCallButRejectedOffer(with: job_completion_status, call_status: call_status)
        DLog(documentData)
        NSLog("********************* End Active Call Action Called 8 *********************")
        APIHandler.shared.updateOpportunity(for: pushParamModel.twi_params.opportunity_id, documentData: documentData) {  (error) in
            NSLog("********************* End Active Call Action Called 9 *********************")
        }
    }
    
    internal func updateJobAcceptanceStatus() {
        let parameters: [String: Any] = [ApiParameterStatics.job_acceptance_status: ApiParameterStatics.rejected]
        let called_tradies_dict: [String: Any] = [pushParamModel.twi_call_sid: parameters]
        let documentData: [String: Any] = [ApiParameterStatics.called_tradies: called_tradies_dict]
        NSLog("********************* End Active Call Action Called 15 PARAMS = %@ *********************", pushParamModel.twi_params.opportunity_id)
        NSLog("********************* End Active Call Action Called 10 *********************")
        APIHandler.shared.updateOpportunity(for: pushParamModel.twi_params.opportunity_id, documentData: documentData) {  (error) in
            DLog(documentData)
            NSLog("********************* End Active Call Action Called 11 *********************")
            self.updateOpportunity()
        }
    }
    
    internal func getDocumentDataForAcceptCallButRejectedOffer(with job_completion_status: String, call_status: String) -> [String: Any] {
        let date = Timestamp(date: Date())
        let calledTradiesParam: [String: Any] = [ApiParameterStatics.call_finished: date,
                                                 ApiParameterStatics.job_acceptance_status: ApiParameterStatics.rejected,
                                                 ApiParameterStatics.job_acceptance_time: date,
                                                 ApiParameterStatics.tradie_email: TODDefaultsManager.shared.email,
                                                 ApiParameterStatics.tradie_name: TODDefaultsManager.shared.name,
                                                 ApiParameterStatics.tradie_phone_number: TODDefaultsManager.shared.mobileNumber]
        
        let called_tradies_dict: [String: Any] = [pushParamModel.twi_call_sid: calledTradiesParam]
        
        let parameters: [String: Any] = [ApiParameterStatics.call_ended_time: date,
                                         ApiParameterStatics.call_status: call_status,
                                         ApiParameterStatics.job_completion_status: job_completion_status,
                                         ApiParameterStatics.called_tradies: called_tradies_dict,
                                         ApiParameterStatics.job_scheduled_time: date]
        
        return parameters
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let firebaseAuth = Auth.auth()
        DLog(deviceToken.hexString)
        firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()
        if (firebaseAuth.canHandleNotification(userInfo)) {
            print(userInfo)
            return
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        DLog(response.notification.request.content.userInfo)
    }
    
}

// MARK: PKPushRegistryDelegate
extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print("pushRegistry:didUpdatePushCredentials:forType:")
        DLog(credentials.token.hexString)
        if let delegate = self.pushKitEventDelegate {
            if TODDefaultsManager.shared.isUserLoggedIn {
                if TODDefaultsManager.shared.accessToken != " " {
                    // Second time user
                    delegate.credentialsUpdated(credentials: credentials, token: TODDefaultsManager.shared.accessToken)
                } else {
                    // First time user
                    /*let userID: String = TODDefaultsManager.shared.userID
                     fetchAccessToken(for: userID) { (token) in
                     guard let token = token else { return }
                     delegate.credentialsUpdated(credentials: credentials, token: token)
                     }*/
                    fetchAccessTokenFromCloudFunction { [weak self] (httpScallableResult, error) in
                        guard let self = self else { return }
                        print(self)
                        if let httpScallableResult = httpScallableResult {
                            if let data = httpScallableResult.data as? [String: Any] {
                                let generateAccessTokenParam: GenerateAccessTokenParam = GenerateAccessTokenParam(data: data)
                                delegate.credentialsUpdated(credentials: credentials, token: generateAccessTokenParam.access_token_ios)
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("pushRegistry:didInvalidatePushTokenForType:")
        if let delegate = self.pushKitEventDelegate {
            delegate.credentialsInvalidated()
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("pushRegistry:didReceiveIncomingPushWithPayload:forType:")
        if let delegate = self.pushKitEventDelegate {
            delegate.incomingPushReceived(payload: payload)
        }
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("pushRegistry:didReceiveIncomingPushWithPayload:forType:completion:")
        
        print(payload.dictionaryPayload)
        
        let model:VoipPushParam = VoipPushParam(data: payload.dictionaryPayload)
        pushParamModel = model
        
        isCallDidConnect = false
        
        if let delegate = self.pushKitEventDelegate {
            if TODDefaultsManager.shared.isUserLoggedIn {
                delegate.incomingPushReceived(payload: payload, completion: completion)
            }
        }
        
        if let version = Float(UIDevice.current.systemVersion), version >= 13.0 {
            completion()
        }
        
    }
    
}

// MARK: - CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if UIApplication.shared.applicationState == .active {
        } else {
            
            let location = locations.last
            lastLocation = location
            let lati :Double = Double(lastLocation?.coordinate.latitude ?? 0.0)
            let long : Double = Double(lastLocation?.coordinate.longitude ?? 0.0)
            getAddressFromLatLong(latitude: lati, withLongitude: long)
        }
    }
    
    func getAddressFromLatLong(latitude: Double, withLongitude longitude: Double) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude , longitude: longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0  {
                let placemark = placemarks[0]
                DispatchQueue.main.async {
                    if let zipCode = placemark.postalCode {
                        if TODDefaultsManager.shared.isUserLoggedIn == true {
                            let lati :Double = Double(location.coordinate.latitude)
                            let long : Double = Double(location.coordinate.longitude)
                            let last_location_maps: GeoPoint = GeoPoint(latitude: lati, longitude: long)
                            let pinCode = Int(zipCode) ?? 0
                            
                            self.checkStatus(pinCode: pinCode, last_location_maps: last_location_maps)
                        }
                    }
                }
            }
        })
    }
    
    private func checkStatus(pinCode: Int, last_location_maps: GeoPoint) {
        let getSwitchSatus = TODDefaultsManager.shared.getSwitchStatus()
        let userID = TODDefaultsManager.shared.userID
        let last_status_updated: Timestamp = Timestamp(date: Date())
        if getSwitchSatus.count > 0 {
            getSwitchSatus.forEach { (key, value)  in
                if (value) {
                    APIHandler.shared.updateActiveTradiesLocation(userID: userID, serviceName: key, data: [/*ApiParameterStatics.available_pincodes : [],*/
                                                                    ApiParameterStatics.last_location_maps : last_location_maps,
                                                                    ApiParameterStatics.last_location_updated_on:last_status_updated,
                                                                    ApiParameterStatics.last_pincode : pinCode]) { (error) in
                        if error == nil {
                            TODDefaultsManager.shared.pinCode = String(pinCode)
                            TODDefaultsManager.shared.latitude = "\(self.lastLocation?.coordinate.latitude ?? 0.0)"
                            TODDefaultsManager.shared.longitude = "\(self.lastLocation?.coordinate.longitude ?? 0.0)"
                        }
                    }
                }
            }
        }
    }
    
}
