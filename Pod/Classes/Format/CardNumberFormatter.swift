//
//  CardNumberFormatter.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/4/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public final class CardNumberFormatter {

    public let separator: String
    private var cardTypeRegister: CardTypeRegister
    
    /**
     Creates a `CardNumberFormatter` with the provided separator for formatting.
     - parameter separator: The separator that is used for grouping the card number.
     */
    public init(cardTypeRegister: CardTypeRegister, separator: String = " ") {
        self.separator = separator
        self.cardTypeRegister = cardTypeRegister
    }
    
    /**
     This function removes the format of a card number string that has been formatted with the same instance of a `CardNumberFormatter`.
     - parameter cardNumberString: The card number string representation that has previously been formatted with `self`.
     - returns: The unformatted card number string representation.
     */
    public func unformattedCardNumber(cardNumberString: String) -> String {
        return cardNumberString.stringByReplacingOccurrencesOfString(self.separator, withString: "")
    }
    
    /**
     Formats the given card number string based on the detected card type.
     - seealso: CardType.CardTypeForNumber
     - seealso: CardType.numberGroupingForCardType
     - parameter cardNumberString: The card number's unformatted string representation.
     - returns: Formatted card number string.
     */
    public func formattedCardNumber(cardNumberString: String) -> String {
        let regex: NSRegularExpression
        
        let cardType = cardTypeRegister.cardTypeForNumber(Number(rawValue: cardNumberString))
        do {
            let groups = cardType.numberGrouping
            var pattern = ""
            var first = true
            for group in groups {
                pattern += "(\\d{1,\(group)})"
                if !first {
                    pattern += "?"
                }
                first = false
            }
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions())
        } catch {
            fatalError("Error when creating regular expression: \(error)")
        }
        
        return NSArray(array: self.splitString(cardNumberString, withRegex: regex)).componentsJoinedByString(self.separator)
    }
    
    /**
     Computes the index of the cursor position after unformatting the textField's content.
     - parameter textField: The textField containing a formatted string.
     - returns: The index of the cursor position or nil, if no selected text was found.
     */
    public func cursorPositionAfterUnformattingText(text: String, inTextField textField: UITextField) -> Int? {
        guard let selectedRange = textField.selectedTextRange else {
            return nil
        }
        let addedCharacters = text.characters.count - (textField.text ?? "").characters.count
        
        let position = textField.offsetFromPosition(textField.beginningOfDocument, toPosition: selectedRange.start) + addedCharacters
        
        let formattedString = text ?? ""
        let components = formattedString.componentsSeparatedByString(self.separator)
        
        // Find the component that contains the cursor
        var componentContainingCursor = 0
        var stringParsingIndex = 0
        for i in 0..<components.count {
            stringParsingIndex += components[i].characters.count
            if position <= stringParsingIndex {
                componentContainingCursor = i
                break
            }
            stringParsingIndex += self.separator.characters.count
        }
        
        return position - componentContainingCursor * self.separator.characters.count
    }
    
    private func indexInUnformattedString(index: Int, formattedString: String) -> Int {
        var componentWithIndex = 0
        var charCount = 0
        for component in formattedString.componentsSeparatedByString(self.separator) {
            charCount += component.characters.count
            if charCount >= index {
                break
            } else {
                componentWithIndex += 1
                charCount += self.separator.characters.count
            }
        }
        
        return index - componentWithIndex * self.separator.characters.count
    }
    
    private func indexInFormattedString(index: Int, unformattedString: String) -> Int {
        var charIdx = 0
        let formattedString = self.formattedCardNumber(unformattedString)
        
        let groups = formattedString.componentsSeparatedByString(self.separator)
        
        for i in 0..<groups.count {
            let groupChars = groups[i].characters.count
            
            charIdx += groupChars
            if charIdx >= index {
                return min(index + i * self.separator.characters.count, formattedString.characters.count)
            }
        }
        
        return 0
    }
    
    public func replaceRangeFormatted(range: NSRange, inTextField textField: UITextField, withString string: String) {
        let newValueUnformatted = self.unformattedCardNumber(NSString(string: textField.text ?? "").stringByReplacingCharactersInRange(range, withString: string))
        let oldValueUnformatted = self.unformattedCardNumber(textField.text ?? "")
        
        let newValue = self.formattedCardNumber(newValueUnformatted)
        let oldValue = textField.text ?? ""
        
        var position: UITextPosition?
        if let start = textField.selectedTextRange?.start {
            let oldCursorPosition = textField.offsetFromPosition(textField.beginningOfDocument, toPosition: start)
            let oldCursorPositionUnformatted = self.indexInUnformattedString(oldCursorPosition, formattedString: oldValue)
            let newCursorPositionUnformatted = oldCursorPositionUnformatted + (newValueUnformatted.characters.count - oldValueUnformatted.characters.count)
            let newCursorPositionFormatted = self.indexInFormattedString(newCursorPositionUnformatted, unformattedString: newValueUnformatted)
            
            position = textField.positionFromPosition(textField.beginningOfDocument, offset: newCursorPositionFormatted)
        }
        
        textField.text = newValue
        if let position = position {
            textField.selectedTextRange = textField.textRangeFromPosition(position, toPosition: position)
        }
    }
    
    /**
     Splits a string with a given regular expression and returns all matches in an array of separate strings.
     - parameter string: The string that is to be split.
     - parameter regex: The regular expression that is used to search for matches in `string`.
     - returns: An array of all matches found in string for `regex`.
     */
    private func splitString(string: String, withRegex regex: NSRegularExpression) -> [String] {
        let matches = regex.matchesInString(string, options: NSMatchingOptions(), range: NSMakeRange(0, string.characters.count))
        var result = [String]()
        
        matches.forEach {
            for i in 1..<$0.numberOfRanges {
                let range = $0.rangeAtIndex(i)
                
                if range.length > 0 {
                    result.append(NSString(string: string).substringWithRange(range))
                }
            }
        }
        
        return result
    }
}
