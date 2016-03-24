//
//  ViewController.swift
//  Caishen
//
//  Created by Daniel Vancura on 02/03/2016.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit
import Caishen
import Braintree

class ViewController: UIViewController, CardNumberTextFieldDelegate, CardIOPaymentViewControllerDelegate {
    
    @IBOutlet weak var buyButton: UIButton?
    @IBOutlet weak var cardNumberTextField: CardNumberTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBraintree()
        cardNumberTextField.cardNumberTextFieldDelegate = self
    }
    
    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - CardNumberTextField delegate methods
    
    // This method of `CardNumberTextFieldDelegate` will set the saveButton enabled or disabled, based on whether valid card information has been entered.
    func cardNumberTextField(cardNumberTextField: CardNumberTextField, didEnterCardInformation information: Card, withValidationResult validationResult: CardValidationResult) {

        print (validationResult)

        buyButton?.enabled = validationResult == .Valid
    }
    
    func cardNumberTextFieldShouldShowAccessoryImage(cardNumberTextField: CardNumberTextField) -> UIImage? {
        return UIImage(named: "camera")
    }
    
    func cardNumberTextFieldShouldProvideAccessoryAction(cardNumberTextField: CardNumberTextField) -> (() -> ())? {
        return { [weak self] _ in
            let cardIOViewController = CardIOPaymentViewController(paymentDelegate: self)
            self?.presentViewController(cardIOViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Card.io delegate methods
    
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        cardNumberTextField.prefillCardInformation(cardInfo.cardNumber, month: Int(cardInfo.expiryMonth), year: Int(cardInfo.expiryYear), cvc: cardInfo.cvv)
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Braintree
    
    let btAPI: BTAPIClient? = BTAPIClient(authorization: "")
    var braintreeClient: BTAPIClient?
    
    private func setupBraintree() {
        let clientTokenURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com/client_token")!
        let clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
    
        NSURLSession.sharedSession().dataTaskWithRequest(clientTokenRequest) { (data, response, error) -> Void in
            if let error = error {
                print(error)
            }
            guard let data = data else {
                return
            }
    
            let clientToken = String(data: data, encoding: NSUTF8StringEncoding)
            self.braintreeClient = BTAPIClient(authorization: clientToken!)
        }.resume()
    }
    
    @IBAction func buy(sender: UIButton) {
        guard let braintreeClient = braintreeClient else {
            return
        }
    
        cardNumberTextField.card?.tokenizeViaBraintree(braintreeClient, postalCode: "00000", completionHandler: { (nonce) in
            print("\(nonce.type) \(nonce.localizedDescription)")
        }, errorHandler: { (error) in
            print(error)
        })
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

