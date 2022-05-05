//
//  BookingsDetailCell.swift
//  TOD
//
//  Created by My Mac on 22/05/21.
//

import UIKit

class BookingsDetailCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var viwMain: UIView!
    @IBOutlet weak var imgBooking: UIImageView!
    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var lblPIN: UILabel!
    @IBOutlet weak var lblPinNumber: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lctScheduledTimeHeight: NSLayoutConstraint!
    @IBOutlet weak var lctScheduledTimeBottom: NSLayoutConstraint!
    
    // MARK: - Variables
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func setupUI() {
        setupView()
        setupImageView()
    }
    
    private func setupView() {
        viwMain.addCornerRadius(16.0)
        viwMain.clipsToBounds = true
        viwMain.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
    }
    
    private func setupImageView() {
        imgBooking.addCornerRadius(imgBooking.frame.size.height / 2)
        imgBooking.clipsToBounds = true
    }
    
    func setupData(data:BookingModel, selectedTab: Int) {
        var dateFormat = ""
        
        if selectedTab == 1 {
            dateFormat = SCHEDULED_TAB_DATE_FORMAT
            self.lctScheduledTimeHeight.constant = 20.0
            self.lctScheduledTimeBottom.constant = 2.0
        } else {
            dateFormat = OPEN_COMPLETED_TAB_DATE_FORMAT
            self.lctScheduledTimeHeight.constant = 0.0
            self.lctScheduledTimeBottom.constant = 0.0
        }
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.amSymbol = ApiParameterStatics.am_symbol
        dateFormatter.pmSymbol = ApiParameterStatics.pm_symbol
        self.lblDateTime.text = dateFormatter.string(from: data.job_scheduled_time)
        self.lblServiceName.text = data.requested_service
        self.lblPinNumber.text = data.jobLocationPincode
    }
    
}
