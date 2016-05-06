//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Vladislav Dorfman on 21.04.16.
//  Copyright © 2016 Vladislav Dorfman. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: CustomStringConvertible
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double) // operation name, operation function, operation priority,
        case BinaryOperation(String, (Double, Double) -> Double, Int) // operation name, operation function, operation priority
        case Variable(String)
        case Constant(String, () -> Double)
        var description : String {
            get {
                switch self {
                case .Operand (let operand):
                    return "\(operand)"
                case .Variable (let operand):
                    return operand
                case .Constant (let operand, _):
                    return operand
                case .UnaryOperation (let symbol, _ ):
                    return symbol
                case .BinaryOperation(let symbol, _ , _):
                    return symbol
                }
            }
        }
        var priority : Int {
            get {
                switch self {
                case .BinaryOperation(_, _ , let priority):
                    return priority
                default:
                    return Int.max
                }
            }
        }
        
    }
    
    var description : String {
        get {
            var (descriptionStr, remainder, _) = description(opStackRPN)
            
            while !remainder.isEmpty {
                var result : String
                
                (result, remainder, _) = description(remainder)
                descriptionStr = result + ", " + descriptionStr
            }
            print("\(opStackRPN) = \(descriptionStr)")
            return descriptionStr + "="
            
        }
    }
    
    private var opStackRPN = [Op]() // Reverse Polish notation for calculations
    
    private var opStackInfix = [Op]() // Infix notation for input
    
    private var knownOps = [String:Op]() //dictionary
    
    //    private var Brackets = [String:String]()
    private var Priority = [String:Int]()
    
    
    
    var variableValues = [String:Double]()
    
    init () {
        
        func learnOp (op: Op) {
            knownOps[op.description] = op
        }
        
        //Constants
        learnOp(Op.Constant("π", {M_PI}))
        learnOp(Op.Constant("e", {M_E}))
        
        //Binary operations
        learnOp(Op.BinaryOperation("×", *, 2))
        learnOp(Op.BinaryOperation("+", +, 1))
        learnOp(Op.BinaryOperation("÷", { $1 / $0   }, 3))
        learnOp(Op.BinaryOperation("−", { $1 - $0   }, 1))
        learnOp(Op.BinaryOperation("^", { pow($1, $0)  }, 4))
        
        //Unary operations
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("tan", tan))
        learnOp(Op.UnaryOperation("log", log10))
        
        //        // Brackets
        //        Brackets["("] = "OpenBracket"
        //        Brackets[")"] = "CloseBracket"
        
    }
    
    //// Adding stuff to stack
    
    // Adding a Double operand and evaluating mathematical expression from stack
    
    func pushOperand( operand : Double) -> Double? {
        opStackRPN.append(Op.Operand(operand))
        return evaluate()
    }
    
    
    // Adding a constant or variable
    
    func pushOperand( constant : String) -> Double? {
        opStackRPN.append(Op.Variable(constant))
        return evaluate()
    }
    
    // Adding binary or unary operation to the stack and evaluating mathematical expression from stack
    
    func performOperation( symbol: String) -> Double? { //perform mathematical operation using postfix expression notation
        if let operation = knownOps[symbol] {
            opStackRPN.append(operation)
        }
        return evaluate()
    }
    
    
    func cancel() { // resetting stack and variables
        opStackRPN = []
        variableValues = [:]
    }
    
    
    private func expression(Ops: [Op]) -> String { // represent the stack as a string in postfix notation
        var outputStr : String = ""
        Ops.forEach {outputStr += $0.description + " "}
        return outputStr
    }
    
    
    //// Evaluating
    
    // General function for evaluating double value from stack (expression in postfix notation)
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStackRPN)
        print("\(opStackRPN) = \(result) with \(remainder) left over")
        return result
    }
    
    // Evaluating helper with recursive calculations
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand( let operand):
                return (operand, remainingOps)
            case .Variable( let variable):
                if let operand = variableValues[variable] {
                    return (operand, remainingOps)
                }
            case .Constant(_ , let constantValue ):
                return (constantValue(), remainingOps)
            case .UnaryOperation(_, let operation) :
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation, _):
                let operand1Evaluation = evaluate(remainingOps)
                if let operand1 = operand1Evaluation.result {
                    let operand2Evaluation = evaluate(operand1Evaluation.remainingOps)
                    if let operand2 = operand2Evaluation.result {
                        return (operation(operand1, operand2), operand2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil,ops)
    }
    
    private func description (ops: [Op]) -> (infixPart: String, remainingOps: [Op], precedence : Int) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand( let operand) :
                return (String(operand), remainingOps, op.priority)
            case .Variable( let variable) :
                if variableValues[variable] == nil {
                    print("\(variable) is not convertable to Double!")
                }
                return (variable, remainingOps, op.priority)
            case .Constant( let constant, _) :
                return (constant, remainingOps, op.priority)
            case .UnaryOperation(let operation, _ ) :
                let descriptionEvaluation = description(remainingOps)
                return ("\(operation)(\(descriptionEvaluation.infixPart))", descriptionEvaluation.remainingOps, op.priority)
            case .BinaryOperation(let operation, _ ,  let precedence) :
                var descriptionRight = description(remainingOps)
                var descriptionLeft = description(descriptionRight.remainingOps)
                
                if precedence > descriptionRight.precedence {
                    descriptionRight.infixPart = "(" + descriptionRight.infixPart + ")"
                }
                if precedence > descriptionLeft.precedence {
                    descriptionLeft.infixPart = "(" + descriptionLeft.infixPart + ")"
                }
                return (descriptionLeft.infixPart + operation + descriptionRight.infixPart, descriptionLeft.remainingOps, precedence)
                
            }
        }
        return ("?",ops, Int.max)
    }
    
    
    //// Infix notation stack of operands to postfix notation stack convertion - for future use - not tested
    
    private func infixToPostfix (infixOpQueue : [Op]) -> [Op]  //Shunting-yard algorithm
    {
        var rpnOpStack = [Op] ()
        var opStack = [Op]()
        var remainingQueue = infixOpQueue
        
        while !infixOpQueue.isEmpty {
            let op = remainingQueue.removeFirst()
            //debug
            print(op)
            print(remainingQueue)
            print(rpnOpStack)
            print(opStack)
            
            switch op {
            case .Operand, .Variable, .Constant (_) :
                rpnOpStack.append(op)
            case .UnaryOperation(_ , _ ), .BinaryOperation(_ , _, _) :
                var endOp = false
                while !endOp {
                    if opStack.isEmpty {
                        opStack.append(op)
                        endOp = true
                    }
                    else {
                        if (op.priority > opStack.last!.priority) {
                            opStack.append(op)
                            endOp = true
                        }
                        else {
                            rpnOpStack.append(opStack.last!)
                        }
                    }
                }
            }
        }
        return rpnOpStack
    }
    
    func undo () -> Double? {
        if !opStackRPN.isEmpty {
            
            let operand = opStackRPN.removeLast()
            switch operand {
            case .Operand ( let opVal) :
                return opVal                
            default:
                return nil
            }
        }
        return nil
    }
    
    ////Section for future use
    
    typealias PropertyList = AnyObject // for future use
    
    
    var program: PropertyList { //guaranteed to be a PropertyList
        get {
            return opStackRPN.map {$0.description }
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = Double(opSymbol) {
                        newOpStack.append(.Operand(operand))
                    }
                    opStackRPN = newOpStack
                }
            }
        }
    }
    
    
    
}