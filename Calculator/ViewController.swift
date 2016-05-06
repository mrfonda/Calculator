//
//  ViewController.swift
//  Calculator
//
//  Created by Vladislav Dorfman on 19.04.16.
//  Copyright © 2016 Vladislav Dorfman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var userIsInTheMiddleOfTypingANumer: Bool = false
    var brain = CalculatorBrain()
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var expressionDisplay: UILabel!
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumer {
            let textCurrentlyInInDisplay = display.text!
            display.text = textCurrentlyInInDisplay + digit
        }
        else {
            display.text = digit
        }
        userIsInTheMiddleOfTypingANumer = true
    }
    
    @IBAction func negative() {
        display.text = String(-NSNumberFormatter().numberFromString(display.text!)!.doubleValue)
    }
    
    @IBAction func backSpace() {
        if userIsInTheMiddleOfTypingANumer {
        if display.text != "0.0" && display.text != "0"  {
            //            var value = display.text!
            display.text = display.text!.substringToIndex(display.text!.characters.endIndex.predecessor())
        }
        if (display.text?.isEmpty)! {
            display.text = "0"
            userIsInTheMiddleOfTypingANumer = false
        }
        } else {
            displayValue = brain.undo()
        }
    }
    
    
    @IBAction func cancel() {
        displayValue = 0
        userIsInTheMiddleOfTypingANumer = false
        brain.cancel()
        expressionDisplay.text = brain.description
        
    }
    
    
    //    @IBAction func setVariable(sender: UIButton) {
    //        brain.pushOperand(displayValue!)
    //    }
    
    @IBAction func enter() {
        
        
        if userIsInTheMiddleOfTypingANumer,  let operand = displayValue {
                 displayValue = brain.pushOperand(operand)
        }
        
        userIsInTheMiddleOfTypingANumer = false
    }
    
    
    @IBAction func storedOperation(sender: UIButton) {

        if userIsInTheMiddleOfTypingANumer {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
        
    }
    
    @IBAction func setVariableValue(sender: UIButton) {
        if let variableToSet = sender.currentTitle {
            brain.variableValues[String(variableToSet.characters.dropFirst())] = displayValue
        }
        print(brain.variableValues)
        userIsInTheMiddleOfTypingANumer = false
    }
    
    @IBAction func getVariableValue(sender: UIButton) {
        userIsInTheMiddleOfTypingANumer = true
        if let variableSymbol = sender.currentTitle {
            if let result = brain.pushOperand(variableSymbol) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
       
        if sender.currentTitle != nil {
            if let variableToGet = brain.variableValues[sender.currentTitle!] {
                displayValue = variableToGet
            }
        }
    }
    
    var displayValue : Double? {
        get {
            
            if let doubleValue = Double(display.text!) {
                return doubleValue
            }
            else {
                return 0.0
            }
            //            if String(UTF8String: display.text!) == nil {
            //                return 0.0
            //            }
            //            else {
            //                return Double(display.text!)!
            //            }
        }
        set{
            
            if let valueString = newValue {
                display.text = String(valueString)
            } else {
                display.text = " "
            }
            userIsInTheMiddleOfTypingANumer = false
            expressionDisplay.text = brain.description
        }
    }
    
}

