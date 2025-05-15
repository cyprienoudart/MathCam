//
//  PythonBridge.swift
//  photoMath
//
//  Created by Cyprien OUDART on 4/28/25.
//

import Foundation

#if os(macOS)
class PythonBridge {
    static func solveMathProblem(_ equation: String) -> String {
        do {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
            
            // Path to your math_solver.py script in the new structure
            let scriptPath = "/Users/cyprienoudart/Documents/work/personal/projects/MathCam/backend/ml_models/math_solver/math_solver.py"
            
            // Process the equation to replace UI symbols with Python equivalents
            let processedEquation = equation
                .replacingOccurrences(of: "×", with: "*")
                .replacingOccurrences(of: "÷", with: "/")
                .replacingOccurrences(of: "−", with: "-")
            
            // Set up arguments to run the script with the equation
            process.arguments = ["-c", "import sys; sys.path.append('/Users/cyprienoudart/Documents/work/personal/projects/MathCam/backend'); from ml_models.math_solver.math_solver import solve_equation; print(solve_equation('\(processedEquation)'))"]
            
            // Create a pipe to capture output
            let pipe = Pipe()
            process.standardOutput = pipe
            
            // Run the process
            try process.run()
            
            // Read the output
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            process.waitUntilExit()
            return "No result"
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}
#endif