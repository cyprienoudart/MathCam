//
//  CalculatorView.swift
//  photoMath
//
//  Created by Cyprien OUDART on 4/28/25.
//

import SwiftUI
import Foundation  // Add this import statement

struct CalculatorView: View {
    @Binding var isShowing: Bool
    @State private var inputText: String = ""
    @State private var resultText: String = ""
    @State private var isEditing: Bool = false
    @State private var selectedTab: Int = 0
    @State private var showingLetterKeyboard: Bool = false
    
    // Custom color
    let customRed = Color(hex: "#b62000")
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with logo, title and close button
            HStack {
                // Logo in top left
                Image(systemName: "doc.text.image")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(customRed)
                    .padding(.leading)
                
                Spacer()
                
                // Title centered
                Text("Calculator")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Close button in top right
                Button(action: {
                    isShowing = false
                }) {
                    Text("Close")
                        .foregroundColor(customRed)
                        .fontWeight(.medium)
                        .padding(.trailing)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            // Input area
            ZStack(alignment: .leading) {
                if inputText.isEmpty {
                    Text("Type a math problem...")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                TextField("", text: $inputText, onEditingChanged: { editing in
                    isEditing = editing
                })
                    .font(.system(size: 20))
                    .padding(.horizontal)
                    .foregroundColor(.black)
                    .onChange(of: inputText) { newValue in
                        if !newValue.isEmpty {
                            solveEquation(newValue)
                        } else {
                            resultText = ""
                        }
                    }
            }
            .frame(height: 50)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.horizontal, 8)
                    .offset(y: 12),
                alignment: .bottom
            )
            .padding(.bottom, 20)
            
            // Result area - only visible when not empty
            if !resultText.isEmpty {
                HStack {
                    Text(resultText)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    Spacer()
                }
            }
            
            
            Spacer()
            
            // Function bar
            HStack {
                Button(action: {
                    showingLetterKeyboard.toggle()
                }) {
                    Text("abc")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                }
                
                Button(action: {}) {
                    Image(systemName: "clock")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                }
                
                Button(action: {}) {
                    Image(systemName: "arrow.left")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                }
                
                Button(action: {}) {
                    Image(systemName: "arrow.right")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                }
                
                Button(action: {
                    if !inputText.isEmpty {
                        inputText = String(inputText.dropLast())
                    }
                }) {
                    Image(systemName: "delete.left")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                }
                
                Button(action: {
                    inputText = ""
                }) {
                    Image(systemName: "xmark.rectangle")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                }
            }
            .padding(.vertical, 10)
            .background(Color.white)
            .border(Color.gray.opacity(0.3), width: 1)
            
            // Function buttons (tabs)
            HStack {
                Button(action: { selectedTab = 0 }) {
                    VStack(spacing: 2) { // Reduced spacing
                        Text("+ −")
                        Text("× ÷")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6) // Reduced from 10
                    .background(selectedTab == 0 ? customRed : Color.white)
                    .foregroundColor(selectedTab == 0 ? .white : .black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: selectedTab == 0 ? 0 : 1)
                    )
                }
                
                Button(action: { selectedTab = 1 }) {
                    VStack {
                        Text("f(x)  e")
                        Text("log  ln")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedTab == 1 ? customRed : Color.white)
                    .foregroundColor(selectedTab == 1 ? .white : .black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: selectedTab == 1 ? 0 : 1)
                    )
                }
                
