//
//  CardNumberTextField+UITextFieldDelegate.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/4/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

extension CardNumberTextField: CardInfoTextFieldDelegate {

    public func textField(textField: UITextField, didEnterValidInfo: String) {
        switch textField {
        case let val where val == monthTextField:
            monthString = val.text
        case let val where val == yearTextField:
            yearString = val.text
        case let val where val == cvcTextField:
            cardCVC = CVC(rawValue: val.text ?? "")
        default:
            break
        }
        
        checkCardExpired()
        selectNextTextField(textField)
    }
    
    public func textField(textField: UITextField, didEnterPartiallyValidInfo: String) {
        switch textField {
        case let val where val == monthTextField:
            monthString = nil
        case let val where val == yearTextField:
            yearString = nil
        case let val where val == cvcTextField:
            cardCVC = nil
        default:
            break
        }
        
        checkCardExpired()
    }
    
    private func selectNextTextField(textField: UITextField) {
        if textField == monthTextField {
            yearTextField?.becomeFirstResponder()
        } else if textField == yearTextField {
            cvcTextField?.becomeFirstResponder()
        }
    }
    
    private func checkCardExpired() {
        // if the date is invalid, set the text color for the date to `invalidNumberColor`
        if cardExpiry?.rawValue.timeIntervalSinceNow < 0 {
            monthTextField?.textColor = invalidInputColor ?? UIColor.redColor()
            yearTextField?.textColor = invalidInputColor ?? UIColor.redColor()
        } else {
            monthTextField?.textColor = numberInputTextField?.textColor ?? UIColor.blackColor()
            yearTextField?.textColor = numberInputTextField?.textColor ?? UIColor.blackColor()
        }
        
        notifyDelegate()
    }
}
