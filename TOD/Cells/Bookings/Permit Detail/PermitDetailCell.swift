//
//  PermitDetailCell.swift
//  TOD
//
//  Created by My Mac on 02/06/21.
//

import UIKit

class PermitDetailCell: UITableViewCell {

    // MARK: - Variables
    
    // MARK: - IBOutlets
    @IBOutlet weak var viwMain: UIView!
    @IBOutlet weak var viwDot: UIView!
    @IBOutlet weak var lblPermitDescription: UILabel!
    
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
    
    
    // MARK: - Methods
    private func setupUI() {
        setupView()
    }
    
    private func setupView() {
        viwDot.addCornerRadius(2.0)
    }
    
    public func setData(for permit: Permit) {
        self.lblPermitDescription.text = "\(permit.permit_name) : \(permit.permit_description)"
    }
    
    
}
