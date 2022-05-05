//
//  FAQs.swift
//  TOD
//
//  Created by My Mac on 28/05/21.
//

import Foundation

struct FAQs {
    
    let description: String
    let title: String

    init(description: String, title: String) {
        self.description = description
        self.title = title
    }
    
    init(data: [String: Any]) {
        
        if let description = data[ApiParameterStatics.description] as? String, !description.isEmpty {
            self.description = description
        } else {
            self.description = ""
        }
        
        if let title = data[ApiParameterStatics.title] as? String, !title.isEmpty {
            self.title = title
        } else {
            self.title = ""
        }
        
    }
    
}
