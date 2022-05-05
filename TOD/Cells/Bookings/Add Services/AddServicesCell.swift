//
//  AddServicesCell.swift
//  TOD
//
//  Created by My Mac on 24/05/21.
//

import UIKit

class AddServicesCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var viwMain: UIView!
    @IBOutlet weak var lblServicesName: UILabel!
    @IBOutlet weak var viwAdd: UIView!
    @IBOutlet weak var btnAdd: UIButton!
    
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
    
    // MARK: - Methods
    private func setupUI() {
        setupView()
    }
    
    private func setupView() {
        viwMain.addCornerRadius(16.0)
        viwMain.clipsToBounds = true
        viwMain.applyBorder(1.0, borderColor: AppColor.OPTION_GRAY_COLOR.withAlphaComponent(0.8))
    }
    
    public func setData(serviceName: String) {
       
        self.lblServicesName.text = serviceName.capitalized(with: NSLocale.current)
    
}
}
