//
//  SwiftMathSolver.swift
//  photoMath
//
//  Created by Cyprien OUDART on 4/28/25.
//

import Foundation

class SwiftMathSolver {
    static func solve(_ equation: String) -> String {
        // Process the equation to replace UI symbols
        var processedEquation = equation
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "−", with: "-")
        
        // Check if it's an equation (contains =)
        if processedEquation.contains("=") {
            return solveEquation(processedEquation)
        } else {
            return evaluateExpression(processedEquation)
        }
    }
    
    private static func evaluateExpression(_ expression: String) -> String {
        // This is a simplified expression evaluator
        // For a complete solution, you would use a proper expression parser
        
        // Handle basic operations
        do {
            let expr = NSExpression(format: expression)
            if let result = expr.expressionValue(with: nil, context: nil) as? NSNumber {
                // Format the result
                if result.doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                    return "\(Int(result.doubleValue))"
                } else {
                    // Check if it's close to a simple fraction
                    let (num, denom) = approximateFraction(result.doubleValue)
                    if denom <= 10 { // Only show "nice" fractions
                        return "\(num)/\(denom)"
                    }
                    return "\(result.doubleValue)"
                }
            }
        } catch {
            return "Error evaluating expression"
        }
        
        return "Cannot evaluate expression"
    }
    
    private static func solveEquation(_ equation: String) -> String {
        // Split the equation into left and right sides
        let sides = equation.split(separator: "=")
        if sides.count != 2 {
            return "Invalid equation format"
        }
        
        let leftSide = String(sides[0])
        let rightSide = String(sides[1])
        
        // Check if the equation contains x
        if equation.contains("x") {
            // Very basic linear equation solver (ax+b=c)
            // This is a simplified implementation
            
            // Move everything to the left side
            // ax + b - c = 0
            // Solve for x: x = (c - b) / a
            
            // For a proper implementation, you would need a more sophisticated equation parser
            
            // Example for 2x+3=7
            if leftSide.contains("x+") {
                let parts = leftSide.split(separator: "x+")
                if parts.count == 2, 
                   let coefficient = Double(parts[0].isEmpty ? "1" : String(parts[0])), 
                   let constant = Double(parts[1]), 
                   let rightValue = Double(rightSide) {
                    
                    let solution = (rightValue - constant) / coefficient
                    
                    // Format the result
                    if solution.truncatingRemainder(dividingBy: 1) == 0 {
                        return "x = \(Int(solution))"
                    } else {
                        // Check if it's a simple fraction
                        let (num, denom) = approximateFraction(solution)
                        if denom <= 10 { // Only show "nice" fractions
                            return "x = \(num)/\(denom)"
                        }
                        return "x = \(solution)"
                    }
                }
            }
            
            return "Cannot solve equation yet"
        } else {
            // It's an equation without x, check if it's true
            do {
                let leftExpr = NSExpression(format: leftSide)
                let rightExpr = NSExpression(format: rightSide)
                
                if let leftValue = leftExpr.expressionValue(with: nil, context: nil) as? NSNumber,
                   let rightValue = rightExpr.expressionValue(with: nil, context: nil) as? NSNumber {
                    
                    if abs(leftValue.doubleValue - rightValue.doubleValue) < 0.0001 {
                        return "Equation is true"
                    } else {
                        return "Equation is false"
                    }
                }
            } catch {
                return "Error evaluating equation"
            }
        }
        
        return "Cannot solve equation"
    }
    
    // Helper function to approximate a decimal as a fraction
    private static func approximateFraction(_ value: Double) -> (Int, Int) {
        let tolerance = 1.0E-6
        
        var n = 1
        var d = 1
        
        // Check for common fractions
        if abs(value - 0.5) < tolerance { return (1, 2) }
        if abs(value - 0.25) < tolerance { return (1, 4) }
        if abs(value - 0.75) < tolerance { return (3, 4) }
        if abs(value - 0.33333) < tolerance { return (1, 3) }
        if abs(value - 0.66667) < tolerance { return (2, 3) }
        if abs(value - 0.2) < tolerance { return (1, 5) }
        
        // For more complex fractions, use a continued fraction algorithm
        var x = value
        var a = floor(x)
        var h1 = 1.0
        var h2 = 0.0
        var k1 = 0.0
        var k2 = 1.0
        var h = a * h1 + h2
        var k = a * k1 + k2
        
        while abs(value - h / k) > tolerance && n < 10000 {
            x = 1.0 / (x - a)
            a = floor(x)
            h2 = h1
            h1 = h
            k2 = k1
            k1 = k
            h = a * h1 + h2
            k = a * k1 + k2
            n += 1
        }
        
        return (Int(h), Int(k))
    }
}