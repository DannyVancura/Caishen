//
//  XCTAssertValidation.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/3/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit
import XCTest
import Caishen

func XCTAssertValid(validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult == CardValidationResult.Valid, "Expected the validation result to be true, but was \(validationResult.description)")
}

func XCTAssertInvalidCVC(validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSupersetOf(CardValidationResult.InvalidCVC), "Expected an invalid CVC, but got \(validationResult.description)")
}

func XCTAssertIncompleteCVC(validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSupersetOf(CardValidationResult.CVCIncomplete), "Expected an incomplete CVC, but got \(validationResult.description)")
}

func XCTAssertInvalidNumberForType(validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSupersetOf(CardValidationResult.NumberTooLong), "Expected an invalid number for the credit card type, but got \(validationResult.description)")
}

func XCTAssertIncompleteNumber(validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSupersetOf(CardValidationResult.NumberIncomplete), "Expected an incomplete number for the credit card type, but got \(validationResult.description)")
}

func XCTAssertCardNotExpired(validationResult: CardValidationResult) {
    XCTAssertFalse(validationResult.isSupersetOf(CardValidationResult.CardExpired), "Expected a not expired card, but got: \(validationResult.description)")
}

func XCTAssertCardExpired(validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSupersetOf(CardValidationResult.CardExpired), "Expected an expired card, but got: \(validationResult.description)")
}

func XCTAssertLuhnTestFailed(validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSupersetOf(CardValidationResult.LuhnTestFailed), "Expected a Luhn test failure on validation, but got \(validationResult.description)")
}