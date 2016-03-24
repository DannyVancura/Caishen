# 💳 Caishen - Payment Card UI & Validation for iOS

## Description

Caishen provides an easy-to-use text field to ask users for payment card information and to validate the input. It serves a similar purpose as [PaymentKit](https://github.com/stripe/PaymentKit), but is developed as a standalone framework entirely written in Swift. Caishen also allows an easy integration with other third-party frameworks, such as [CardIO](https://www.card.io).

## Installation

Caishen is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Caishen"
```

## Usage

### Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

---

### Inside your project

To add a text field for entering card information to a view, either ...

- ... add a UITextField to your view in InterfaceBuilder and change its class to *CardNumberTextField* (when using InterfaceBuilder)
- ... or initiate a *CardNumberTextField* with one of its initializers (when instantiating from code): 
	- init?(coder: aDecoder: NSCoder)
	- init(frame: CGRect)

To get updates about entered card information on your view controller, confirm to the protocol *CardNumberTextFieldDelegate* set the view controller as *cardNumberTextFieldDelegate* for the text field:

```swift
class MyViewController: UIViewController, CardNumberTextFieldDelegate {
	
	@IBOutlet weak var cardNumberTextField: CardNumberTextField?
	
	override func viewDidLoad() {
		cardNumberTextField?.cardNumberTextFieldDelegate = self
		
		...
	}
	
	func cardNumberTextField(cardNumberTextField: CardNumberTextField, didEnterCardInformation information: Card?, withValidationResult validationResult: CardValidationResult?) {
		// A valid card has been entered, if information is not nil and validationResult == CardValidationResult.Valid
	}
	
	func cardNumberTextFieldShouldShowAccessoryImage(cardNumberTextField: CardNumberTextField) -> UIImage? {
		// You can return an image which will be used on cardNumberTextField's accessory button
		// If you return nil but provide an accessory button action, the unicode character "⇤" is displayed instead of an image to indicate an action that affects the text field.
	}
	
	func cardNumberTextFieldShouldProvideAccessoryAction(cardNumberTextField: CardNumberTextField) -> (() -> ())? {
		// You can return a callback function which will be called if a user tapped on cardNumberTextField's accessory button
		// If you return nil, cardNumberTextField won't display an accessory button at all.
	}
	
	...
```

---

### Customizing the text field appearance

CardNumberTextField is mostly customizable like every other UITextField. Setting any of the following standard attributes for a CardNumberTextField (either from code or from interface builder) will affect the text field just like it affects any other UITextField:

| Property           | Type                 | Description                                                                                                            |
|:-------------------|:---------------------|:-----------------------------------------------------------------------------------------------------------------------|
| placeholder        | String?              | The card number place holder. This will be automatically formatted at runtime to look like an actual Visa card number. |
| textColor          | UIColor?             | The color of text entered into the CardNumberTextField.                                                                |
| backgroundColor    | UIColor?             | The background color of the text field.                                                                                |
| font               | UIFont?              | The font of the entered text.                                                                                          |
| keyboardType       | UIKeyboardType       | The keyboard type that is used for input in the text field.                                                            |
| secureTextEntry    | Bool                 | When set to true, any input in the text field will be secure (i.e. masked with "•" characters).                        |
| keyboardAppearance | UIKeyboardAppearance | The keyboard appearance when editing text in the text field.                                                           |
| borderStyle        | UITextBorderStyle    | The border style for the text field.                                                                                   |

Additionally, CardNumberTextField offers attributes tailored to its purpose (accessible from interface builder as well):

| Property           | Type                 | Description                                                                                                            |
|:-------------------|:---------------------|:-----------------------------------------------------------------------------------------------------------------------|
| cardNumberSeparator| String?              | A string that is used to separate the groups in a card number. Defaults to " - ".                                      |
| viewAnimationDuration | Double?           | The duration for a view animation in seconds when switching between the card number text field and details (month, view and cvc text fields). |
| invalidInputColor  | UIColor?             | The text color for invalid input. When entering an invalid card number, the text will flash in this color and in case of an expired card, the expiry will be displayed in this color as well. |

---

### CardIO

CardIO might be among the most powerful tools to let users enter their payment card information. It uses the camera and lets the user scan his or her credit card. However, you might still want to provide users with a visually appealing text field to enter their payment card information, since users might want to restrict access to their camera or simply want to enter this information manually.

In order to provide users with a link to CardIO, you can use a CardNumberTextField's `prefillCardInformation` method alongside the previously mentioned accessory button:

```swift
// 1. Let your view controller confirm to the CardNumberTextFieldDelegate and CardIOPaymentViewControllerDelegate protocol:
class ViewController: UIViewController, CardNumberTextFieldDelegate, CardIOPaymentViewControllerDelegate {
	...
	
	// MARK: - CardNumberTextFieldDelegate
    func cardNumberTextField(cardNumberTextField: CardNumberTextField, didEnterCardInformation information: Card?, withValidationResult validationResult: CardValidationResult?) {
        if validationResult == .Valid {
        	// A valid payment card has been manually entered or CardIO was used to scan one.
        }
    }
    
    // 2. Optionally provide an image for the CardIO button
    func cardNumberTextFieldShouldShowAccessoryImage(cardNumberTextField: CardNumberTextField) -> UIImage? {
        return UIImage(named: "cardIOIcon")
    }
    
    // 3. Set the action for the accessoryButton to open CardIO:
    func cardNumberTextFieldShouldProvideAccessoryAction(cardNumberTextField: CardNumberTextField) -> (() -> ())? {
        return { [weak self] _ in
            let cardIOViewController = CardIOPaymentViewController(paymentDelegate: self)
            self?.presentViewController(cardIOViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - CardIOPaymentViewControllerDelegate
    
    // 4. When receiving payment card information from CardIO, prefill the text field with that information:
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        cardNumberTextField.prefillCardInformation(
        	cardInfo.cardNumber, 
        	month: Int(cardInfo.expiryMonth), 
        	year: Int(cardInfo.expiryYear), 
        	cvc: cardInfo.cvv)
        	
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
```

---

### Specifying your own card types

CardNumberTextField further contains a *CardTypeRegister* which maintains a set of different card types that are accepted by this text field.
You can create your own card types and add or remove them to or from card number text fields:

```swift
struct MyCardType: CardType {
    
	// MARK: - Required
	
	// The image that will be displayed in the card number text field's image view when this card type has been detected:
    public let cardTypeImage: UIImage? = UIImage(named: "MyCardType")
	
	// The name of your specified card type:
    public let name = "My Card Type"
	
	// If the Issuer Identification Number (the first six digits of the entered card number) of a card number 
	// starts with anything from 1000 to 1111, the card is identified as being of type "MyCardType":
    public let identifyingDigits = Set(1000...1111)
	
	// MARK: - Optional
	
	// Not specifying this will assert a three digits long cvc:
	public let CVCLength = 4
	
	// Not specifying this will load a default cvc image:
    public let cvcImage: UIImage? = UIImage(named: "MyCardTypeCVCImage")
	
	// Not specifying this will result in a 16 digit number, separated into 4 groups of 4 digits.
	// The grouping of your card number type. The following results in a card number format
	// like "100 - 0000 - 00000 - 000000":
	public let numberGrouping = [3, 4, 5, 6]
	
    public init() {
		
    }
}

...

class MyViewController: UIViewController, CardNumberTextFieldDelegate {
	
	@IBOutlet weak var cardNumberTextField: CardNumberTextField?
	...
	
	func viewDidLoad() {
		cardNumberTextField?.cardTypeRegister.registerCardType(MyCardType())
	}
	
	...
}
```

## Author

Daniel Vancura, daniel@prolificinteractive.com

## License

Caishen is available under the MIT license. See the LICENSE file for more info.
