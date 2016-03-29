//
//  CVCInputTextField.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/8/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public class CVCInputTextField: DetailInputTextField {
    
    var cardType: CardType?
    override var expectedInputLength: Int {
        return cardType?.CVCLength ?? 3
    }
    /**
     Checks the validity of the entered card validation code.
     
     - returns: True, if the card validation code is valid.
     */
    internal override func isInputValid(cvcString: String, partiallyValid: Bool) -> Bool {
        if cvcString.characters.count == 0 && partiallyValid {
            return true
        }
        
        let cvc = CVC(rawValue: cvcString)
        return (cardType?.validateCVC(cvc) == .Valid) ?? false || partiallyValid && (cardType?.validateCVC(cvc) == .CVCIncomplete) ?? false
    }
}
