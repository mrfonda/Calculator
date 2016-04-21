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
    private enum Op {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    }
    
    private var opStack = [Op]()
    

    
    private var knownOps = [String:Op]()
    
    init () {

        //Binary operations
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0   }
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0   }
        //Unary operations
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        knownOps["tan"] = Op.UnaryOperation("tan", tan)
        knownOps["log"] = Op.UnaryOperation("log", log10)
    }
    private func evaluate( ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand( let operand) :
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation) :
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation) :
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
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        
        return result
    }
    func pushOperand( operand : Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    func performOperation( symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
}