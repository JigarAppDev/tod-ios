//
//  Validtion.swift
//  Management
//
//  Created by Bhavin Kevadia on 12/11/20.
//  Copyright © 2020 Bhavin Kevadia. All rights reserved.
//

import Foundation


class Validation {
   public func validateName(name: String) ->Bool {
      // Length be 18 characters max and 3 characters minimum, you can always modify.
      let nameRegex = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ "
      let trimmedString = name.trimmingCharacters(in: .whitespaces)
      let validateName = NSPredicate(format: "SELF MATCHES %@", nameRegex)
      let isValidateName = validateName.evaluate(with: trimmedString)
      return isValidateName
   }
   public func validCharacters  (phoneNumber: String) -> Bool {
      let phoneNumberRegex = ".*[^A-Za-z0-9].*{3,32}$"
      let trimmedString = phoneNumber.trimmingCharacters(in: .whitespaces)
      let validatePhone = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
      let isValidPhone = validatePhone.evaluate(with: trimmedString)
      return isValidPhone
   }
   public func validateEmailId(emailID: String) -> Bool {
      let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let trimmedString = emailID.trimmingCharacters(in: .whitespaces)
      let validateEmail = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
      let isValidateEmail = validateEmail.evaluate(with: trimmedString)
      return isValidateEmail
   }
   public func validatePassword(password: String) -> Bool {
      //Minimum 8 characters at least 1 Alphabet and 1 Number:
      let passRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
      let trimmedString = password.trimmingCharacters(in: .whitespaces)
      let validatePassord = NSPredicate(format:"SELF MATCHES %@", passRegEx)
      let isvalidatePass = validatePassord.evaluate(with: trimmedString)
      return isvalidatePass
   }
   public func validateAnyOtherTextField(otherField: String) -> Bool {
      let otherRegexString = "Your regex String"
      let trimmedString = otherField.trimmingCharacters(in: .whitespaces)
      let validateOtherString = NSPredicate(format: "SELF MATCHES %@", otherRegexString)
      let isValidateOtherString = validateOtherString.evaluate(with: trimmedString)
      return isValidateOtherString
   }
    public func validDate(otherField: String) -> Bool {
       let otherRegexString = ""
       let trimmedString = otherField.trimmingCharacters(in: .whitespaces)
       let validateOtherString = NSPredicate(format: "SELF MATCHES %@", otherRegexString)
       let isValidateOtherString = validateOtherString.evaluate(with: trimmedString)
       return isValidateOtherString
    }
    public func phoneNumber(budget: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = budget.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return budget == numberFiltered
    }
}
