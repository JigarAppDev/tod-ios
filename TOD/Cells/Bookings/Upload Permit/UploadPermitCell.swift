//
//  UploadPermitCell.swift
//  TOD
//
//  Created by My Mac on 24/05/21.
//

import UIKit

class UploadPermitCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var viwMain: UIView!
    @IBOutlet weak var viwSubMain: UIView!
    @IBOutlet weak var imgAdd: UIImageView!
    @IBOutlet weak var imgUploadedPermit: UIImageView!
    @IBOutlet weak var lblPermitName: UILabel!
    @IBOutlet weak var lctImageHeight: NSLayoutConstraint!
    
    // MARK: - Variables
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        // Initialization code
    }
    
    // MARK: - Methods
    private func setupUI() {
        setupView()
    }
    
    private func setupView() {
        viwMain.addCornerRadius(10.0)
        viwMain.clipsToBounds = true
        viwMain.addShadow(color: AppColor.TEXT_SHADOW, opacity: 0.3, offset: CGSize(width: 1.0, height: 1.0), radius: 2)
    }
    
    public func setData(permitName: String, image: UIImage?) {
        self.lblPermitName.text = permitName
        if image != nil {
            self.imgUploadedPermit.isHidden = false
            self.imgUploadedPermit.image = image
            self.lctImageHeight.constant = 80.0
        } else {
            self.imgUploadedPermit.isHidden = true
            self.lctImageHeight.constant = 0.0
        }
    }
    

}
