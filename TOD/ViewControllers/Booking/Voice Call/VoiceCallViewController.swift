//
//  VoiceCallViewController.swift
//  TOD
//
//  Created by My Mac on 02/06/21.
//

import UIKit

class VoiceCallViewController: UIViewController {

    // MARK: - Variables
    var callerName: String = "Unknown Number"
    
    // MARK: - IBOutlets
    @IBOutlet weak var viwMain: UIView!
    @IBOutlet weak var lblCallerName: UILabel!
    @IBOutlet weak var lblCalling: UILabel!
    @IBOutlet weak var imgCallerPicture: UIImageView!
    @IBOutlet weak var btnReject: UIButton!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
    }
    
    // MARK: - Methods
    private func setupUI() {
        setupView()
        setupLabel()
        setupButton()
    }
    
    private func setupView() {
        
    }
    
    private func setupLabel() {
        self.lblCallerName.text = callerName
    }
    
    private func setupButton() {
        btnReject.addCornerRadius(self.btnReject.frame.height / 2.0)
    }
    
    // MARK: - IBActions
    @IBAction func onBtnRejectAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
