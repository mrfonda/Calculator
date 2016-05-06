//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Vladislav Dorfman on 21.04.16.
//  Copyright © 2016 Vladislav Dorfman. All rights reserved.
//

import Foundation

class CalculatorBrain2016
{
    private enum Op: CustomStringConvertible
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double, Int) // operation name, operation function, operation priority
        case BinaryOperation(String, (Double, Double) -> Double, Int) // operation name, operation function, operation priority
        //        case Bracket(String)
        
        var description : String {
            get {
                switch self {
                case .Operand (let operand):
                    return "\(operand)"
                case .UnaryOperation (let symbol, _ , _):
                    return symbol
                case .BinaryOperation(let symbol, _ , _):
                    return symbol
                    //                    case .Bracket(let symbol):
                    //                        return symbol
                }
            }
        }
        var priority : Int {
            get {
                switch self {
                case .Operand (_):
                    return 0
                case .UnaryOperation (_, _ , let priority):
                    return priority
                case .BinaryOperation(_, _ , let priority):
                    return priority
                    //                    case .Bracket(let symbol):
                    //                        return symbol
                }
            }
        }
    }
    
    private var opStackRPN = [Op]() // Reverse Polish notation for calculations
    
    private var opStackInfix = [Op]() // Infix notation for input
    
    private var knownOps = [String:Op]() //dictionary
    
    //    private var Brackets = [String:String]()
    private var Priority = [String:Int]()
    
    //2016 Stanford course 
    
    
    init () {
        func learnOp (op: Op) {
            knownOps[op.description] = op
        }
        //Binary operations
        learnOp(Op.BinaryOperation("×", *, 2))
        learnOp(Op.BinaryOperation("+", +, 1))
        learnOp(Op.BinaryOperation("÷", { $1 / $0   }, 3))
        learnOp(Op.BinaryOperation("−", { $1 - $0   }, 1))
        //Unary operations
        learnOp(Op.UnaryOperation("√", sqrt, 4))
        learnOp(Op.UnaryOperation("sin", sin, 4))
        learnOp(Op.UnaryOperation("cos", cos, 4))
        learnOp(Op.UnaryOperation("tan", tan, 4))
        learnOp(Op.UnaryOperation("log", log10, 4))
        //        // Brackets
        //        Brackets["("] = "OpenBracket"
        //        Brackets[")"] = "CloseBracket"
        
    }
    
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
                
            case .Operand( let operand) :
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation, _) :
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation, _) :
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
    private func parseMathExpression (infixOpQueue : [Op]) -> [Op]  //Shunting-yard algorithm
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
            case .Operand(_) :
                rpnOpStack.append(op)
            case .UnaryOperation(_ , _ , _), .BinaryOperation(_ , _, _) :
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
                
                
                //            case .Bracket(_) :
                //                opStack.append(op)
                
                
            }
            
        }
        
        
        
        return rpnOpStack
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStackRPN)
        print("\(opStackRPN) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand( operand : Double) -> Double? {
        opStackRPN.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation( symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStackRPN.append(operation)
        }
        return evaluate()
    }
    
}