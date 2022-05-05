//
//  UICollectionViewCell+Extension.swift
//  TOD
//
//  Created by My Mac on 21/05/21.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    
    // Return Nib
    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // Return Identifier
    public static var identifier: String {
        return String(describing: self)
    }
}
