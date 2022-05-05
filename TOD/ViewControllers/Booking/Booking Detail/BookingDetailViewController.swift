//
//  BookingDetailViewController.swift
//  TOD
//
//  Created by My Mac on 22/05/21.
//

import UIKit
import Alamofire
import FirebaseFirestore

protocol BookingDetailViewControllerDelegate {
    func didPressedCallButton(with phoneNumber: String)
}

class BookingDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var btnClose: UIButton!
    @IBOutlet private weak var viwMain: UIView!
    @IBOutlet private weak var viwBookingProfile: UIView!
    @IBOutlet private weak var imgBookingProfile: UIImageView!
    @IBOutlet private weak var lblPlumbing: UILabel!
    @IBOutlet private weak var btnCall: UIButton!
    @IBOutlet private weak var btnDone: UIButton!
    @IBOutlet weak var lblJobID: UILabel!
    @IBOutlet weak var lblData: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSatus: UILabel!
    
    // MARK: - Variables
    var delegate: BookingDetailViewControllerDelegate?
    var strJobid = ""
    var arrDetailsOfJobs : BookingModel?
    var isDoneButtton = false
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Methods
    private func setupUI() {
        setupButton()
        setupView()
        setupImageView()
        setupData()
    }
    
    private func setupView() {
        self.viwMain.addCornerRadius(15.0)
        self.viwBookingProfile.addCornerRadius(self.viwBookingProfile.frame.height / 2.0)
    }
    
    private func setupButton() {
        self.btnDone.addCornerRadius(10.0)
        self.btnDone.applyBorder(1.0, borderColor: AppColor.APP_THEME_COLOR)
        self.btnCall.addCornerRadius(10.0)
        self.btnDone.isHidden = isDoneButtton
    }
    
    private func setupImageView() {
        self.imgBookingProfile.addCornerRadius(self.imgBookingProfile.frame.height / 2.0)
    }
    
    private func setupData() {
        let dateFormat = BOOKING_DETAIL_SCREEN_DATE_FORMAT
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let timeFormat = BOOKING_DETAIL_SCREEN_TIME_FORMAT
        let timeFormatter = DateFormatter()
        timeFormatter.amSymbol = ApiParameterStatics.am_symbol
        timeFormatter.pmSymbol = ApiParameterStatics.pm_symbol
        timeFormatter.dateFormat = timeFormat
        self.lblData.text = dateFormatter.string(from: self.arrDetailsOfJobs?.job_scheduled_time ?? Date())
        self.lblPlumbing.text = self.arrDetailsOfJobs?.requested_service
        self.lblSatus.text = self.arrDetailsOfJobs?.job_completion_status
        self.lblJobID.text = self.arrDetailsOfJobs?.jobId
        self.lblTime.text = timeFormatter.string(from: self.arrDetailsOfJobs?.job_scheduled_time ?? Date())
    }
    
    private func updateJobStatus() {
        showLoader()
        APIHandler.shared.updateJobStatus(jobId: self.arrDetailsOfJobs?.jobId ?? "", data: [ApiParameterStatics.job_completion_status : "\(ApiParameterStatics.completed)"], completion: { [weak self] (error) in
            
            guard let self = self else { return }
            hideLoader()
            if error != nil {
                Utility.showMessageAlert(title: Bundle.appName(), andMessage: error!.localizedDescription, withOkButtonTitle: StringConstants.OKAY)
                return
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
        })
        
    }
    
    // MARK: - IBActions
    @IBAction func onBtnDoneAction(_ sender: UIButton) {
        updateJobStatus()
    }
    
    @IBAction func onBtnCallAction(_ sender: UIButton) {
        if self.delegate != nil {
            self.delegate?.didPressedCallButton(with: "Testing Number")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onBtnCloseAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
