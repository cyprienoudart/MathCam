import Foundation

class MathSolver {
    static func solve(_ equation: String) -> String {
        // Basic replacements for symbols
        var processedEquation = equation
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "−", with: "-")
            .replacingOccurrences(of: "π", with: "\(Double.pi)")
        
        // Simple equation solver for demonstration
        if equation.contains("=") {
            // Handle equations with x
            if equation.contains("x") {
                // Very basic linear equation solver (2x+3=7)
                let sides = equation.split(separator: "=")
                if sides.count == 2 {
                    let leftSide = String(sides[0])
                    let rightSide = String(sides[1])
                    
                    // Extremely simplified solver for 2x+3=7 type equations
                    if leftSide.contains("x+") {
                        let parts = leftSide.split(separator: "x+")
                        if parts.count == 2, let coefficient = Double(parts[0]), let constant = Double(parts[1]), let rightValue = Double(rightSide) {
                            let solution = (rightValue - constant) / coefficient
                            
                            // Format as fraction if needed
                            if solution.truncatingRemainder(dividingBy: 1) == 0 {
                                return "x = \(Int(solution))"
                            } else if solution == 0.5 {
                                return "x = 1/2"
                            } else {
                                return "x = \(solution)"
                            }
                        }
                    }
                    
                    return "Cannot solve equation yet"
                }
            }
            return "Equation solver not implemented"
        }
        
        // Basic expression evaluation
        do {
            // This is a placeholder - you would need a proper expression evaluator
            // For demonstration, we'll just handle very basic operations
            if processedEquation.contains("+") {
                let parts = processedEquation.split(separator: "+")
                if parts.count == 2, let left = Double(parts[0]), let right = Double(parts[1]) {
                    return "\(left + right)"
                }
            } else if processedEquation.contains("*") {
                let parts = processedEquation.split(separator: "*")
                if parts.count == 2, let left = Double(parts[0]), let right = Double(parts[1]) {
                    return "\(left * right)"
                }
            }
            
            return "Cannot evaluate expression yet"
        }
    }
}