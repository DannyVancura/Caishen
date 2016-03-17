//
//  CardExpiryDateValidator.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/3/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public class CardExpiryDateValidator {

    public init() {
        
    }

    /**
     Validates the card's expiry date.
    */
    public func validateExpiry(expiry: Expiry) -> CardValidationResult {
        return self.checkBeforeCurrentDate(expiry)
    }
    
    /**
     Checks if the card is already expired.
     - parameter expiry: The card's expiry information.
     - returns: `CardValidationResult.CardExpired`, if the card has already expired. Valid otherwise.
    */
    private func checkBeforeCurrentDate(expiry: Expiry) -> CardValidationResult {
        let currentDate = NSDate()
        
        let expiryDate = expiry.rawValue
        
        if expiryDate.timeIntervalSince1970 < currentDate.timeIntervalSince1970 {
            return CardValidationResult.CardExpired
        } else {
            return CardValidationResult.Valid
        }
    }
}
