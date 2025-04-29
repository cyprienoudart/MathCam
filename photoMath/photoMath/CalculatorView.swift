//
//  CalculatorView.swift
//  photoMath
//
//  Created by Cyprien OUDART on 4/28/25.
//

import SwiftUI

struct CalculatorView: View {
    @Binding var isShowing: Bool
    @State private var inputText: String = "Type a math problem..."
    @State private var isEditing: Bool = false
    @State private var selectedTab: Int = 0
    
    // Custom color
    let customRed = Color(hex: "#b62000")
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and close button
            HStack {
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
                }
                .padding(.trailing)
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
                
                TextField("", text: $inputText)
                    .font(.system(size: 20))
                    .padding(.horizontal)
                    .foregroundColor(.black)
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
            
            Spacer()
            
            // Function bar
            HStack {
                Button(action: {}) {
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
                    VStack {
                        Text("+ −")
                        Text("× ÷")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
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
            
            // Keyboard content based on selected tab
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
            .frame(height: 240)
            .background(Color.white)
        }
        .background(Color.white)
        .frame(height: UIScreen.main.bounds.height - 80) // Leave approximately 2cm at top
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // Basic operations keyboard
    private func basicOperationsKeyboard() -> some View {
        VStack(spacing: 0) {
            // Row 1
            HStack(spacing: 0) {
                keyButton("(", color: customRed)
                keyButton(")", color: customRed)
                keyButton("7")
                keyButton("8")
                keyButton("9")
                keyButton("÷", color: customRed)
            }
            
            // Row 2
            HStack(spacing: 0) {
                keyButton("□", color: customRed)
                keyButton("√", color: customRed)
                keyButton("4")
                keyButton("5")
                keyButton("6")
                keyButton("×", color: customRed)
            }
            
            // Row 3
            HStack(spacing: 0) {
                keyButton("^2", color: customRed)
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