//
//  BTCard+Caishen.swift
//  Pods
//
//  Created by Daniel Vancura on 3/25/16.
//
//

import Foundation
import Braintree

public extension BTCard {
    public convenience init(card: Caishen.Card) {
        self.init(number: card.bankCardNumber.rawValue, expirationMonth: String(format: "%02i", card.expiryDate.month), expirationYear: String(format: "%02i", card.expiryDate.year), cvv: card.cardVerificationCode.rawValue)
    }
    
    public var caishenCard: Caishen.Card {
        return Card(braintreeCard: self)
    }
}
