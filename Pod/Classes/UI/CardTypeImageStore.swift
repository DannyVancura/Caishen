//
//  CardImageStore.swift
//  Pods
//
//  Created by Christopher Jones on 3/24/16.
//
//

import UIKit

/// Defines a store that will return an image for a specific card type.
public protocol CardTypeImageStore {

    func imageForCardType(cardType: CardType) -> UIImage?
    func cvcImageForCardType(cardType: CardType) -> UIImage?

}

extension NSBundle: CardTypeImageStore {

    public func imageForCardType(cardType: CardType) -> UIImage? {
        return UIImage(named: cardType.name, inBundle: self, compatibleWithTraitCollection: nil)
    }

    public func cvcImageForCardType(cardType: CardType) -> UIImage? {
        let cvcImageName: String
        if cardType.isEqualTo(AmericanExpress()) {
            cvcImageName = "AmexCVC"
        } else {
            cvcImageName = "CVC"
        }
        
        return UIImage(named: cvcImageName, inBundle: self, compatibleWithTraitCollection: nil)
    }

}
