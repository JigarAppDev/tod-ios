//
//  Global.swift
//  TOD
//
//  Created by My Mac on 21/05/21.
//

import Foundation
import SVProgressHUD
import UIKit
import CallKit
import FirebaseFunctions
import TwilioVoice

var enableLog = true
var noInternet = false
var longitude = ""
var latitude = ""
var IS_IPHONE_6 = UIScreen.main.bounds.height <= 667
var IS_IPHONE_SE = UIScreen.main.bounds.height <= 568
var isFirstTime: Bool = false
var incomingPushCompletionCallback: (() -> Void)?
var selectedScheduledDate: Date = Date()
var audioDevice = DefaultAudioDevice()
var activeCallInvites: [String: CallInvite]! = [:]
var callKitProvider: CXProvider?
let callKitCallController = CXCallController()
var incomingAlertController: UIAlertController?
var callKitCompletionCallback: ((Bool) -> Void)? = nil
var activeCalls: [String: Call]! = [:]
var activeCall: Call? = nil
var userInitiatedDisconnect: Bool = false
var isCallDidConnect: Bool = false
var playCustomRingback = true
var ringtonePlayer: AVAudioPlayer? = nil
var SCHEDULED_TAB_DATE_FORMAT = "M/d/yy HH:mma"
var OPEN_COMPLETED_TAB_DATE_FORMAT = "EEEE, MMM dd, yyyy h:mma"
var BOOKING_DETAIL_SCREEN_DATE_FORMAT = "EEEE, MMM dd, yyyy"
var BOOKING_DETAIL_SCREEN_TIME_FORMAT = "h:mm:ssa ZZZZ"
var pushParamModel: VoipPushParam = VoipPushParam(data: [:])
var arrayOfZipCode : [String] = []
let incomingVC = IncomingViewController()

func DLog(_ items: Any?..., function: String = #function, file: String = #file, line: Int = #line) {
    if(enableLog) {
        print("-----------START-------------")
        let url = NSURL(fileURLWithPath: file)
        print("Message = ", items, "\n\n(File: ", url.lastPathComponent ?? "nil", ", Function: ", function, ", Line: ", line, ")")
        print("-----------END-------------\n")
    }
}

protocol ModelToParameters {
    var dbParamRequest: [String: Any] { get }
}
func getCurrentDate() -> String {
    let currentDateTime = Date()
    let formatter = DateFormatter()
    formatter.timeStyle = .long
    formatter.dateStyle = .long
    return formatter.string(from: currentDateTime)
}

func showLoader() {
    SVProgressHUD.setDefaultStyle(.custom)
    SVProgressHUD.setDefaultMaskType(.custom)
    SVProgressHUD.setForegroundColor(AppColor.COLOR_PRIMARY_RED)
    SVProgressHUD.setBackgroundColor(#colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1))
    SVProgressHUD.show()
}

func hideLoader() {
    SVProgressHUD.dismiss()
}


struct AppColor {
    static let APP_THEME_COLOR = #colorLiteral(red: 1, green: 0.4156862745, blue: 0.06666666667, alpha: 1) //FF6A11
    static let ICON_TINT_COLOR = #colorLiteral(red: 0.4, green: 0.4078431373, blue: 0.4117647059, alpha: 1) //666869
    static let SHADOW_COLOR = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1) //CDCDCD
    static let BLACK_COLOR = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) //000000
    static let TEXT_SHADOW = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1) //222222
    static let COLOR_GRAY_COLOR = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1) //888888
    static let OPTION_GRAY_COLOR = #colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1) //C0C0C0
    static let COLOR_PRIMARY_PINK = #colorLiteral(red: 0.8666666667, green: 0.1411764706, blue: 0.462745098, alpha: 1) //DD2476
    static let COLOR_PRIMARY_RED = #colorLiteral(red: 0.9803921569, green: 0.2901960784, blue: 0.2156862745, alpha: 1) //FA4A37
    static let PROFILE_BACKGROUND_COLOR = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1) //E2E2E2
    static let DISABLED_COLOR = #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1) //BEBEBE
    static let WHATSAPP_GREEN = #colorLiteral(red: 0.1450980392, green: 0.8274509804, blue: 0.4, alpha: 1) //25D366
    static let GREEN_COLOR = #colorLiteral(red: 0.2745098039, green: 0.8588235294, blue: 0.5294117647, alpha: 1) //46DB87
}

struct AppFont {
    static let ROBOTO_BOLD_9 = UIFont(name: "Roboto-Bold", size: 9.0)
    static let ROBOTO_MEDIUM_9 = UIFont(name: "Roboto-Medium", size: 9.0)
    static let ROBOTO_LIGHT_9 = UIFont(name: "Roboto-Light", size: 9.0)
    static let ROBOTO_REGULAR_9 = UIFont(name: "Roboto-Regular", size: 9.0)
    
    static let ROBOTO_BOLD_12 = UIFont(name: "Roboto-Bold", size: 12.0)
    static let ROBOTO_MEDIUM_12 = UIFont(name: "Roboto-Medium", size: 12.0)
    static let ROBOTO_LIGHT_12 = UIFont(name: "Roboto-Light", size: 12.0)
    static let ROBOTO_REGULAR_12 = UIFont(name: "Roboto-Regular", size: 12.0)
    
    static let ROBOTO_BOLD_14 = UIFont(name: "Roboto-Bold", size: 14.0)
    static let ROBOTO_MEDIUM_14 = UIFont(name: "Roboto-Medium", size: 14.0)
    static let ROBOTO_LIGHT_14 = UIFont(name: "Roboto-Light", size: 14.0)
    static let ROBOTO_REGULAR_14 = UIFont(name: "Roboto-Regular", size: 14.0)
    
    static let SFPRO_DISPLAY_LIGHT_15 = UIFont(name: "SFProDisplay-Light", size: 15.0)
}

class TextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(
        top: 10,
        left: 15,
        bottom: 10,
        right: 20
    )

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}

func randomString(length: Int) -> String {
  let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}


extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}

func fetchAccessToken(for userID: String, completion: @escaping (String?) -> Void) {
    let urlString: String = URLConstants.getTwilioAccessTokenURL()
    guard let accessTokenURL = URL(string: urlString) else {
        return
    }
    
    let parameters: [String: Any] = [ApiParameterStatics.twilio_client: userID]
    
    APIHandler.shared.callAccessTokenAPI(with: accessTokenURL, parameters: parameters) { (accessTokenStr) in
        completion(accessTokenStr)
    }
}

func incomingPushHandled() {
    guard let completion = incomingPushCompletionCallback else { return }
    
    incomingPushCompletionCallback = nil
    completion()
}


func fetchAccessTokenFromCloudFunction(completion: @escaping ((HTTPSCallableResult?, Error?) -> Void)) {
    let parameters: [String: Any] = [ApiParameterStatics.push: true]
    APIHandler.shared.getTwilioAccessTokenFromCloudFunction(data: parameters) { (httpScallableResult, error) in
        if let httpScallableResult = httpScallableResult {
            completion(httpScallableResult, nil)
        }
        if let error = error {
            completion(nil, error)
        }
    }
}
