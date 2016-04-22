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
        if display.text != "0.0" && display.text != "0"  {
//            var value = display.text!
            display.text = display.text!.substringToIndex(display.text!.characters.endIndex.predecessor())
        }
        if (display.text?.isEmpty)! {
            display.text = "0"
            userIsInTheMiddleOfTypingANumer = false
        }
    }
    
    @IBAction func pasteSpecialValue(sender: UIButton) {
        userIsInTheMiddleOfTypingANumer = true
        if let mathematicalSymbol = sender.currentTitle {
            if mathematicalSymbol == "π" {
                display.text = String(M_PI)
            }
        }
    }
    //lalala
    var operandStack = Array<Double>()
    var lastOperator = ""
    
    @IBAction func cancel() {
        operandStack = []
        displayValue = 0
        equalsPressed = false
        userIsInTheMiddleOfTypingANumer = false

    }
    


    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumer = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        }
        else {
            displayValue = 0
        }
    }
    
    var equalsPressed = false
    
    @IBAction func equals() {
        
        
        if userIsInTheMiddleOfTypingANumer {
            enter()
        }
        if !operandStack.isEmpty {
            let lastOperand = operandStack.last
           // operate(lastOperator)
            operandStack.append(lastOperand!)
            equalsPressed = true
        }
        
    }
    
    
    @IBAction func storedOperation(sender: UIButton) {
        
        if equalsPressed {
            equalsPressed = false
            operandStack.removeLast()
        }
        
        if userIsInTheMiddleOfTypingANumer {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
            displayValue = result
            } else
            {
                displayValue = 0
            }
        }
        
    }
    
    var displayValue : Double {
        get {
            if NSNumberFormatter().numberFromString(display.text!) == nil {
                return 0.0
            }
            else {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
            }
        }
        set{
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumer = false
        }
    }

}

