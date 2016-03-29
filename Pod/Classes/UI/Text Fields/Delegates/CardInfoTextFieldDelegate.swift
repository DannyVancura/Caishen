//
//  MonthInputTextFieldDelegate.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/8/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public protocol CardInfoTextFieldDelegate {
    func textField(textField: UITextField, didEnterValidInfo: String)
    func textField(textField: UITextField, didEnterPartiallyValidInfo: String)
    func textField(textField: UITextField, didEnterOverflowInfo overFlowDigits: String)
}
