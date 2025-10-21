import SwiftUI

struct CategoryWrapper: Identifiable {
    let id = UUID()
    let category: GroceryItem.Category
}

struct CategoryGridView: View {
    @ObservedObject var viewModel: GroceryListViewModel
    @State private var showingAddItem = false
    @State private var selectedCategory: GroceryItem.Category?
    @State private var quickAddText = ""
    @State private var quickAddCategory: GroceryItem.Category = .other
    @State private var isAnimating = false
    @State private var animateCards = false
    @State private var showingCategoryPicker = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "f093fb").opacity(0.1),
                Color(hex: "f5576c").opacity(0.05)
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
        .sheet(isPresented: $showingAddItem) {
            AddEditItemView(viewModel: viewModel)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateCards = true
            }
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    isAnimating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isAnimating = false
                    }
                }
            }
        }
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    categoriesGrid
                    if let selectedCategory = selectedCategory {
                        categoryItemsView(selectedCategory: selectedCategory)
                    }
                }
                .padding(.vertical, 20)
                .padding(.bottom, 140) // Increased padding for quick add panel + tab bar
            }
            
            // Quick add panel at bottom, above tab bar
            quickAddPanel
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Space above tab bar
        }
    }

    private var quickAddPanel: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick Add")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Add items instantly")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [ColorTheme.warningColor.opacity(0.2), ColorTheme.warningColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTheme.warningColor, ColorTheme.warningColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isAnimating)
            }
            
            HStack(spacing: 6) {
                TextField("Add item...", text: $quickAddText)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                ColorTheme.warningColor.opacity(0.3),
                                                ColorTheme.warningColor.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .submitLabel(.done)
                    .onSubmit {
                        addQuickItem()
                    }
                
                Button(action: {
                    showingCategoryPicker = true
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: iconName)
                            .font(.system(size: 10, weight: .semibold))
                        Text(quickAddCategory.rawValue)
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(ColorTheme.categoryColors[quickAddCategory])
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(ColorTheme.categoryColors[quickAddCategory]?.opacity(0.15) ?? .gray.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(ColorTheme.categoryColors[quickAddCategory]?.opacity(0.3) ?? .gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                Button(action: addQuickItem) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [ColorTheme.warningColor, ColorTheme.warningColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
                }
                .disabled(quickAddText.isEmpty)
                .opacity(quickAddText.isEmpty ? 0.6 : 1.0)
            }
        }
        .padding(10)
        .frostedGlassBackground(cornerRadius: 14)
        .shadow(
            color: ColorTheme.warningColor.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        .confirmationDialog("Select Category", isPresented: $showingCategoryPicker) {
            ForEach(GroceryItem.Category.allCases, id: \.self) { category in
                Button(category.rawValue) {
                    quickAddCategory = category
                }
            }
        }
    }
    
    private var iconName: String {
        switch quickAddCategory {
        case .fruit: return "applelogo"
        case .dairy: return "cup.and.saucer.fill"
        case .meat: return "fork.knife"
        case .vegetables: return "leaf.fill"
        case .bakery: return "birthday.cake.fill"
        case .other: return "cart.fill"
        }
    }

    private var categoriesGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Categories")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(viewModel.items.count) total items")
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
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(GroceryItem.Category.allCases.enumerated()), id: \.element) { index, category in
                    CategoryCard(
                        category: category,
                        itemCount: viewModel.items.filter { $0.category == category }.count,
                        isSelected: selectedCategory == category,
                        onSelect: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                if selectedCategory == category {
                                    selectedCategory = nil
                                } else {
                                    selectedCategory = category
                                }
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }
                        }
                    )
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7)
                        .delay(Double(index) * 0.1),
                        value: animateCards
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func categoryItemsView(selectedCategory: GroceryItem.Category) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedCategory.rawValue)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("\(viewModel.items.filter { $0.category == selectedCategory }.count) items")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        self.selectedCategory = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.gray, .gray.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .padding(.horizontal, 20)
            LazyVStack(spacing: 12) {
                ForEach(viewModel.items.filter { $0.category == selectedCategory }) { item in
                    GroceryItemRow(viewModel: viewModel, item: item)
                        .padding(.horizontal, 20)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }
    
    private func addQuickItem() {
        guard !quickAddText.isEmpty else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            let newItem = GroceryItem(
                name: quickAddText,
                category: quickAddCategory
            )
            viewModel.addItem(newItem)
            quickAddText = ""
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
}

struct CategoryCard: View {
    let category: GroceryItem.Category
    let itemCount: Int
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 16) {
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
                    .frame(width: 70, height: 70)
                
                Image(systemName: iconName)
                    .font(.system(size: 28, weight: .semibold))
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
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            
            VStack(spacing: 6) {
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(ColorTheme.categoryColors[category])
                    
                    Text("\(itemCount) items")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frostedGlassBackground(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            ColorTheme.categoryColors[category]?.opacity(isSelected ? 0.8 : 0.3) ?? .gray.opacity(0.3),
                            ColorTheme.categoryColors[category]?.opacity(isSelected ? 0.4 : 0.1) ?? .gray.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .shadow(
            color: (ColorTheme.categoryColors[category] ?? .gray).opacity(isSelected ? 0.2 : 0.1),
            radius: isSelected ? 12 : 6,
            x: 0,
            y: 4
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
            onSelect()
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

struct QuickAddView: View {
    @ObservedObject var viewModel: GroceryListViewModel
    @State private var showingCategoryPicker = false
    @State private var selectedCategory: GroceryItem.Category = .other
    @State private var itemName = ""
    
    var body: some View {
        HStack {
            TextField("Quick add item...", text: $itemName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                showingCategoryPicker = true
            }) {
                Image(systemName: "tag.fill")
                    .foregroundColor(ColorTheme.categoryColors[selectedCategory])
            }
            
            Button(action: addItem) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(ColorTheme.categoryColors[selectedCategory])
                    .font(.title2)
            }
        }
        .padding()
        .glassBackground()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: ColorTheme.gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .confirmationDialog("Select Category", isPresented: $showingCategoryPicker) {
            ForEach(GroceryItem.Category.allCases, id: \.self) { category in
                Button(category.rawValue) {
                    selectedCategory = category
                }
            }
        }
    }
    
    private func addItem() {
        guard !itemName.isEmpty else { return }
        let newItem = GroceryItem(name: itemName, category: selectedCategory, isPurchased: false)
        viewModel.addItem(newItem)
        itemName = ""
    }
}

struct CategoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GroceryListViewModel
    let category: GroceryItem.Category
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items.filter { $0.category == category }) { item in
                    GroceryItemRow(viewModel: viewModel, item: item)
                }
            }
            .navigationTitle(category.rawValue)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
} 
