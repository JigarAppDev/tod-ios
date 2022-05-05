//
//  MyServicesViewController.swift
//  TOD
//
//  Created by My Mac on 24/05/21.
//

import UIKit
import FirebaseFirestore
import CoreLocation

class MyServicesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var viwTable: UIView!
    @IBOutlet private weak var tblServices: UITableView!
    @IBOutlet private weak var viwNavigation: UIView!
    @IBOutlet private weak var lblMyServices: UILabel!
    @IBOutlet private weak var btnBack: UIButton!
    @IBOutlet private weak var btnAdd: UIButton!
    @IBOutlet private weak var lblNoServicesAvailable: UILabel!
    
    // MARK: - Variables
    private var arrOfService: [Service] = []
    private var tempArray: [String] = []
    private var switchStatus : [String : Bool] = [:]
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
        checkService()
    }
    
    // MARK: - Methods
    private func setupUI() {
        setupView()
        setupButton()
        setupTableView()
    }
    
    private func setupView() {
        DispatchQueue.main.async {
            self.viwTable.roundCorners([.topLeft, .topRight], radius: 20.0)
        }
    }
    
    private func setupButton() {
        self.btnAdd.addCornerRadius(self.btnAdd.frame.size.height / 2.0)
        self.btnAdd.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
    }
    
    private func setupTableView() {
        tblServices.delegate = self
        tblServices.dataSource = self
        tblServices.tableFooterView = UIView()
        tblServices.backgroundColor = .clear
        tblServices.register(MyServicesCell.nib, forCellReuseIdentifier: MyServicesCell.identifier)
    }
    
    private func getDocumentData(withService: Service, with activeStatus: Bool) -> [String: Any] {
        
        let service_code: Int = withService.service_code
        let service_option_code: Int = withService.service_option_code
        let service_type: String = withService.service_type
        let sp_id: String = TODDefaultsManager.shared.userID
        
        let last_status_updated: Timestamp = Timestamp(date: Date())
        
        let last_pincode: Int = Int(TODDefaultsManager.shared.pinCode) ?? 0
        
        guard let latitude: Double = Double("\(TODDefaultsManager.shared.latitude)") else { return [:] }
        guard let longitude: Double = Double("\(TODDefaultsManager.shared.longitude)") else { return [:] }
        let last_location_maps: GeoPoint = GeoPoint(latitude: latitude, longitude: longitude)
        var available_pincodes: [Int] = []
        
        let isContains = available_pincodes.filter { (pincode) -> Bool in
            if pincode == last_pincode {
                return true
            }
            return false
        }
        
        if isContains.count == 0 {
            available_pincodes.insert(last_pincode, at: available_pincodes.count)
        }
        
        
        let activeTradiesParam: ActiveTradiesParam = ActiveTradiesParam(available_pincodes: available_pincodes,
                                                                        last_location_maps: last_location_maps,
                                                                        last_location_updated_on: last_status_updated,
                                                                        last_pincode: last_pincode,
                                                                        last_status_updated: last_status_updated,
                                                                        service_code: service_code,
                                                                        service_option_code: service_option_code,
                                                                        service_type: service_type,
                                                                        sp_id: sp_id,
                                                                        status: activeStatus,
                                                                        twilio_client_id: sp_id)
        
        return activeTradiesParam.dbParamRequest
    }
    
    // MARK: - API Call
    private func checkService() {
        showLoader()
        
        let userID = TODDefaultsManager.shared.userID
        self.tempArray.removeAll()
        self.arrOfService.removeAll()
        
        APIHandler.shared.getTradiesService(userID: userID, completion:  { [weak self] (response, error) in
            guard let self = self else { return }
            hideLoader()
            if let response = response {
                if response.keys.count > 0 {
                    self.lblNoServicesAvailable.isHidden = true
                    self.tblServices.isHidden = false
                    for key in response.keys {
                        self.tempArray.append(key)
                        self.getServiceDetails(for: key)
                    }
                } else {
                   
                    self.lblNoServicesAvailable.isHidden = false
                    self.tblServices.isHidden = true
                }
            } else {
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: "\(error?.localizedDescription ?? "")", withOkButtonTitle: StringConstants.OKAY)
                return
            }
        })
    }
    
    private func getServiceDetails(for documentID: String) {
        
        APIHandler.shared.getServiceDetails(for: documentID) { [weak self] (documentSnapshot, error) in
            guard let self = self else { return  }
            
            if let error = error {
                DLog(error.localizedDescription)
                hideLoader()
                if error._code != 14 {
                    Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                }
                return
            }
            
            if let documentData = documentSnapshot?.data() {
                let service = Service(dict: documentData)
                self.arrOfService.append(service)
                self.getActiveTradies()
                
            }
            
        }
    }
    
    
    private func getActiveTradies() {
        
        APIHandler.shared.getActiveTradiesServic { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                hideLoader()
                if error._code != 14 {
                    Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                }
                return
            }
            
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    let documentID: String = document.documentID
                    let userID: String = TODDefaultsManager.shared.userID
                    self.getActiveTradiesForServiceName(for: documentID, userID: userID)
                }
            } else {
                self.tblServices.reloadData()
            }
           
        }
        //self.tblServices.reloadData()
    }
  
    private func getActiveTradiesForServiceName(for documentID: String, userID: String) {
        
        APIHandler.shared.getActiveTradiesServices(for: documentID, userID: userID) { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                hideLoader()
                if error._code != 14 {
                    Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.tblServices.reloadData()
            }
            
            if let documentData = documentSnapshot?.data() {
                let activeTradies = ActiveTradiesParam(data: documentData)
                if let modelIndex = self.arrOfService.firstIndex(where: { $0.service_type == documentID }) {
                    let objectAtIndex = self.arrOfService[modelIndex]
                    let newObject = objectAtIndex.with(activeStatus: activeTradies.status)
                    self.switchStatus[newObject.service_type] = newObject.status
                    self.tblServices.reloadData()
                    self.arrOfService[modelIndex] = newObject
                    hideLoader()
                }
            }
            TODDefaultsManager.shared.setSwitchStatus(checkStatusButton: self.switchStatus)
            if self.tempArray.count == self.arrOfService.count {
                //
                let sortedArray = self.arrOfService.sorted { $0.service_type.localizedCaseInsensitiveCompare($1.service_type) == ComparisonResult.orderedAscending }
                self.arrOfService = sortedArray
               
            }
            
        }
    }
    
    private func updateActiveTradiesDetailsForService(atIndex: Int, with activeStatus: Bool) {
        self.switchStatus.removeAll()
        
        if self.arrOfService.count > atIndex {
            let service: Service = self.arrOfService[atIndex]
            let documentID: String = service.service_type
            let userID: String = TODDefaultsManager.shared.userID
            self.switchStatus = TODDefaultsManager.shared.getSwitchStatus()
            let documentData: [String: Any] = self.getDocumentData(withService: service, with: activeStatus)
            self.switchStatus[service.service_type] = activeStatus
            TODDefaultsManager.shared.setSwitchStatus(checkStatusButton: self.switchStatus)
            
            APIHandler.shared.updateActiveTradiesServices(forDocumentID: service.service_type, forUserID: userID, with: documentData) { [weak self] (error) in
                guard let self = self else { return }
                
                if let error = error {
                    hideLoader()
                    if error._code != 14 {
                        Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                    }
                    return
                } else {
                    let objectAtIndex = self.arrOfService[atIndex]
                    let newObject = objectAtIndex.with(activeStatus: activeStatus)
                    self.arrOfService[atIndex] = newObject
                    let indexpath = IndexPath(row: atIndex, section: 0)
                    self.tblServices.reloadRows(at: [indexpath], with: .automatic)
                    hideLoader()
                }
                
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func onBtnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnAddAction(_ sender: UIButton) {
        let nextVC = AddServicesViewController.instantiate(fromAppStoryboard: .Bookings)
        nextVC.delegate = self
        self.presentPanModal(nextVC)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MyServicesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfService.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tblServices.dequeueReusableCell(withIdentifier: MyServicesCell.identifier, for: indexPath) as? MyServicesCell else { return UITableViewCell() }
        if arrOfService.count > indexPath.row {
            cell.cellDelegate = self
            let service: Service = self.arrOfService[indexPath.row]
            cell.setData(service: service, tag: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

// MARK: - AddServicesViewControllerDelegate
extension MyServicesViewController: AddServicesViewControllerDelegate {
    
    func didSelectService(at index: Int, service: Service) {
        
        let filteredArray = self.arrOfService.filter { $0.service_type == service.service_type }
        if filteredArray.count > 0 {
            Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.ALREADY_LISTED_IN_SERVICES, withOkButtonTitle: StringConstants.OKAY)
            return
        } else {
            let nextVC = UploadPermitViewController.instantiate(fromAppStoryboard: .Bookings)
            nextVC.selectedService = service
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
}

// MARK: - MyServicesCellDelegate
extension MyServicesViewController: MyServicesCellDelegate {
    
    func switchStateChanged(_ mjSwitch: MJMaterialSwitch) {
        print(mjSwitch.isOn, mjSwitch.tag, "Medium")
        if mjSwitch.isOn == true {
            print("Switch On")
        } else {
            print("Switch Off")
        }
        
        self.updateActiveTradiesDetailsForService(atIndex: mjSwitch.tag, with: mjSwitch.isOn)
    }
    
    
}
