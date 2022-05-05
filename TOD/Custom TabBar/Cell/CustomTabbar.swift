//
//  CustomTabbar.swift
//  TOD
//
//  Created by My Mac on 21/05/21..
//

import Foundation

import UIKit

@objc protocol CustomTabBarViewDelegate {
    
    @objc optional func tabSelectedAtIndex(tabIndex: Int)
}

class CustomTabBar: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet var btnTabs: [UIButton]!
    @IBOutlet weak var viwButtonView: UIView!
    @IBOutlet weak var imgBooking: UIImageView!
    @IBOutlet weak var imgHelp: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnBooking: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var viwBooking: UIView!
    @IBOutlet weak var viwHelp: UIView!
    @IBOutlet weak var viwProfile: UIView!
    @IBOutlet weak var imgSelectedBooking: UIImageView!
    @IBOutlet weak var imgSelectedHelp: UIImageView!
    @IBOutlet weak var imgSelectedProfile: UIImageView!
    @IBOutlet weak var viwSelectedBooking: UIView!
    @IBOutlet weak var viwSelectedHelp: UIView!
    @IBOutlet weak var viwSelectedProfile: UIView!
    @IBOutlet weak var btnSelectedBooking: UIButton!
    @IBOutlet weak var btnSelectedHelp: UIButton!
    @IBOutlet weak var btnSelectedProfile: UIButton!
    @IBOutlet weak var lblBooking: UILabel!
    @IBOutlet weak var lblHelp: UILabel!
    @IBOutlet weak var lblProfile: UILabel!
    @IBOutlet weak var viwGrayBooking: UIView!
    @IBOutlet weak var viwGrayHelp: UIView!
    @IBOutlet weak var viwGrayProfile: UIView!
    
    
    // MARK: - Variables
    var delegate: CustomTabBarViewDelegate?
    var alertCount: NSNumber = 0
    private var lastIndex: Int = Int()
    
    
    // MARK: - View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        initializeSetup()
    }
    
    private func initializeSetup() {
        for btn in btnTabs {
            if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
                btn.titleLabel?.font = UIFont(name: btn.titleLabel!.font.familyName, size: 9.0)
            }
            //btn.centerVerticallyWithPadding(padding: verticalSpacing)
        }
        setupView()
        setupImageView()
        tabBtnClicked(btnTabs.first!)
    }
    
    private func setupView() {
        viwButtonView.addShadow(color: AppColor.SHADOW_COLOR, opacity: 1, offset: CGSize(width: 1, height: 1), radius: 5)
        viwGrayBooking.addCornerRadius(viwGrayBooking.frame.size.height / 2.0)
        viwGrayHelp.addCornerRadius(viwGrayHelp.frame.size.height / 2.0)
        viwGrayProfile.addCornerRadius(viwGrayProfile.frame.size.height / 2.0)
    }
    
    private func setupImageView() {
        self.imgSelectedBooking.tintColor = AppColor.APP_THEME_COLOR
        self.imgHelp.tintColor = AppColor.ICON_TINT_COLOR
        self.imgProfile.tintColor = AppColor.ICON_TINT_COLOR
    }
    
    func selectTabAt(index: Int) {
        
        lastIndex = index
        
        for btn in btnTabs {
            
            if(btn.tag == index) {
                btn.isSelected = true
                if btn == btnBooking {
                    self.viwBooking.isHidden = true
                    self.viwSelectedBooking.isHidden = false
                    self.imgBooking.tintColor = AppColor.APP_THEME_COLOR
                    self.imgSelectedBooking.tintColor = AppColor.APP_THEME_COLOR
                    self.imgBooking.tintColorDidChange()
                    self.imgSelectedBooking.tintColorDidChange()
                } else if btn == btnHelp {
                    self.viwHelp.isHidden = true
                    self.viwSelectedHelp.isHidden = false
                    self.imgHelp.tintColor = AppColor.APP_THEME_COLOR
                    self.imgSelectedHelp.tintColor = AppColor.APP_THEME_COLOR
                } else if btn == btnProfile {
                    self.viwProfile.isHidden = true
                    self.viwSelectedProfile.isHidden = false
                    self.imgProfile.tintColor = AppColor.APP_THEME_COLOR
                    self.imgSelectedProfile.tintColor = AppColor.APP_THEME_COLOR
                }
            } else {
                btn.isSelected = false
                if btn == btnBooking {
                    self.viwBooking.isHidden = false
                    self.viwSelectedBooking.isHidden = true
                    self.imgBooking.tintColor = AppColor.ICON_TINT_COLOR
                    self.imgSelectedBooking.tintColor = AppColor.ICON_TINT_COLOR
                    
                } else if btn == btnHelp {
                    self.viwHelp.isHidden = false
                    self.viwSelectedHelp.isHidden = true
                    self.imgHelp.tintColor = AppColor.ICON_TINT_COLOR
                    self.imgSelectedHelp.tintColor = AppColor.ICON_TINT_COLOR
                } else if btn == btnProfile {
                    self.viwProfile.isHidden = false
                    self.viwSelectedProfile.isHidden = true
                    self.imgProfile.tintColor = AppColor.ICON_TINT_COLOR
                    self.imgSelectedProfile.tintColor = AppColor.ICON_TINT_COLOR
                }
            }
            
            self.imgBooking.tintColorDidChange()
            self.imgSelectedBooking.tintColorDidChange()
            self.imgHelp.tintColorDidChange()
            self.imgSelectedHelp.tintColorDidChange()
            self.imgProfile.tintColorDidChange()
            self.imgSelectedProfile.tintColorDidChange()
        }
        
        delegate?.tabSelectedAtIndex!(tabIndex: lastIndex)
    }
    
    //MARK: - All button click events
    @IBAction func tabBtnClicked(_ sender: UIButton) {
        lastIndex = sender.tag
        selectTabAt(index: lastIndex)
    }
}
