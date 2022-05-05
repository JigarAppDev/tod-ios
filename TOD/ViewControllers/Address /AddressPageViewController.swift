//
//  AddressPageViewController.swift
//  TOD
//
//  Created by iMac on 24/05/21.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseFirestore
class AddressPageViewController: UIViewController {
    
    //MARK:- IbOutlet
    @IBOutlet weak var locationPinMarkerImage: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var yourNameTextField: TextFieldWithPadding!
    @IBOutlet weak var businessNameTextField: TextFieldWithPadding!
    @IBOutlet weak var abnNameTextField: TextFieldWithPadding!
    @IBOutlet weak var officeDoorNameTextField: TextFieldWithPadding!
    @IBOutlet weak var streetAddressTextField: TextFieldWithPadding!
    @IBOutlet weak var cityTextField: TextFieldWithPadding!
    @IBOutlet weak var stateAddressTextField: TextFieldWithPadding!
    @IBOutlet weak var pinCodeAddressTextField: TextFieldWithPadding!
    @IBOutlet weak var countryAddressTextField: TextFieldWithPadding!
    @IBOutlet weak var saveBusinessDetailsButton: UIButton!
    @IBOutlet weak var yourNameAlretButton: UIButton!
    @IBOutlet weak var businessNameAlretButton: UIButton!
    @IBOutlet weak var abnNumberAlretButton: UIButton!
    @IBOutlet weak var officeDoorNumberAlertButton: UIButton!
    @IBOutlet weak var streetAddressAlertButton: UIButton!
    @IBOutlet weak var cityAlretButton: UIButton!
    @IBOutlet weak var stateAlertButton: UIButton!
    @IBOutlet weak var countryAlertButton: UIButton!
    @IBOutlet weak var pincodeAlertButton: UIButton!
    //MARK:- Variable Declaration
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation : CLLocation?
    var validation = Validation()
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Step 6.
        mapView.clear()
    }
    
    //MARK:- Function
    
    private func setupUI() {
        googleMapDelegate()
        setUpTextFiled()
        setUpView()
        setUpButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setUpView() {
        self.view.backgroundColor = AppColor.APP_THEME_COLOR
        TODDefaultsManager.shared.reOpenViewController = "AddressPageViewController"
    }
    
    private func googleMapDelegate() {
        locationManager.delegate = self
        
        GoogleMapsHelper.initLocationManager(locationManager, delegate: self)
        GoogleMapsHelper.createMap(on: mapView, locationManager: locationManager, mapView: mapView)
        
        self.mapView.delegate = self
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: currentLocation?.coordinate.latitude ?? 0.0, longitude:currentLocation?.coordinate.longitude ?? 0.0)
        marker.title = "Lokaci Pvt. Ltd."
        marker.snippet = "Sec 132 Noida India"
        marker.map = self.mapView
        DispatchQueue.main.async {
            self.mapView.isMyLocationEnabled = true
            self.mapView.bringSubviewToFront(self.locationPinMarkerImage)
        }
    }
    
    private func setUpTextFiled() {
        self.yourNameTextField.cornerRadius = 12
        self.businessNameTextField.cornerRadius = 12
        self.abnNameTextField.cornerRadius = 12
        self.officeDoorNameTextField.cornerRadius = 12
        self.streetAddressTextField.cornerRadius = 12
        self.cityTextField.cornerRadius = 12
        self.stateAddressTextField.cornerRadius = 12
        self.pinCodeAddressTextField.cornerRadius = 12
        self.countryAddressTextField.cornerRadius = 12
        self.yourNameTextField.delegate = self
        self.businessNameTextField.delegate = self
        self.cityTextField.delegate = self
        self.stateAddressTextField.delegate = self
        self.countryAddressTextField.delegate = self
        self.abnNameTextField.delegate = self
        self.officeDoorNameTextField.delegate = self
        self.streetAddressTextField.delegate = self
        self.pinCodeAddressTextField.delegate = self
    }
    
    private func setUpButton() {
        self.saveBusinessDetailsButton.backgroundColor = AppColor.APP_THEME_COLOR
        self.saveBusinessDetailsButton.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
        checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: true, state: true, country: true, pincode: true)
    }
    
    private func setupValidation() -> Bool {
        if self.yourNameTextField.text?.isEmpty ?? false &&
            self.businessNameTextField.text?.isEmpty ?? false &&
            self.abnNameTextField.text?.isEmpty  ?? false &&
            self.officeDoorNameTextField.text?.isEmpty ?? false &&
            self.streetAddressTextField.text?.isEmpty ?? false &&
            self.cityTextField.text?.isEmpty ?? false &&
            self.stateAddressTextField.text?.isEmpty ?? false &&
            self.pinCodeAddressTextField.text?.isEmpty ?? false &&
            self.countryAddressTextField.text?.isEmpty ?? false {
            
            checkAlretTextField(yourName: false, businessName: false, abnNumber: false, officeDoorNumber: false, streetAddress: false, city: false, state: false, country: false, pincode: false)
            return false
            
        }
        else if let name = self.yourNameTextField.text, name.isEmpty {
            checkAlretTextField(yourName: false, businessName: false, abnNumber: false, officeDoorNumber: false, streetAddress: false, city: false, state: false, country: false, pincode: false)
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.NAME_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if let businessName = self.businessNameTextField.text, businessName.isEmpty {
            checkAlretTextField(yourName: true,businessName: false, abnNumber: false, officeDoorNumber: false, streetAddress: false, city: false, state: false, country: false, pincode: false)
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.BUSINESS_NAME_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if let abn = self.abnNameTextField.text, abn.isEmpty {
            checkAlretTextField(yourName: true, businessName: true, abnNumber: false, officeDoorNumber: false, streetAddress: false, city: false, state: false, country: false, pincode: false)
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.ABN_NUMBER_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if let ofcDoorName = self.officeDoorNameTextField.text, ofcDoorName.isEmpty {
            checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: false, streetAddress: false, city: false, state: false, country: false, pincode: false)
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.OFFICE_DOOR_NUMBER_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if let streetAddress = self.streetAddressTextField.text, streetAddress.isEmpty {
            checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: false, city: false, state: false, country: false, pincode: false)
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.STREET_ADDRESS_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if let city = self.cityTextField.text, city.isEmpty {
            checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: false, state: false, country: false, pincode: false)
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.CITY_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if let stateAddress = self.stateAddressTextField.text, stateAddress.isEmpty {
            checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: true, state: false, country: false, pincode: false)
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.STATE_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if let pincode = self.pinCodeAddressTextField.text, pincode.isEmpty {
            checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: true, state: true, country: false, pincode: true)
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PINCODE_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else if let country = self.countryAddressTextField.text, country.isEmpty {
            checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: true, state: true, country: false,pincode: true)
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.COUNTRY_FIELD_EMPTY, withOkButtonTitle: StringConstants.OKAY)
            return false
        } else {
            checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: true, state: true, country: true, pincode: true)
            return true
        }
        
    }
    
    
    private func getDocumentData() -> [String: Any] {
        guard let displayName = self.yourNameTextField.text else { return [:] }
        guard let abn_number_value = self.abnNameTextField.text else { return [:] }
        guard let city = self.cityTextField.text else { return [:] }
        guard let country = self.countryAddressTextField.text else { return [:] }
        guard let doorNumber = self.officeDoorNameTextField.text else { return [:] }
        guard let pincode = self.pinCodeAddressTextField.text else { return [:] }
        guard let street = self.streetAddressTextField.text else { return [:] }
        guard let state = self.stateAddressTextField.text else {return [:] }
        guard let business_name = self.businessNameTextField.text else {return [:] }
        
        let mobile:String = TODDefaultsManager.shared.mobileNumber
        let email: String = TODDefaultsManager.shared.email
        let createdAt: Timestamp = Timestamp(date: Date())
        let completeAddress: String = "\(doorNumber), \(street), \(city), \(state), \(pincode), \(country)"
        
        let abn_number: ABNNumber = ABNNumber(isUploaded: false,
                                              value: abn_number_value)
        let user_dl: UserDL = UserDL(isUploaded: false,
                                     value: "")
        let address: Address = Address(city: city,
                                       country: country,
                                       doorNumber: doorNumber,
                                       completeAddress: completeAddress,
                                       isUploaded: true,
                                       pincode: pincode,
                                       street: street,
                                       state: state)
        let tradiesProdfileParam: TradiesProfileParam = TradiesProfileParam(abn_number: abn_number,
                                                                            user_dl: user_dl,
                                                                            address: address,
                                                                            createdAt: createdAt,
                                                                            displayName: displayName,
                                                                            email: email,
                                                                            verified: true,
                                                                            imageUrl: "",
                                                                            phoneNumber: mobile,
                                                                            buisness_name: business_name)
        
        return tradiesProdfileParam.dbParamRequest
    }
    
    
    private func checkAlretTextField(yourName:Bool,
                                     businessName:Bool,
                                     abnNumber:Bool,
                                     officeDoorNumber:Bool,
                                     streetAddress:Bool,
                                     city:Bool,
                                     state:Bool,
                                     country:Bool,
                                     pincode:Bool) {
        self.yourNameAlretButton.isHidden = yourName
        self.businessNameAlretButton.isHidden = businessName
        self.abnNumberAlretButton.isHidden = abnNumber
        self.officeDoorNumberAlertButton.isHidden = officeDoorNumber
        self.streetAddressAlertButton.isHidden = streetAddress
        self.cityAlretButton.isHidden = city
        self.stateAlertButton.isHidden = state
        self.countryAlertButton.isHidden = country
        self.pincodeAlertButton.isHidden = pincode
        
    }
    
    private func validationTextField() {
        
        if  self.yourNameTextField.text != nil && (self.yourNameTextField.text?.count ?? 0 >= 3) && (self.yourNameTextField.text?.count ?? 0 <= 32){
            if  self.businessNameTextField.text != nil && (self.businessNameTextField.text?.count ?? 0 >= 3) && (self.businessNameTextField.text?.count ?? 0 <= 32){
                if self.cityTextField.text != nil && (self.cityTextField.text?.count ?? 0 >= 3) && (self.cityTextField.text?.count ?? 0 <= 32) {
                    if  self.stateAddressTextField.text != nil && (self.stateAddressTextField.text?.count ?? 0 >= 3) && (self.stateAddressTextField.text?.count ?? 0 <= 32) {
                        if  self.countryAddressTextField.text != nil && (self.countryAddressTextField.text?.count ?? 0 >= 3) && (self.countryAddressTextField.text?.count ?? 0 <= 32) {
                            checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: true, state: true, country: true, pincode: true)
                            callTradiesProfileAPI()
                        } else {
                            checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: true, state: true, country: false, pincode: true)
                            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PLEASE_ENTER_ONLY_CHARACTER_COUNTRY, withOkButtonTitle: StringConstants.OKAY)
                        }
                    } else {
                        checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: true, state: false, country: true, pincode: true)
                        Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PLEASE_ENTER_ONLY_CHARACTER_STATE, withOkButtonTitle: StringConstants.OKAY)
                    }
                } else {
                    checkAlretTextField(yourName: true, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: false, state: true, country: true, pincode: true)
                    Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PLEASE_ENTER_ONLY_CHARACTER_CITY, withOkButtonTitle: StringConstants.OKAY)
                }
            } else {
                checkAlretTextField(yourName: true, businessName: false, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: true, state: true, country: true, pincode: true)
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PLEASE_ENTER_ONLY_CHARACTER_BUSINESS_NAME, withOkButtonTitle: StringConstants.OKAY)
                
            }
        } else {
            checkAlretTextField(yourName: false, businessName: true, abnNumber: true, officeDoorNumber: true, streetAddress: true, city: true, state: true, country: true, pincode: true)
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.PLEASE_ENTER_ONLY_CHARACTER_YOUR_NAME, withOkButtonTitle: StringConstants.OKAY)
        }
    }
    // MARK: - API Call
    private func callTradiesProfileAPI() {
        showLoader()
        DLog(getDocumentData())
        APIHandler.shared.addUserProfileDetails(for: TODDefaultsManager.shared.userID, documentData: getDocumentData()) { [weak self] error in
            
            guard let self = self else { return }
            hideLoader()
            if let error = error {
                DLog(error.localizedDescription)
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
            } else {
                TODDefaultsManager.shared.address = "Done"
                let nextVC = UploadLicsnseViewController.instantiate(fromAppStoryboard: .Main)
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            
        }
    }
    
    
    //MARK:- IbButton Action
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func saveBusinessDetailsButtonAction(_ sender: Any) {
        if setupValidation() {
            self.validationTextField()
            
            
        }
    }
    
}

