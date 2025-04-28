//
//  ContentView.swift
//  photoMath
//
//  Created by Cyprien OUDART on 4/28/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingCamera = true
    @State private var capturedImage: UIImage? = nil
    @State private var showingCalculator = false
    @State private var showingHistory = false
    @State private var showingMenu = false
    
    var body: some View {
        ZStack {
            // Grey background instead of camera
            Color.gray.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            // Main content overlay
            VStack {
                // Top navigation bar
                HStack {
                    Button(action: {
                        showingMenu = true
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Help action
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                Spacer()
                
                // Camera frame guides
                ZStack {
                    // Corner brackets
                    VStack {
                        HStack {
                            Image(systemName: "l.square.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(180))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "l.square.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(270))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "l.square.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(90))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "l.square.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(40)
                    
                    // Center crosshair
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: 400)
                
                Spacer()
                
                // Text prompt
                Text("Take a picture of a math problem")
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .padding(.bottom, 20)
                
                // Bottom controls
                HStack {
                    // Calculator button
                    Button(action: {
                        showingCalculator = true
                    }) {
                        VStack {
                            Image(systemName: "calculator")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Text("Calculator")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 80)
                    
                    Spacer()
                    
                    // Camera capture button
                    Button(action: {
                        // Capture photo action
                    }) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 80, height: 80)
                            )
                    }
                    
                    Spacer()
                    
                    // Empty space to balance layout
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 80)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                
                // Bottom navigation bar
                HStack(spacing: 40) {
                    Button(action: {
                        showingHistory = true
                    }) {
                        Image(systemName: "photo")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 30)
            }
            
            // Show calculator sheet
            if showingCalculator {
                CalculatorView(isShowing: $showingCalculator)
                    .transition(.move(edge: .bottom))
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Show history sheet
            if showingHistory {
                HistoryView(isShowing: $showingHistory)
                    .transition(.move(edge: .bottom))
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Show menu sheet
            if showingMenu {
                MenuView(isShowing: $showingMenu)
                    .transition(.move(edge: .leading))
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .animation(.default, value: showingCalculator)
        .animation(.default, value: showingHistory)
        .animation(.default, value: showingMenu)
    }
}

#Preview {
    ContentView()
}
