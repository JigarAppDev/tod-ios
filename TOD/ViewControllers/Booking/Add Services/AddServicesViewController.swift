//
//  AddServicesViewController.swift
//  TOD
//
//  Created by My Mac on 24/05/21.
//

import UIKit
import FirebaseFirestore
protocol AddServicesViewControllerDelegate {
    func didSelectService(at index: Int, service: Service)
}

class AddServicesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var viwMain: UIView!
    @IBOutlet private weak var lblAddServices: UILabel!
    @IBOutlet private weak var btnClose: UIButton!
    @IBOutlet private weak var tblServices: UITableView!
    @IBOutlet private weak var lctTableHeight: NSLayoutConstraint!
    
    // MARK: - Variables
    private var arrOfServices: [String] = []
    private var arrOfServicesName :[String] = []
    private var arrOfServiceDetails: [Service] = []
    private var defaultTableHeight: CGFloat = 80.0
    var delegate: AddServicesViewControllerDelegate?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showTabBar()
        getServicesList()
    }
    
    // MARK: - Methods
    private func setupUI() {
        setupView()
        setupTableView()
        setupTableHeight()
    }
    
    private func setupView() {
        self.viwMain.addCornerRadius(15.0)
    }
    
    private func setupTableView() {
        tblServices.delegate = self
        tblServices.dataSource = self
        tblServices.tableFooterView = UIView()
        tblServices.backgroundColor = .clear
        tblServices.isScrollEnabled = false
        tblServices.register(AddServicesCell.nib, forCellReuseIdentifier: AddServicesCell.identifier)
        tblServices.reloadData()
    }
    
    private func setupTableHeight() {
        lctTableHeight.constant = CGFloat(self.arrOfServices.count) * defaultTableHeight
    }
    
    // MARK: - API Call
    private func getServicesList() {
        showLoader()
        
        APIHandler.shared.getServicesList { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
           
            
            if let error = error {
                DLog(error.localizedDescription)
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            }
            self.arrOfServices.removeAll()
            self.arrOfServicesName.removeAll()
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    let data = document.data()
                    let service_type : String = data[ApiParameterStatics.service_type] as! String
                    let service_name : String = data[ApiParameterStatics.service_name] as! String
                    self.arrOfServices.append(service_type)
                    self.arrOfServicesName.append(service_name)
                }
                self.setupTableHeight()
                self.tblServices.reloadData()
                hideLoader()
            } else {
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: StringConstants.COULD_NOT_GET_SERVICES, withOkButtonTitle: StringConstants.OKAY)
                hideLoader()
                return
            }
            
        }
    }
    
    private func getServiceDetails(for documentID: String, indexPath: Int) {
        
        showLoader()
                                            
        APIHandler.shared.getServiceDetails(for: documentID) { [weak self] (documentSnapshot, error) in
            guard let self = self else { return  }
            
            if let error = error {
                DLog(error.localizedDescription)
                hideLoader()
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            }
        
            if let documentData = documentSnapshot?.data() {
                hideLoader()
                let service = Service(dict: documentData)
                if self.delegate != nil {
                    self.delegate?.didSelectService(at: indexPath, service: service)
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        
    }

    // MARK: - IBActions
    @IBAction func onBtnCloseAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AddServicesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tblServices.dequeueReusableCell(withIdentifier: AddServicesCell.identifier, for: indexPath) as? AddServicesCell else { return UITableViewCell() }
    
        let serviceName: String = self.arrOfServicesName[indexPath.row]
        cell.setData(serviceName: serviceName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return defaultTableHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let serviceName: String = self.arrOfServices[indexPath.row]
        self.getServiceDetails(for: serviceName, indexPath: indexPath.row)
    }
    
}
