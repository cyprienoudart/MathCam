//
//  CalculatorView.swift
//  photoMath
//
//  Created by Cyprien OUDART on 4/28/25.
//

import SwiftUI

struct CalculatorView: View {
    @Binding var isShowing: Bool
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Calculator")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button("Close") {
                    isShowing = false
                }
                .foregroundColor(.red)
                .padding()
            }
            .background(Color.white)
            .border(Color.gray.opacity(0.3), width: 1)
            
            // Input area
            VStack {
                TextField("Type a math problem...", text: $inputText)
                    .padding()
                    .foregroundColor(.gray)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .offset(y: 12),
                        alignment: .bottom
                    )
                
                Spacer()
            }
            .frame(height: 200)
            .background(Color.white)
            
            // Function bar
            HStack {
                Text("abc")
                    .frame(maxWidth: .infinity)
                
                Image(systemName: "clock")
                    .frame(maxWidth: .infinity)
                
                Image(systemName: "arrow.left")
                    .frame(maxWidth: .infinity)
                
                Image(systemName: "arrow.right")
                    .frame(maxWidth: .infinity)
                
                Image(systemName: "delete.left")
                    .frame(maxWidth: .infinity)
                
                Image(systemName: "xmark.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .background(Color.white)
            .border(Color.gray.opacity(0.3), width: 1)
            
            // Function buttons
            HStack {
                Button(action: {}) {
                    VStack {
                        Text("+ −")
                        Text("× ÷")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button(action: {}) {
                    VStack {
                        Text("f(x)  e")
                        Text("log  ln")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Button(action: {}) {
                    VStack {
                        Text("sin cos")
                        Text("tan cot")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Button(action: {}) {
                    VStack {
                        Text("lim  dx")
                        Text("∫ ∞")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 5)
            .background(Color.white)
            
            // Number pad
            VStack(spacing: 0) {
                // Row 1
                HStack(spacing: 0) {
                    Button(action: {}) {
                        Text("( )")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text(">")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("7")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("8")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("9")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("÷")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                }
                .frame(height: 50)
                
                // Row 2
                HStack(spacing: 0) {
                    Button(action: {}) {
                        Text("□")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("√□")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("4")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("5")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("6")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("×")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                }
                .frame(height: 50)
                
                // Row 3
                HStack(spacing: 0) {
                    Button(action: {}) {
                        Text("□²")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("x")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("1")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("2")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("3")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("−")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                }
                .frame(height: 50)
                
                // Row 4
                HStack(spacing: 0) {
                    Button(action: {}) {
                        Text("π")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("%")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("0")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text(".")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("=")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                    
                    Button(action: {}) {
                        Text("+")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                }
                .frame(height: 50)
            }
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    CalculatorView(isShowing: .constant(true))
}