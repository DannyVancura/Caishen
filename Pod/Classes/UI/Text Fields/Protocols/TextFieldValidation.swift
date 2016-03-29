//
//  TextFieldValidation.swift
//  Pods
//
//  Created by Daniel Vancura on 3/29/16.
//
//

import Foundation

internal protocol TextFieldValidation {
    
    /**
     number of expected digits for a DetailInputTextField,
     E.g. For a MonthInputTextField, it is 2. For a CVCInputTextField with Visa type, it is 3
     */
    var expectedInputLength: Int { get }
    
    /**
     Checks the validity of the input.
     
     - returns: True, if the input is valid.
     */
    func isInputValid(input: String, partiallyValid: Bool) -> Bool
}
