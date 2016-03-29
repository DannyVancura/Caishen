//
//  UnknownCardType.swift
//  Pods
//
//  Created by Christopher Jones on 3/24/16.
//
//

internal struct UnknownCardType: CardType {

    let name = "Unknown"
    let CVCLength = 0
    let identifyingDigits: Set<Int> = []

    func validateNumber(cardNumber: Number) -> CardValidationResult {
        return .UnknownType
    }

    func validateCVC(cvc: CVC) -> CardValidationResult {
        return .UnknownType
    }

    func validateExpiry(expiry: Expiry) -> CardValidationResult {
        return .UnknownType
    }

}
