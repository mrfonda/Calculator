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
    
    @IBOutlet weak var display: UILabel!

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
        operandStack.append(displayValue)
        print("\(operandStack)  \(lastOperator)")

    }
    
    var equalsPressed = false
    
    @IBAction func equals() {
        
        
        if userIsInTheMiddleOfTypingANumer {
            enter()
        }
        if !operandStack.isEmpty {
            let lastOperand = operandStack.last
            operate(lastOperator)
            operandStack.append(lastOperand!)
            equalsPressed = true
        }
        
    }
    
    func operate (operation : String) {
        switch operation {
        case "×": performOperation {$0 * $1}
        case "÷": performOperation {$1 / $0}
        case "−": performOperation {$1 - $0}
        case "+": performOperation {$0 + $1}
        case "√": performOperation {sqrt($0)}
        case "sin": performOperation {sin($0)}
        case "cos": performOperation {cos($0)}
        case "tan": performOperation {tan($0)}
        case "log": performOperation {log10($0)}
        default:
            break
        }
    }
    
    @IBAction func immidiateOperation(sender: AnyObject) {
        if equalsPressed {
            equalsPressed = false
        }
        operandStack.removeAll()
        
        let operation = sender.currentTitle!
        
        enter()
        
        operate(operation!)
        
//        lastOperator = ""
        
    }
    
    @IBAction func storedOperation(sender: UIButton) {
        
        if equalsPressed {
            equalsPressed = false
            operandStack.removeLast()
        }
        
        if userIsInTheMiddleOfTypingANumer {
            enter()
        }
        
        
        
        operate(lastOperator)
        
        let operation = sender.currentTitle!
        lastOperator = operation
         print(lastOperator)
        
    }
    
    @nonobjc
    func performOperation (operation: (Double, Double) -> Double ) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    func performOperation (operation : Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
            
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

