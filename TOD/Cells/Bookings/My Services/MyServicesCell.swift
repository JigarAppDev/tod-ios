//
//  MyServicesCell.swift
//  TOD
//
//  Created by My Mac on 24/05/21.
//

import UIKit

protocol MyServicesCellDelegate {
    func switchStateChanged(_ mjSwitch: MJMaterialSwitch)
}

class MyServicesCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var viwMain: UIView!
    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var viwSwitch: UIView!
    
    // MARK: - Variables
    var cellDelegate: MyServicesCellDelegate?
    var androidSwitchMedium = MJMaterialSwitch()
    
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
        viwMain.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
    }
    
    private func setupSwitch(with status: Bool, tag: Int) {
        androidSwitchMedium =  MJMaterialSwitch(withSize: .normal, style: MJMaterialSwitchStyle.medium, state: status ? .on : .off )
        androidSwitchMedium.isBounceEnabled = false
        androidSwitchMedium.isRippleEnabled = true
        androidSwitchMedium.tag = tag
        
        let width: CGFloat = viwSwitch.frame.size.width
        let height: CGFloat = viwSwitch.frame.size.height
        
        androidSwitchMedium.frame = CGRect(x: 0, y: 0, width: width, height: height)
        androidSwitchMedium.addTarget(self, action: #selector(switchStateChanged(_:)), for: UIControl.Event.valueChanged)
        
        
        if self.viwSwitch.subviews.count > 0 {
            for view in self.viwSwitch.subviews {
                if let materialSwitch = view.viewWithTag(tag) as? MJMaterialSwitch {
                    print("Already exists \(materialSwitch.tag)")
                    materialSwitch.removeFromSuperview()
                    self.viwSwitch.addSubview(androidSwitchMedium)
                }
            }
        } else {
            self.viwSwitch.addSubview(androidSwitchMedium)
        }
        
    }
    
    public func setData(service: Service, tag: Int) {
        self.lblServiceName.text = service.service_type.capitalized
        androidSwitchMedium.tag = tag
        self.setupSwitch(with: service.status, tag: tag)
    }
    
    // MARK: - IBActions
    @objc func switchStateChanged(_ mjSwitch: MJMaterialSwitch) {
        if self.cellDelegate != nil {
            self.cellDelegate?.switchStateChanged(mjSwitch)
        }
    }
    
    
    
}
