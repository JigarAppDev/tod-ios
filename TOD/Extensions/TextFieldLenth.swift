//
//  TextFieldLenth.swift
//  Management
//
//  Created by iMac on 31/12/20.
//  Copyright © 2020 Bhavin Kevadia. All rights reserved.
//

import Foundation
import UIKit

private var __maxLengths = [UITextField: Int]()

extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    
    @objc func fix(textField: UITextField) {
        if let t: String = textField.text {
            textField.text = String(t.prefix(maxLength))
        }
    }
    
}
