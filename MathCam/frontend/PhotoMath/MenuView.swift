//
//  MenuView.swift
//  photoMath
//
//  Created by Cyprien OUDART on 4/28/25.
//

import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String?
    let isHighlighted: Bool
}

struct MenuView: View {
    @Binding var isShowing: Bool
    
    let menuItems: [MenuItem] = [
        MenuItem(icon: "globe", title: "Language", subtitle: "English", isHighlighted: false),
        MenuItem(icon: "gearshape", title: "Settings", subtitle: nil, isHighlighted: false),
        MenuItem(icon: "questionmark.circle", title: "Help center", subtitle: nil, isHighlighted: false),
        MenuItem(icon: "info.circle", title: "About us", subtitle: nil, isHighlighted: false),
        MenuItem(icon: "plus", title: "Photomath Plus", subtitle: nil, isHighlighted: true)
    ]
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isShowing = false
                }
            
            // Menu panel
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Image(systemName: "doc.text.image")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                            .padding(.trailing, 8)
                        
                        Text("photomath")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .padding(.top, 20)
                    
                    Divider()
                    
                    // Menu items
                    ForEach(menuItems) { item in
                        HStack {
                            Image(systemName: item.icon)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(item.isHighlighted ? .orange : .gray)
                                .padding(.trailing, 15)
                            
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .foregroundColor(item.isHighlighted ? .orange : .black)
                                    .font(.headline)
                                
                                if let subtitle = item.subtitle {
                                    Text(subtitle)
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .frame(width: 250)
                .background(Color.white)
                .edgesIgnoringSafeArea(.vertical)
                
                Spacer()
            }
        }
    }
}

#Preview {
    MenuView(isShowing: .constant(true))
}