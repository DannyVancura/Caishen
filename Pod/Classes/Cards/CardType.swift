//
//  CardType.swift
//  Caishen
//
//  Created by Sagar Natekar on 11/23/15.
//  Copyright © 2015 Prolific Interactive. All rights reserved.
//

import Foundation

/**
 A `CardType` is a predefined type for different bank cards. Bank card types can be determined by using a bank cards number with `CardType.ForNumber(bankCardNumber)`
 */
public protocol CardType {
    
    /**
     - returns: The card type name (e.g.: Visa, MasterCard, ...)
     */
    var name: String { get }
    
    /**
     - returns: The number of digits expected in the Card Validation Code.
     */
    var CVCLength: Int { get }
    
    /**
     The card number grouping is used to format the card number when typing in the card number text field.
     For Visa Card types for example, this grouping would be [4,4,4,4], resulting in a card number format like
     0000-0000-0000-0000.
     - returns: The grouping of digits in the card number.
     */
    var numberGrouping: [Int] { get }
    
    /**
     Card types are typically identified by their first n digits. In compliance to ISO/IEC 7812, the first digit is the *Major industry identifier*, which is equal to:
        - 1, 2 for airlines
        - 3 for Travel & Entertainment (non-banks like American Express, DinersClub, ...)
        - 4, 5 for banking and financial institutions
        - 6 for merchandising and banking/financial (Discover Card, Laser, China UnionPay, ...)
        - 7 for petroleum and other future industry assignments
        - 8 for healthcare, telecommunications and other future industry assignments
        - 9 for assignment by national standards bodies
     The first 6 digits also are the *Issuer Identification Number*, indicating the issuer of the card. 
     
     In order to identify the card issuer, this function returns a Set of integers which indicate the card issuer. In case of Discover for example, this is the set of [(644...649),(622126...622925),(6011)], which contains different IIN ranges which are reserved for Discover.
     
     - returns: A set of numbers which, when being found in the first digits of the card number, indicate the card issuer.
     */
    var identifyingDigits: Set<Int> { get }

    func validateCVC(cvc: CVC) -> CardValidationResult

    func validateNumber(number: Number) -> CardValidationResult

    func validateExpiry(expiry: Expiry) -> CardValidationResult 

    func isEqualTo(cardType: CardType) -> Bool
}

extension CardType {

    public func isEqualTo(cardType: CardType) -> Bool {
        return cardType.name == self.name
    }

    public var numberGrouping: [Int] {
        return [4, 4, 4, 4]
    }

    public var maxLength: Int {
        return numberGrouping.reduce(0) { $0 + $1 }
    }

    public func validateCVC(cvc: CVC) -> CardValidationResult {
        guard let _ = cvc.toInt() else {
            return .InvalidCVC
        }

        if cvc.length > CVCLength {
            return .InvalidCVC
        } else if cvc.length < CVCLength {
            return .CVCIncomplete
        }

        return .Valid
    }

    public func validateNumber(cardNumber: Number) -> CardValidationResult {
        return lengthMatchesType(cardNumber.length)
            .union(numberIsNumeric(cardNumber))
            .union(numberIsValidLuhn(cardNumber))
    }

    public func validateExpiry(expiry: Expiry) -> CardValidationResult {
        guard expiry != Expiry.invalid else {
            return .InvalidExpiry
        }

        let currentDate = NSDate()
        let expiryDate = expiry.rawValue

        if expiryDate.timeIntervalSince1970 < currentDate.timeIntervalSince1970 {
            return CardValidationResult.CardExpired
        } else {
            return CardValidationResult.Valid
        }
    }

    public func expectedCardNumberLength() -> Int {
        return numberGrouping.reduce(0, combine: {$0 + $1})
    }

    public func numberIsValidLuhn(number: Number) -> CardValidationResult {
        var odd = true
        var sum = 0
        let digits = NSMutableArray(capacity: number.length)
        for i in 0..<number.length {
            // If the number is not long enough, fail the Luhn test
            guard let digit = number.description[i,i+1] else {
                return CardValidationResult.LuhnTestFailed
            }
            digits.addObject(NSString(string: digit))
        }
        for obj in digits.reverseObjectEnumerator() {
            let digitString = obj as! NSString
            var digit = digitString.integerValue
            odd = !odd
            if odd {
                digit = digit * 2
            }
            if digit > 9 {3
                digit = digit - 9
            }
            sum += digit
        }

        if sum % 10 == 0 {
            return CardValidationResult.Valid
        } else {
            return CardValidationResult.LuhnTestFailed
        }
    }

    /**
     Returns Valid, if the card validation succeeded or the card validation failed because of the Luhn test or insufficient card number length, both of which are not important for incomplete card numbers.
     */
    public func checkCardNumberPartiallyValid(cardNumber: Number) -> CardValidationResult {
        let validationResult = validateNumber(cardNumber)
        let completeNumberButLuhnTestFailed = !validationResult.isSupersetOf(CardValidationResult.NumberIncomplete) && validationResult.isSupersetOf(CardValidationResult.LuhnTestFailed)

        if completeNumberButLuhnTestFailed {
            return validationResult
        } else {
            return
                self.validateNumber(cardNumber)
                    .subtract(.NumberIncomplete)
                    .subtract(.LuhnTestFailed)
        }
    }

    /**
     Helper method for `lengthMatchesType` to check the actual length of a card number against the expected length.
     - parameter actualLength: The length of a card number that is to be validated.
     - parameter expectedLength: The expected length for the card number's card type.
     - returns: CardValidationResult.Valid if the lengths match, CardValidationResult.NumberDoesNotMatchType otherwise.
     */
    private func testLength(actualLength: Int, assumingLength expectedLength: Int) -> CardValidationResult {
        if actualLength == expectedLength {
            return .Valid
        } else if actualLength < expectedLength {
            return .NumberIncomplete
        } else if actualLength > maxLength {
            return .NumberTooLong
        } else {
            return .NumberDoesNotMatchType
        }
    }

    private func lengthMatchesType(length: Int) -> CardValidationResult {
        return testLength(length, assumingLength: expectedCardNumberLength())
    }

    private func numberIsNumeric(number: Number) -> CardValidationResult {
        for c in number.description.characters {
            if !["0","1","2","3","4","5","6","7","8","9"].contains(c) {
                return CardValidationResult.NumberIsNotNumeric
            }
        }

        return CardValidationResult.Valid
    }

}
