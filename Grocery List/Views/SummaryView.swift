import SwiftUI

struct SummaryView: View {
    @ObservedObject var viewModel: GroceryListViewModel
    @State private var animateProgress = false
    @State private var animateStats = false
    @State private var animateCharts = false
    
    var totalItems: Int {
        viewModel.items.count
    }
    
    var purchasedItems: Int {
        viewModel.purchasedItems.count
    }
    
    var progress: Double {
        guard totalItems > 0 else { return 0 }
        return Double(purchasedItems) / Double(totalItems)
    }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "43e97b").opacity(0.1),
                Color(hex: "38f9d7").opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            mainContent
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateProgress = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animateStats = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animateCharts = true
                }
            }
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                statsSection
                categoryBreakdownSection
                if !viewModel.recentlyAddedItems.isEmpty {
                    recentActivitySection
                }
                let suggestions = viewModel.getSmartSuggestions()
                if !suggestions.isEmpty {
                    smartSuggestionsSection(suggestions: suggestions)
                }
            }
            .padding(.bottom, 120)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 20) {
            Text("Shopping Progress")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.gray.opacity(0.2), .gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 25
                    )
                    .frame(width: 180, height: 180)
                Circle()
                    .trim(from: 0, to: animateProgress ? progress : 0)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                ColorTheme.successColor,
                                ColorTheme.successColor.opacity(0.7),
                                ColorTheme.successColor.opacity(0.5)
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 25, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5), value: animateProgress)
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Complete")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .scaleEffect(animateProgress ? 1.0 : 0.8)
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateProgress)
        }
        .padding(.top, 20)
    }

    private var statsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            EnhancedStatCard(
                title: "Total Items",
                value: "\(totalItems)",
                icon: "cart.fill",
                color: ColorTheme.accentColors[0],
                delay: 0.1
            )
            EnhancedStatCard(
                title: "Purchased",
                value: "\(purchasedItems)",
                icon: "checkmark.circle.fill",
                color: ColorTheme.successColor,
                delay: 0.2
            )
            EnhancedStatCard(
                title: "Remaining",
                value: "\(totalItems - purchasedItems)",
                icon: "clock.fill",
                color: ColorTheme.warningColor,
                delay: 0.3
            )
            EnhancedStatCard(
                title: "Favorites",
                value: "\(viewModel.favoriteItems.count)",
                icon: "star.fill",
                color: ColorTheme.warningColor,
                delay: 0.4
            )
        }
        .padding(.horizontal, 20)
    }

    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Category Breakdown")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(viewModel.itemsByCategory.count) categories")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .padding(.horizontal, 20)
            let sortedKeys = viewModel.categoryStats.keys.sorted { $0.rawValue < $1.rawValue }
            LazyVStack(spacing: 12) {
                ForEach(sortedKeys, id: \.self) { category in
                    if let stats = viewModel.categoryStats[category] {
                        EnhancedCategoryStatCard(
                            category: category,
                            stats: stats,
                            delay: Double(sortedKeys.firstIndex(of: category) ?? 0) * 0.1
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            LazyVStack(spacing: 8) {
                ForEach(viewModel.recentlyAddedItems.prefix(3)) { item in
                    RecentActivityRow(item: item)
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    private func smartSuggestionsSection(suggestions: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Smart Suggestions")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ColorTheme.warningColor, ColorTheme.warningColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(suggestions.prefix(8), id: \.self) { suggestion in
                        SuggestionChip(text: suggestion)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct EnhancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let delay: Double
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(animate ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animate)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frostedGlassBackground(cornerRadius: 16)
        .shadow(
            color: color.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        .offset(y: animate ? 0 : 30)
        .opacity(animate ? 1 : 0)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7)
            .delay(delay),
            value: animate
        )
        .onAppear {
            animate = true
        }
    }
}

struct EnhancedCategoryStatCard: View {
    let category: GroceryItem.Category
    let stats: CategoryStats
    let delay: Double
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorTheme.categoryColors[category]?.opacity(0.2) ?? .gray.opacity(0.2),
                                ColorTheme.categoryColors[category]?.opacity(0.1) ?? .gray.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                ColorTheme.categoryColors[category] ?? .gray,
                                ColorTheme.categoryColors[category]?.opacity(0.7) ?? .gray.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(category.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(stats.purchased)/\(stats.total)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ColorTheme.categoryColors[category] ?? .gray,
                                        ColorTheme.categoryColors[category]?.opacity(0.7) ?? .gray.opacity(0.7)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * (animate ? stats.percentage : 0), height: 8)
                            .animation(.easeInOut(duration: 1.0).delay(delay), value: animate)
                    }
                }
                .frame(height: 8)
            }
            
            Spacer()
        }
        .padding(16)
        .frostedGlassBackground(cornerRadius: 16)
        .shadow(
            color: (ColorTheme.categoryColors[category] ?? .gray).opacity(0.1),
            radius: 6,
            x: 0,
            y: 3
        )
        .offset(x: animate ? 0 : -30)
        .opacity(animate ? 1 : 0)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7)
            .delay(delay),
            value: animate
        )
        .onAppear {
            animate = true
        }
    }
    
    private var iconName: String {
        switch category {
        case .fruit: return "applelogo"
        case .dairy: return "cup.and.saucer.fill"
        case .meat: return "fork.knife"
        case .vegetables: return "leaf.fill"
        case .bakery: return "birthday.cake.fill"
        case .other: return "cart.fill"
        }
    }
}

struct RecentActivityRow: View {
    let item: GroceryItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ColorTheme.successColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Added \(item.dateAdded.timeAgoDisplay())")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(item.category.rawValue)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(ColorTheme.categoryColors[item.category])
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(ColorTheme.categoryColors[item.category]?.opacity(0.15) ?? .gray.opacity(0.15))
                )
        }
        .padding(12)
        .glassBackground(cornerRadius: 12)
    }
}

struct SuggestionChip: View {
    let text: String
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }) {
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
} 
