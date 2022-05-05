//
//  UITextView+Extensions.swift
//  TOD
//
//  Created by My Mac on 25/05/21.
//

import Foundation
import UIKit

extension UITextView {
    
    func setPlaceholder(message: String, tag: Int) {
        let placeholderLabel = UILabel()
        placeholderLabel.text = message
        placeholderLabel.font = AppFont.ROBOTO_REGULAR_14
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = tag
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 2)
        placeholderLabel.textColor = AppColor.COLOR_GRAY_COLOR
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
    }
    
    func checkPlaceholder(tag: Int) {
        let placeholderLabel = self.viewWithTag(tag) as! UILabel
        placeholderLabel.isHidden = !self.text.isEmpty
    }
    
}
