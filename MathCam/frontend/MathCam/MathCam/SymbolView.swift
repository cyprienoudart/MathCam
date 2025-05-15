//
//  SymbolView.swift
//  photoMath
//
//  Created by Cyprien OUDART on 4/28/25.
//

import SwiftUI

struct FractionSymbolView: View {
    var body: some View {
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
    }
}

struct SquareRootSymbolView: View {
    var color: Color
    
    var body: some View {
        ZStack {
            Text("√")
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Rectangle()
                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                .frame(width: 20, height: 20)
                .offset(x: 10)
        }
    }
}

struct SquarePowerSymbolView: View {
    var color: Color
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                .frame(width: 20, height: 20)
            
            Text("²")
                .font(.system(size: 16))
                .foregroundColor(color)
                .offset(x: 15, y: -10)
        }
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FractionSymbolView()
            SquareRootSymbolView(color: .red)
            SquarePowerSymbolView(color: .red)
        }
        .padding()
    }
}