//
//  NumberInputTextField.Swift
//  Caishen
//
//  Created by Daniel Vancura on 2/9/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 This kind of text field only allows entering card numbers and provides means to customize the appearance of entered card numbers by changing the card number group separator.
 */
@IBDesignable
public class NumberInputTextField: StylizedTextField {

    // MARK: - Variables
    
    /**
     The card number that has been entered into this text field. 
     
     - note: This card number may be incomplete and invalid while the user is entering a card number. Be sure to validate it against a proper card type before assuming it is valid.
     */
    public var cardNumber: Number {
        let textFieldTextUnformatted = cardNumberFormatter.unformattedCardNumber(text ?? "")
        return Number(rawValue: textFieldTextUnformatted)
    }
    
    /**
     */
    @IBOutlet public weak var numberInputTextFieldDelegate: NumberInputTextFieldDelegate?
    
    /**
     The string that is used to separate different groups in a card number.
     */
    @IBInspectable public var cardNumberSeparator: String = "-" {
        didSet {
            placeholder = cardNumberFormatter.formattedCardNumber(self.placeholder ?? "1234123412341234")
        }
    }

    override public var placeholder: String? {
        didSet {
            guard let placeholder = placeholder else {
                return
            }

            let isUnformatted = (placeholder == self.cardNumberFormatter.unformattedCardNumber(placeholder))
        
            // Format the placeholder, if not already done
            if isUnformatted && cardNumberSeparator != "" {
                self.placeholder = cardNumberFormatter.formattedCardNumber(placeholder)
            }
        }
    }
    
    /**
     The card type register that holds information about which card types are accepted and which ones are not.
     */
    private let cardTypeRegister: CardTypeRegister = CardTypeRegister.sharedCardTypeRegister
    
    /**
     A card number formatter used to format the input
     */
    private var cardNumberFormatter: CardNumberFormatter {
        return CardNumberFormatter(cardTypeRegister: cardTypeRegister, separator: cardNumberSeparator)
    }
    
    /**
     Private struct for storing the text color when flashing the text field.
     Using asynchronous operations to flash the text field would result in the text color being overwritten:
     - user types in invalid number
        -> Original text color is stored
        -> Text color is set to red for 0.5 seconds
     - after less than 0.5 seconds, the user types in invalid card number again
        -> The text color is stored again, but right now, this text color is red.
     
     Solution: Save the text color only on first read.
     */
    private struct SaveOldColor {
        static var onceToken: dispatch_once_t = 0
        static var oldTextColor: UIColor?
        
        init(textColor: UIColor?) {
            dispatch_once(&SaveOldColor.onceToken, {
                SaveOldColor.oldTextColor = textColor
            })
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    public override func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Current text in text field, formatted and unformatted:
        let textFieldTextFormatted = NSString(string: textField.text ?? "")
        // Text in text field after applying changes, formatted and unformatted:
        let newTextFormatted = textFieldTextFormatted.stringByReplacingCharactersInRange(range, withString: string)
        let newTextUnformatted = cardNumberFormatter.unformattedCardNumber(newTextFormatted)
        
        if !newTextUnformatted.isEmpty && !newTextUnformatted.isNumeric() {
            flashTextFieldInvalid()
            return false
        }

        let parsedCardNumber = Number(rawValue: newTextUnformatted)
        let oldValidation = cardTypeRegister.cardTypeForNumber(cardNumber).validateNumber(cardNumber)
        let newValidation =
            cardTypeRegister.cardTypeForNumber(parsedCardNumber).validateNumber(parsedCardNumber)

        if !newValidation.contains(.NumberTooLong) {
            cardNumberFormatter.replaceRangeFormatted(range, inTextField: textField, withString: string)
            numberInputTextFieldDelegate?.numberInputTextFieldDidChangeText(self)
        } else if oldValidation == .Valid {
            numberInputTextFieldDelegate?.numberInputTextFieldDidComplete(self)
        }

        let newLengthComplete =
            parsedCardNumber.length == cardTypeRegister.cardTypeForNumber(parsedCardNumber).maxLength

        if newLengthComplete && newValidation != .Valid {
            flashTextFieldInvalid()
        } else if newValidation == .Valid {
            numberInputTextFieldDelegate?.numberInputTextFieldDidComplete(self)
        }

        return false
    }
    
    public func prefillInformation(cardNumber: String) {
        let validCharacters: Set<Character> = Set("0123456789".characters)
        let unformattedCardNumber = String(cardNumber.characters.filter({validCharacters.contains($0)}))
        let cardNumber = Number(rawValue: unformattedCardNumber)
        let type = cardTypeRegister.cardTypeForNumber(cardNumber)
        let numberPartiallyValid = type.checkCardNumberPartiallyValid(cardNumber) == .Valid
        
        if numberPartiallyValid {
            let formatter = cardNumberFormatter
            text = formatter.formattedCardNumber(unformattedCardNumber)
            numberInputTextFieldDelegate?.numberInputTextFieldDidChangeText(self)
        }
    }
    
    // MARK: - Helper functions
    
    /**
     Computes the rect that contains the specified text range within the text field.
     - precondition: This function will only work, when `textField` is the first responder. If `textField` is not first responder, `textField.beginningOfDocument` will not be initialized and this function will return nil.
     - parameter range: The range of the text in the text field whose bounds should be detected.
     - parameter textField: The text field containing the text.
     - returns: A rect indicating the location and bounds of the text within the text field, or nil, if an invalid range has been entered.
     */
    private func rectForTextRange(range: NSRange, inTextField textField: UITextField) -> CGRect? {
        guard let rangeStart = textField.positionFromPosition(textField.beginningOfDocument, offset: range.location) else {
            return nil
        }
        guard let rangeEnd = textField.positionFromPosition(rangeStart, offset: range.length) else {
            return nil
        }
        guard let textRange = textField.textRangeFromPosition(rangeStart, toPosition: rangeEnd) else {
            return nil
        }
        
        return textField.firstRectForRange(textRange)
    }
    
    /**
     - precondition: This function will only work, when `self` is the first responder. If `self` is not first responder, `self.beginningOfDocument` will not be initialized and this function will return nil.
     - returns: The CGRect in `self` that contains the last group of the card number.
     */
    public func rectForLastGroup() -> CGRect? {
        guard let lastGroupLength = text?.componentsSeparatedByString(cardNumberFormatter.separator).last?.characters.count else {
            return nil
        }
        guard let textLength = text?.characters.count else {
            return nil
        }
        
        return rectForTextRange(NSMakeRange(textLength - lastGroupLength, lastGroupLength), inTextField: self)
    }
    
    /**
     Shortly changes the text color to indicate, that the user was about to enter an invalid card number.
     */
    private func flashTextFieldInvalid() {
        NSOperationQueue().addOperationWithBlock({ [unowned self] _ in
            let _ = SaveOldColor(textColor: self.textColor)
            dispatch_async(dispatch_get_main_queue(), {
                UIView.animateWithDuration(0.5, animations: { [unowned self] _ in
                    self.textColor = self.invalidInputColor
                    })
            })
            NSThread.sleepForTimeInterval(0.5)
            dispatch_async(dispatch_get_main_queue(), {
                UIView.animateWithDuration(0.5, animations: { [unowned self] _ in
                    self.textColor = SaveOldColor.oldTextColor
                    })
            })
            })
    }
}
