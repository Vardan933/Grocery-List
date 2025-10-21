//
//  ContentView.swift
//  Grocery List
//
//  Created by Vardan Ghazaryan on 13.06.25.
//

import SwiftUI

struct ToolbarButtons: ViewModifier {
    let showingAddItem: Binding<Bool>
    let showingSettings: Binding<Bool>
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 10) {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showingAddItem.wrappedValue = true
                            }
                            
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [ColorTheme.accentColors[0], ColorTheme.accentColors[0].opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Button(action: { 
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showingSettings.wrappedValue = true
                            }
                            
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.gray, .gray.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "gear")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
    }
}

struct SortAndShareToolbar: ViewModifier {
    let viewModel: GroceryListViewModel
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SortAndShareMenu(viewModel: viewModel)
                }
            }
    }
}

extension View {
    func categoryToolbar(showingAddItem: Binding<Bool>, showingSettings: Binding<Bool>) -> some View {
        modifier(ToolbarButtons(showingAddItem: showingAddItem, showingSettings: showingSettings))
    }
    
    func sortAndShareToolbar(viewModel: GroceryListViewModel) -> some View {
        modifier(SortAndShareToolbar(viewModel: viewModel))
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    @State private var animateTabs = false
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                TabBarButton(
                    icon: icon(for: index),
                    title: title(for: index),
                    isSelected: selectedTab == index,
                    color: color(for: index)
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedTab = index
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                }
                .frame(maxWidth: .infinity)
                .offset(y: animateTabs ? 0 : 20)
                .opacity(animateTabs ? 1 : 0)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7)
                    .delay(Double(index) * 0.1),
                    value: animateTabs
                )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: .black.opacity(0.1),
            radius: 15,
            x: 0,
            y: 8
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateTabs = true
            }
        }
    }
    
    private func icon(for index: Int) -> String {
        switch index {
        case 0: return "square.grid.2x2"
        case 1: return "list.bullet"
        case 2: return "star.fill"
        case 3: return "chart.bar"
        default: return ""
        }
    }
    
    private func title(for index: Int) -> String {
        switch index {
        case 0: return "Categories"
        case 1: return "All Items"
        case 2: return "Favorites"
        case 3: return "Summary"
        default: return ""
        }
    }
    
    private func color(for index: Int) -> Color {
        switch index {
        case 0: return Color(red: 0.2, green: 0.5, blue: 1.0) // Bright blue
        case 1: return Color(red: 0.2, green: 0.8, blue: 0.4) // Vibrant green
        case 2: return Color(red: 1.0, green: 0.8, blue: 0.0) // Bright yellow
        case 3: return Color(red: 0.8, green: 0.4, blue: 1.0) // Vibrant purple
        default: return .gray
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
            action()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            isSelected ?
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [.gray, .gray.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? color : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color.opacity(0.15))
                            .matchedGeometryEffect(id: "TAB", in: namespace)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @Namespace private var namespace
}

struct ContentView: View {
    @StateObject private var viewModel = GroceryListViewModel()
    @State private var selectedTab = 0
    @State private var showingAddItem = false
    @State private var showingSettings = false
    @State private var searchText = ""
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var animateContent = false
    
    var filteredItems: [GroceryItem] {
        if searchText.isEmpty {
            return viewModel.sortedItems
        } else {
            return viewModel.sortedItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                item.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "4facfe").opacity(0.1),
                    Color(hex: "00f2fe").opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                NavigationStack {
                    CategoryGridView(viewModel: viewModel)
                        .navigationTitle("Categories")
                        .navigationBarTitleDisplayMode(.large)
                        .categoryToolbar(showingAddItem: $showingAddItem, showingSettings: $showingSettings)
                }
                .tag(0)
                
                NavigationStack {
                    ZStack {
                        if filteredItems.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "cart.badge.plus")
                                    .font(.system(size: 60, weight: .light))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.gray, .gray.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                VStack(spacing: 8) {
                                    Text("No Items Yet")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text("Add some items to get started")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        showingAddItem = true
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                        Text("Add First Item")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [ColorTheme.accentColors[0], ColorTheme.accentColors[0].opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                            .offset(y: animateContent ? 0 : 30)
                            .opacity(animateContent ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateContent)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredItems) { item in
                                    GroceryItemRow(viewModel: viewModel, item: item)
                                        .padding(.horizontal, 20)
                                        .transition(.asymmetric(
                                            insertion: .scale.combined(with: .opacity),
                                            removal: .scale.combined(with: .opacity)
                                        ))
                                }
                            }
                            .safeAreaInset(edge: .bottom) {
                                Color.clear.frame(height: 120)
                            }
                        }
                    }
                    .navigationTitle("All Items")
                    .navigationBarTitleDisplayMode(.large)
                    .searchable(text: $searchText, prompt: "Search items...")
                    .sortAndShareToolbar(viewModel: viewModel)
                }
                .tag(1)
                
                NavigationStack {
                    FavoritesView(viewModel: viewModel)
                        .navigationTitle("Favorites")
                        .navigationBarTitleDisplayMode(.large)
                        .sortAndShareToolbar(viewModel: viewModel)
                }
                .tag(2)
                
                NavigationStack {
                    SummaryView(viewModel: viewModel)
                        .navigationTitle("Summary")
                        .navigationBarTitleDisplayMode(.large)
                        .sortAndShareToolbar(viewModel: viewModel)
                }
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 8)
        }
        .sheet(isPresented: $showingAddItem) {
            AddEditItemView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateContent = true
            }
        }
    }
}

#Preview {
    ContentView()
}
