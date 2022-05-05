//
//  TermsAndPrivacyViewController.swift
//  TOD
//
//  Created by iMac on 22/05/21.
//

import UIKit

class TermsAndPrivacyViewController: UIViewController {
    //MARK:- IbOutlet
    @IBOutlet weak var headingView: UIView!
    @IBOutlet weak var businessAddressLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var viewNavigationTopView: UIView!
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
    }
    
    //MARK:- Function
    private func setUpUI() {
        setUpButton()
        setUpLabel()
        setUpView()
    }
    private func setUpButton() {
        self.backButton.backgroundColor = AppColor.APP_THEME_COLOR
        
    }
    private func setUpLabel() {
        self.businessAddressLabel.backgroundColor = AppColor.APP_THEME_COLOR
        
    }
    private func setUpView() {
        self.headingView.backgroundColor = AppColor.APP_THEME_COLOR
        self.viewNavigationTopView.backgroundColor = AppColor.APP_THEME_COLOR
    }
    //MARK:- IbButton Action
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
