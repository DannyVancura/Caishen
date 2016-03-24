//
//  Card+Braintree.swift
//  Pods
//
//  Created by Daniel Vancura on 3/24/16.
//
//

import Foundation
import Braintree

public extension Card {
    
    public var braintreeCard: BTCard {
        return BTCard(number: bankCardNumber.rawValue, expirationMonth: String(format: "%02i", expiryDate.month), expirationYear: String(format: "%02i", expiryDate.year), cvv: cardVerificationCode.rawValue)
    }
    
    public init(braintreeCard: BTCard) {
        bankCardNumber = Number(rawValue: braintreeCard.number ?? "")
        expiryDate = Expiry(month: braintreeCard.expirationMonth ?? "", year: braintreeCard.expirationYear ?? "") ?? Expiry.invalid
        cardVerificationCode = CVC(rawValue: braintreeCard.cvv ?? "")
    }
    
    /**
     Tokenizes the card for a payment via the provided Braintree API.
     
     - parameter braintreeAPI: The Braintree API you are using.
     - parameter postalCode: The postal code of the user, which should be provided for Braintree's AVS (Address Verification System). This parameter is optional, as not every financial institution might require this parameter. 
     - parameter completionHandler: A closure that is called with the server response's `BTPaymentNonce` in case the payment action succeeded.
     - parameter errorHandler: A closure for the case that any error occurs during payment.
     */
    public func tokenizeViaBraintree(braintreeAPI: BTAPIClient, postalCode: String?, completionHandler: (BTPaymentMethodNonce) -> (), errorHandler: (NSError) -> ()) {
        var options: [String:AnyObject] = [
            "number":               bankCardNumber.rawValue,
            "expiration_date":      expiryDate.description,
            "cvv":                  cardVerificationCode.rawValue,
            "options":              ["validate": (braintreeAPI.valueForKey("tokenizationKey") as? String) != nil]
        ]
        
        if let postalCode = postalCode {
            options["billing_address"] = ["postal_code": postalCode]
        }
        
        BTTokenizationService.sharedService().tokenizeType("Card", options: options, withAPIClient: braintreeAPI) { (nonce, error) in
            if let error = error {
                errorHandler(error)
            } else if let nonce = nonce {
                completionHandler(nonce)
            } else {
                errorHandler(NSError(domain: "com.prolificinteractive.Caishen", code: 0, userInfo: [NSLocalizedDescriptionKey:"Braintree returned with neither an error nor a nonce."]))
            }
        }
    }
    
    public func payViaBraintree(braintreeAPI: BTAPIClient, amount: String, postalCode: String?, errorHandler: (NSError) -> ()) {
        tokenizeViaBraintree(braintreeAPI, postalCode: postalCode, completionHandler: { (paymentMethodNonce) in
            let paymentRequest = BTPaymentRequest()
            paymentRequest.amount = amount
        }) { (error) in
            errorHandler(error)
        }
    }
}