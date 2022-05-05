//
//  UIView+Extensions.swift
//  TOD
//
//  Created by My Mac on 21/05/21.
//

import Foundation
import UIKit

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor.init(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {

            layer.shadowRadius = shadowRadius
        }
    }
    @IBInspectable
    var shadowOffset : CGSize{

        get{
            return layer.shadowOffset
        }set{

            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor : UIColor{
        get{
            return UIColor.init(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    @IBInspectable
    var shadowOpacity : Float {

        get{
            return layer.shadowOpacity
        }
        set {

            layer.shadowOpacity = newValue

        }
    }
    
    public func addCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    public func applyBorder(_ width: CGFloat, borderColor: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
    }
    
    public func addShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addSubViewWithAutolayout(subView: UIView) {
        self.addSubview(subView)
        
        subView.translatesAutoresizingMaskIntoConstraints = true
        
        if #available(iOS 11.0, *) {
            let guide = self.safeAreaLayoutGuide
            subView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            subView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            subView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            subView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        } else {
            subView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            subView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            subView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            subView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        
        subView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private static let kLayerNameGradientBorder = "GradientBorderLayer"

    func setGradientBorder(
        width: CGFloat,
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5),radius: CGFloat) {
        let existedBorder = gradientBorderLayer()
        let border = existedBorder ?? CAGradientLayer()
        border.frame = bounds
        border.colors = colors.map { return $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint

        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width

        border.mask = mask

        let exists = existedBorder != nil
        if !exists {
            layer.insertSublayer(border, at: 0)
            layer.addSublayer(border)
        }
    }


    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter { return $0.name == UIView.kLayerNameGradientBorder }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }
    
}

extension UIDevice {
    
    //::
    static let FRAME = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    
    static let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    //static let IS_TV = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.TV
    
    static let IS_IPHONE_4_OR_LESS =  IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 1125.0
    static let IS_IPHONE_LESS_THAN_6 =  IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH < 667.0
    static let IS_IPHONE_LESS_THAN_OR_EQUAL_6 =  IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH <= 667.0
    
    static let IS_IPHONE_4_OR_LESS_MIN =  IS_IPHONE && ScreenSize.SCREEN_MIN_LENGTH < 320.0
    static let IS_IPHONE_5_MIN = IS_IPHONE && ScreenSize.SCREEN_MIN_LENGTH == 320.0
    static let IS_IPHONE_6_MIN = IS_IPHONE && ScreenSize.SCREEN_MIN_LENGTH == 375.0
    static let IS_IPHONE_6P_MIN = IS_IPHONE && ScreenSize.SCREEN_MIN_LENGTH == 375.0
    static let IS_IPHONE_X_MIN = IS_IPHONE && ScreenSize.SCREEN_MIN_LENGTH == 375.0
    static let IS_IPHONE_7P_MIN = IS_IPHONE && ScreenSize.SCREEN_MIN_LENGTH == 414.0
    static let IS_IPHONE_LESS_THAN_6_MIN =  IS_IPHONE && ScreenSize.SCREEN_MIN_LENGTH < 375.0
    static let IS_IPHONE_LESS_THAN_OR_EQUAL_6_MIN =  IS_IPHONE && ScreenSize.SCREEN_MIN_LENGTH <= 375.0
    static let IS_IPAD_ = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO_11 = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1194.0
    static let IS_IPAD_AIR = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1180.0
    static let IS_IPAD_PRO = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH >= 1180 && ScreenSize.SCREEN_MAX_LENGTH <= 1366.0
    //::
    
    
    var iPhoneX: Bool { UIScreen.main.nativeBounds.height == 2436 }
    var iPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    var iPad: Bool { UIDevice().userInterfaceIdiom == .pad }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR_11 = "iPhone XR or iPhone 11"
        case iPhone_XSMax_ProMax = "iPhone XS Max or iPhone Pro Max"
        case iPhone_11Pro = "iPhone 11 Pro"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR_11
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2426:
            return .iPhone_11Pro
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax_ProMax
        default:
            return .unknown
        }
    }
    
}
extension UIImage {

    public enum DataUnits: String {
        case byte, kilobyte, megabyte, gigabyte
    }

    func getSizeIn(_ type: DataUnits)-> String {

        guard let data = self.pngData() else {
            return ""
        }

        var size: Double = 0.0

        switch type {
        case .byte:
            size = Double(data.count)
        case .kilobyte:
            size = Double(data.count) / 1024
        case .megabyte:
            size = Double(data.count) / 1024 / 1024
        case .gigabyte:
            size = Double(data.count) / 1024 / 1024 / 1024
        }

        return String(format: "%.2f", size)
    }
}