                Button(action: { selectedTab = 2 }) {
                    VStack {
                        Text("sin cos")
                        Text("tan cot")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedTab == 2 ? customRed : Color.white)
                    .foregroundColor(selectedTab == 2 ? .white : .black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: selectedTab == 2 ? 0 : 1)
                    )
                }
                
                Button(action: { selectedTab = 3 }) {
                    VStack {
                        Text("lim  dx")
                        Text("∫ ∞")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedTab == 3 ? customRed : Color.white)
                    .foregroundColor(selectedTab == 3 ? .white : .black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: selectedTab == 3 ? 0 : 1)
                    )
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 5)
            .background(Color.white)
            
            // Keyboard content based on selected tab or letter keyboard
            if showingLetterKeyboard {
                letterKeyboard()
                    .frame(height: 200) // Reduced from 240
                    .background(Color.white)
            } else {
                TabView(selection: $selectedTab) {
                    // Tab 0: Basic operations
                    basicOperationsKeyboard()
                        .tag(0)
                    
                    // Tab 1: Functions
                    functionsKeyboard()
                        .tag(1)
                    
                    // Tab 2: Trigonometry
                    trigonometryKeyboard()
                        .tag(2)
                    
                    // Tab 3: Calculus
                    calculusKeyboard()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 200) // Reduced from 240
                .background(Color.white)
            }
        }
        .background(Color.white)
        .frame(height: UIScreen.main.bounds.height - 80) // Leave approximately 2cm at top
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // Basic operations keyboard with updated symbols from image
    private func basicOperationsKeyboard() -> some View {
        VStack(spacing: 0) {
            // Row 1
            HStack(spacing: 0) {
                // Parentheses with dotted square
                Button(action: {
                    appendToInput("(")
                }) {
                    Image(systemName: "parentheses")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(customRed)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                }
                .border(Color.gray.opacity(0.3), width: 0.5)
                .frame(height: 60)
                
                // Greater than symbol
                keyButton(">", color: customRed)
                
                keyButton("7")
                keyButton("8")
                keyButton("9")
                keyButton("÷", color: customRed)
            }
            
            // Row 2
            HStack(spacing: 0) {
                // Fraction with solid bar and lighter squares
                Button(action: {
                    appendToInput("/")
                }) {
                    ZStack {
                        // Top square (lighter)
                        Rectangle()
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                            .frame(width: 20, height: 20)
                            .offset(y: -15)
                        
                        // Solid middle bar
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.black)
                        
                        // Bottom square (lighter)
                        Rectangle()
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                            .frame(width: 20, height: 20)
                            .offset(y: 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                }
                .border(Color.gray.opacity(0.3), width: 0.5)
                .frame(height: 60)
                
                // Square root with dotted square
                Button(action: {
                    appendToInput("√")
                }) {
                    ZStack {
                        Text("√")
                            .font(.system(size: 24))
                            .foregroundColor(customRed)
                        
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                            .offset(x: 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                }
                .border(Color.gray.opacity(0.3), width: 0.5)
                .frame(height: 60)
                
                keyButton("4")
                keyButton("5")
                keyButton("6")
                keyButton("×", color: customRed)
            }
            
            // Row 3
            HStack(spacing: 0) {
                // Square with dotted square and exponent
                Button(action: {
                    appendToInput("^2")
                }) {
                    ZStack {
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                        
                        Text("²")
                            .font(.system(size: 16))
                            .foregroundColor(customRed)
                            .offset(x: 15, y: -10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                }
                .border(Color.gray.opacity(0.3), width: 0.5)
                .frame(height: 60)
                
                keyButton("x", color: customRed)
                keyButton("1")
                keyButton("2")
                keyButton("3")
                keyButton("−", color: customRed)
            }
            
            // Row 4
            HStack(spacing: 0) {
                keyButton("π", color: customRed)
                keyButton("%", color: customRed)
                keyButton("0")
                keyButton(".", color: customRed)
                keyButton("=", color: customRed)
                keyButton("+", color: customRed)
            }
        }
    }
    
    // Letter keyboard with small square buttons
    private func letterKeyboard() -> some View {
        VStack(spacing: 0) {
            // Row 1
            HStack(spacing: 0) {
                letterButton("q")
                letterButton("w")
                letterButton("e")
                letterButton("r")
                letterButton("t")
                letterButton("y")
                letterButton("u")
                letterButton("i")
                letterButton("o")
                letterButton("p")
            }
            
            // Row 2
            HStack(spacing: 0) {
                letterButton("a")
                letterButton("s")
                letterButton("d")
                letterButton("f")
                letterButton("g")
                letterButton("h")
                letterButton("j")
                letterButton("k")
                letterButton("l")
            }
            
            // Row 3
            HStack(spacing: 0) {
                letterButton("z")
                letterButton("x")
                letterButton("c")
                letterButton("v")
                letterButton("b")
                letterButton("n")
                letterButton("m")
                
                // Delete button
                Button(action: {
                    if !inputText.isEmpty {
                        inputText = String(inputText.dropLast())
                    }
                }) {
                    Image(systemName: "delete.left")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.black)
                        .background(Color.white)
                }
                .border(Color.gray.opacity(0.3), width: 0.5)
                .frame(height: 60)
            }
            
            // Row 4
            HStack(spacing: 0) {
                // Return to number keyboard
                Button(action: {
                    showingLetterKeyboard = false
                }) {
                    Text("123")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.black)
                        .background(Color.white)
                }
                .border(Color.gray.opacity(0.3), width: 0.5)
                .frame(height: 60)
                
                // Space button
                Button(action: {
                    appendToInput(" ")
                }) {
                    Text("space")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.black)
                        .background(Color.white)
                }
                .border(Color.gray.opacity(0.3), width: 0.5)
                .frame(height: 60)
            }
        }
    }
    
    // Letter button in small square format
    private func letterButton(_ letter: String) -> some View {
        Button(action: {
            appendToInput(letter)
        }) {
            Text(letter)
                .frame(width: 40, height: 40)
                .foregroundColor(.black)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
        }
        .padding(2)
    }
    
    // Functions keyboard
    private func functionsKeyboard() -> some View {
        VStack(spacing: 0) {
            // Row 1
            HStack(spacing: 0) {
                keyButton("|□|", color: .black)
                keyButton("f(x)", color: .black)
                keyButton("log₁₀", color: .black)
                keyButton("□√□", color: .black)
                keyButton("i", color: .black)
                keyButton("□,□,□", color: .black)
            }
            
            // Row 2
            HStack(spacing: 0) {
                keyButton("□ₙ", color: .black)
                keyButton("□(□)", color: .black)
                keyButton("log₂", color: .black)
                keyButton("□P□", color: .black)
                keyButton("z", color: .black)
                keyButton("!", color: .black)
            }
            
            // Row 3
            HStack(spacing: 0) {
                keyButton("e", color: .black)
                keyButton("f(x,y)", color: .black)
                keyButton("log□", color: .black)
                keyButton("□C□", color: .black)
                keyButton("z̄", color: .black)
                keyButton("[□]", color: .black)
            }
            
            // Row 4
            HStack(spacing: 0) {
                keyButton("exp", color: .black)
                keyButton("□(□□)", color: .black)
                keyButton("ln", color: .black)
                keyButton("(□)", color: .black)
                keyButton("sign", color: .black)
                keyButton("||□||", color: .black)
            }
        }
    }
    
    // Trigonometry keyboard
    private func trigonometryKeyboard() -> some View {
        VStack(spacing: 0) {
            // Row 1
            HStack(spacing: 0) {
                keyButton("rad", color: .black)
                keyButton("sin", color: .black)
                keyButton("cos", color: .black)
                keyButton("tan", color: .black)
                keyButton("cot", color: .black)
                keyButton("sec", color: .black)
            }
            
            // Row 2
            HStack(spacing: 0) {
                keyButton("□°", color: .black)
                keyButton("arcsin", color: .black)
                keyButton("arccos", color: .black)
                keyButton("arctan", color: .black)
                keyButton("arccot", color: .black)
                keyButton("arcsec", color: .black)
            }
            
            // Row 3
            HStack(spacing: 0) {
                keyButton("□°′", color: .black)
                keyButton("sinh", color: .black)
                keyButton("cosh", color: .black)
                keyButton("tanh", color: .black)
                keyButton("coth", color: .black)
                keyButton("sech", color: .black)
            }
            
            // Row 4
            HStack(spacing: 0) {
                keyButton("□°′″", color: .black)
                keyButton("arsinh", color: .black)
                keyButton("arcosh", color: .black)
                keyButton("artanh", color: .black)
                keyButton("arcoth", color: .black)
                keyButton("arsech", color: .black)
            }
        }
    }
    
    // Calculus keyboard
    private func calculusKeyboard() -> some View {
        VStack(spacing: 0) {
            // Row 1
            HStack(spacing: 0) {
                keyButton("lim□→□", color: .black)
                keyButton("d/dx□", color: .black)
                keyButton("∫□dx", color: .black)
                keyButton("dy/dx", color: .black)
                keyButton("aₙ", color: .black)
                keyButton("", color: .black)
            }
            
            // Row 2
            HStack(spacing: 0) {
                keyButton("lim□→□⁺", color: .black)
                keyButton("d/d□□", color: .black)
                keyButton("∫□d□", color: .black)
                keyButton("dx", color: .black)
                keyButton("□,□,□", color: .black)
                keyButton("", color: .black)
            }
            
            // Row 3
            HStack(spacing: 0) {
                keyButton("lim□→□⁻", color: .black)
                keyButton("d/d□□", color: .black)
                keyButton("∫ₐᵇ□d□", color: .black)
                keyButton("dy", color: .black)
                keyButton("", color: .black)
                keyButton("", color: .black)
            }
            
            // Row 4
            HStack(spacing: 0) {
                keyButton("∞", color: .black)
                keyButton("", color: .black)
                keyButton("∑ₐᵇ□", color: .black)
                keyButton("y′", color: .black)
                keyButton("", color: .black)
                keyButton("", color: .black)
            }
        }
    }
    
    // Reusable key button
    private func keyButton(_ text: String, color: Color = .black) -> some View {
        Button(action: {
            appendToInput(text)
        }) {
            Text(text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(color)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        }
        .border(Color.gray.opacity(0.3), width: 0.5)
        .frame(height: 60)
    }
    
    // Function to append text to input
    private func appendToInput(_ text: String) {
        inputText += text
        if !inputText.isEmpty {
            solveEquation(inputText)
        }
    }
    
    private func solveEquation(_ equation: String) {
        #if os(macOS)
        resultText = PythonBridge.solveMathProblem(equation)
        #else
        resultText = SwiftMathSolver.solve(equation)
        #endif
    }
}

// Extension for hex color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView(isShowing: .constant(true))
    }
}