//MARK:- CLLocationManagerDelegate,GMSMapViewDelegate Of Google Map
extension AddressPageViewController : CLLocationManagerDelegate ,GMSMapViewDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Step 7.
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        self.mapView?.animate(to: camera)
        currentLocation = locations.last
        
        TODDefaultsManager.shared.latitude = "\(location?.coordinate.latitude ?? 0)"
        TODDefaultsManager.shared.longitude = "\(location?.coordinate.longitude ?? 0)"
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        GoogleMapsHelper.didUpdateLocations(locations, locationManager: self.locationManager, mapView: self.mapView)
        self.locationManager.stopUpdatingLocation()
    }
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Step 8.
        GoogleMapsHelper.handle(manager, didChangeAuthorization: status)
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
}

//MARK:- UITextFieldDelegate
extension AddressPageViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == yourNameTextField {
          
            if string.count > 0 {
                self.yourNameAlretButton.isHidden = true
            }
            let invalidCharacters = CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ ")
            return string.rangeOfCharacter(from: invalidCharacters.inverted) == nil
        } else if textField == businessNameTextField {
            
            
            if string.count > 0 {
                self.businessNameAlretButton.isHidden = true
            }
            let invalidCharacters = CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ ")
            return string.rangeOfCharacter(from: invalidCharacters.inverted) == nil
        } else if textField == abnNameTextField {
            if string.count > 0 {
                self.abnNumberAlretButton.isHidden = true
            }
        } else if textField == officeDoorNameTextField {
            if string.count > 0 {
                self.officeDoorNumberAlertButton.isHidden = true
            }
        } else if textField == streetAddressTextField {
            if string.count > 0 {
                self.streetAddressAlertButton.isHidden = true
            }
        } else if textField == cityTextField {
          
            
            if string.count > 0 {
                self.cityAlretButton.isHidden = true
            }
            let invalidCharacters = CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ ")
            return string.rangeOfCharacter(from: invalidCharacters.inverted) == nil
        } else if textField == stateAddressTextField {
           
            if string.count > 0 {
                self.stateAlertButton.isHidden = true
            }
            let invalidCharacters = CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ ")
            return string.rangeOfCharacter(from: invalidCharacters.inverted) == nil
        } else if textField == pinCodeAddressTextField {
            if string.count > 0 {
                self.pincodeAlertButton.isHidden = true
            }
        } else if textField == countryAddressTextField {
            
            if string.count > 0 {
                self.countryAlertButton.isHidden = true
            }
            let invalidCharacters = CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ ")
            return string.rangeOfCharacter(from: invalidCharacters.inverted) == nil
        }
        
       return true
    }
    
    
    
   
}
