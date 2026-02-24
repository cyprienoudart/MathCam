//
//  HistoryView.swift
//  photoMath
//
//  Created by Cyprien OUDART on 4/28/25.
//

import SwiftUI

struct HistoryItem: Identifiable {
    let id = UUID()
    let date: String
    let itemCount: String
    let expression: String
    let isExpanded: Bool
}

struct HistoryView: View {
    @Binding var isShowing: Bool
    @State private var selectedTab = 0
    @State private var sortByWeek = false
    
    let historyItems: [HistoryItem] = [
        HistoryItem(date: "Mar 18, 2025", itemCount: "1 item", expression: "5sin(5)⁴cos(5)", isExpanded: true),
        HistoryItem(date: "Feb 7, 2025", itemCount: "1 item", expression: "", isExpanded: false),
        HistoryItem(date: "Jul 20, 2024", itemCount: "1 item", expression: "", isExpanded: false),
        HistoryItem(date: "Jun 19, 2024", itemCount: "2 items", expression: "", isExpanded: false),
        HistoryItem(date: "Mar 2, 2024", itemCount: "2 items", expression: "", isExpanded: false),
        HistoryItem(date: "Feb 18, 2024", itemCount: "4 items", expression: "", isExpanded: false),
        HistoryItem(date: "Oct 6, 2023", itemCount: "2 items", expression: "", isExpanded: false),
        HistoryItem(date: "Sep 29, 2023", itemCount: "1 item", expression: "", isExpanded: false),
        HistoryItem(date: "Sep 25, 2023", itemCount: "1 item", expression: "", isExpanded: false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Edit") {
                    // Edit action
                }
                .foregroundColor(.red)
                .padding()
                
                Spacer()
                
                Text("My Stuff")
                    .font(.headline)
                
                Spacer()
                
                Button("Close") {
                    isShowing = false
                }
                .foregroundColor(.red)
                .padding()
            }
            
            // Tab selector
            HStack(spacing: 0) {
                Button(action: {
                    selectedTab = 0
                }) {
                    Text("History")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundColor(selectedTab == 0 ? .red : .black)
                }
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(selectedTab == 0 ? .red : .clear)
                        .padding(.top, 30),
                    alignment: .bottom
                )
                
                Button(action: {
                    selectedTab = 1
                }) {
                    Text("Bookmarks")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundColor(selectedTab == 1 ? .red : .black)
                }
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(selectedTab == 1 ? .red : .clear)
                        .padding(.top, 30),
                    alignment: .bottom
                )
            }
            .padding(.horizontal)
            .background(Color.white)
            .border(Color.gray.opacity(0.3), width: 1)
            
            // Sort toggle
            HStack {
                Text("Sort by week")
                    .foregroundColor(.black)
                
                Spacer()
                
                Toggle("", isOn: $sortByWeek)
                    .labelsHidden()
            }
            .padding()
            .background(Color.white)
            
            // History list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(historyItems) { item in
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: item.isExpanded ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.gray)
                                
                                Text(item.date)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text(item.itemCount)
                                    .foregroundColor(.gray)
                                
                                Image(systemName: "bookmark")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            
                            if item.isExpanded && !item.expression.isEmpty {
                                HStack {
                                    Text(item.expression)
                                        .padding()
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "bookmark")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                                .background(Color.white)
                                .border(Color.gray.opacity(0.3), width: 1)
                                .padding(.horizontal)
                            }
                        }
                        .background(Color.white)
                        .border(Color.gray.opacity(0.3), width: 0.5)
                    }
                }
            }
            .background(Color.white)
        }
        .background(Color.white)
    }
}

#Preview {
    HistoryView(isShowing: .constant(true))
}