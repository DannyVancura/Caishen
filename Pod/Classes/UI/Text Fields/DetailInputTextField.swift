//
//  DetailInputTextField.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/9/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 A text field subclass that validates any input for card detail before changing the text attribute.
 You can subclass `DetailInputTextField` and override `isInputValid` to specify the validation routine.
 The default implementation accepts any input.
 */
public class DetailInputTextField: StylizedTextField {
    
    var cardInfoTextFieldDelegate: CardInfoTextFieldDelegate?
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text ?? "").isEmpty {
            textField.text = UITextField.emptyTextFieldCharacter
        }
    }
    
    public override func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: (textField.text ?? "")).stringByReplacingCharactersInRange(range, withString: string).stringByReplacingOccurrencesOfString(UITextField.emptyTextFieldCharacter, withString: "")
        
        let deletingLastCharacter = !(textField.text ?? "").isEmpty && textField.text != UITextField.emptyTextFieldCharacter && newText.isEmpty
        if deletingLastCharacter {
            textField.text = UITextField.emptyTextFieldCharacter
            cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: newText)
            return false
        }
        
        let autoCompletedNewText = autocompleteText(newText)
        
        let (currentTextFieldText, overflowTextFieldText) = splitText(autoCompletedNewText)
        
        if isInputValid(currentTextFieldText, partiallyValid: true) {
            textField.text = currentTextFieldText
            if isInputValid(currentTextFieldText, partiallyValid: false) {
                cardInfoTextFieldDelegate?.textField(self, didEnterValidInfo: currentTextFieldText)
            } else {
                cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: currentTextFieldText)
            }
        }
        
        if !overflowTextFieldText.characters.isEmpty {
            cardInfoTextFieldDelegate?.textField(self, didEnterOverflowInfo: overflowTextFieldText)
        }
        
        return false
    }
    
    public func prefillInformation(info: String) {
        if isInputValid(info, partiallyValid: false) {
            text = info
            cardInfoTextFieldDelegate?.textField(self, didEnterValidInfo: info)
        } else if isInputValid(info, partiallyValid: true) {
            text = info
            cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: info)
        }
    }
    
    private func splitText(text: String) -> (currentText: String, overflowText: String) {
        let hasOverflow = text.characters.count > expectedInputLength
        let index = (hasOverflow) ?
            text.startIndex.advancedBy(expectedInputLength) :
            text.startIndex.advancedBy(text.characters.count)
        return (text.substringToIndex(index), text.substringFromIndex(index))
    }
}

extension DetailInputTextField: AutoCompletingTextField {

    func autocompleteText(text: String) -> String {
        return text
    }
}

extension DetailInputTextField: TextFieldValidation {
    /**
     Default number of expected digits for MonthInputTextField and YearInputTextField
     */
    var expectedInputLength: Int {
        return 2
    }

    func isInputValid(input: String, partiallyValid: Bool) -> Bool {
        return true
    }
}
