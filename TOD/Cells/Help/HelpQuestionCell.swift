//
//  HelpQuestionCell.swift
//  TOD
//
//  Created by My Mac on 24/05/21.
//

import UIKit

class HelpQuestionCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var viwMain: UIView!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var viwExpand: UIView!
    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var lblAnswer: UILabel!
    
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
    
    public func setData(faq: FAQs, isSelected: Bool) {
        self.lblQuestion.text = faq.title
        self.lblAnswer.text = faq.description
        
        if isSelected {
            self.lblAnswer.isHidden = false
            self.btnExpand.setImage(#imageLiteral(resourceName: "ic_expand_less"), for: .normal)
            self.btnExpand.tintColor = .systemGreen
        } else {
            self.lblAnswer.isHidden = true
            self.btnExpand.setImage(#imageLiteral(resourceName: "ic_expand_more"), for: .normal)
            self.btnExpand.tintColor = .darkGray
        }
    }
    
}
