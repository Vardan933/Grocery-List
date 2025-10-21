import SwiftUI

struct AddEditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GroceryListViewModel
    
    @State private var name: String
    @State private var category: GroceryItem.Category
    @State private var notes: String
    @State private var isFavorite: Bool
    @State private var selectedCategoryIndex: Int
    @State private var isAnimating = false
    @State private var showSuccessAnimation = false
    
    private var editingItem: GroceryItem?
    
    init(viewModel: GroceryListViewModel, editingItem: GroceryItem? = nil) {
        self.viewModel = viewModel
        self.editingItem = editingItem
        
        _name = State(initialValue: editingItem?.name ?? "")
        _category = State(initialValue: editingItem?.category ?? .other)
        _notes = State(initialValue: editingItem?.notes ?? "")
        _isFavorite = State(initialValue: editingItem?.isFavorite ?? false)
        _selectedCategoryIndex = State(initialValue: GroceryItem.Category.allCases.firstIndex(of: editingItem?.category ?? .other) ?? 0)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "667eea").opacity(0.1),
                        Color(hex: "764ba2").opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header section
                        VStack(spacing: 16) {
                            // Icon and title
                            VStack(spacing: 12) {
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
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: editingItem == nil ? "plus.circle.fill" : "pencil.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    ColorTheme.categoryColors[category] ?? .blue,
                                                    ColorTheme.categoryColors[category]?.opacity(0.7) ?? .blue.opacity(0.7)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isAnimating)
                                
                                Text(editingItem == nil ? "Add New Item" : "Edit Item")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Item name input
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(ColorTheme.categoryColors[category])
                                Text("Item Name")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            TextField("Enter item name...", text: $name)
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            ColorTheme.categoryColors[category]?.opacity(0.3) ?? .gray.opacity(0.3),
                                                            ColorTheme.categoryColors[category]?.opacity(0.1) ?? .gray.opacity(0.1)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                                .onChange(of: name) { _ in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isAnimating = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            isAnimating = false
                                        }
                                    }
                                }
                        }
                        .padding(.horizontal, 20)
                        
                        // Category selection
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(ColorTheme.categoryColors[category])
                                Text("Category")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(Array(GroceryItem.Category.allCases.enumerated()), id: \.element) { index, cat in
                                    CategorySelectionCard(
                                        category: cat,
                                        isSelected: category == cat,
                                        action: {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                category = cat
                                                selectedCategoryIndex = index
                                                
                                                // Haptic feedback
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                                impactFeedback.impactOccurred()
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Notes input
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(ColorTheme.categoryColors[category])
                                Text("Notes (Optional)")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            TextField("Add notes...", text: $notes, axis: .vertical)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .lineLimit(3...6)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            ColorTheme.categoryColors[category]?.opacity(0.3) ?? .gray.opacity(0.3),
                                                            ColorTheme.categoryColors[category]?.opacity(0.1) ?? .gray.opacity(0.1)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                        }
                        .padding(.horizontal, 20)
                        
                        // Favorite toggle
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(ColorTheme.warningColor)
                                Text("Add to Favorites")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isFavorite.toggle()
                                    
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }
                            }) {
                                HStack {
                                    Image(systemName: isFavorite ? "star.fill" : "star")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(
                                            isFavorite ?
                                            LinearGradient(
                                                colors: [ColorTheme.warningColor, ColorTheme.warningColor.opacity(0.7)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                colors: [.gray, .gray.opacity(0.7)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    Text(isFavorite ? "Added to Favorites" : "Add to Favorites")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(isFavorite ? ColorTheme.warningColor : .secondary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            isFavorite ? ColorTheme.warningColor.opacity(0.3) : .gray.opacity(0.3),
                                                            isFavorite ? ColorTheme.warningColor.opacity(0.1) : .gray.opacity(0.1)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Action buttons
                        VStack(spacing: 16) {
                            Button(action: saveItem) {
                                HStack(spacing: 12) {
                                    if showSuccessAnimation {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                            .scaleEffect(showSuccessAnimation ? 1.2 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showSuccessAnimation)
                                    } else {
                                        Image(systemName: editingItem == nil ? "plus.circle.fill" : "checkmark.circle.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(editingItem == nil ? "Add Item" : "Save Changes")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: name.isEmpty ? 
                                            [.gray, .gray.opacity(0.7)] :
                                            [
                                                ColorTheme.categoryColors[category] ?? .blue,
                                                ColorTheme.categoryColors[category]?.opacity(0.7) ?? .blue.opacity(0.7)
                                            ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(
                                    color: (ColorTheme.categoryColors[category] ?? .blue).opacity(0.3),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            }
                            .disabled(name.isEmpty)
                            .scaleEffect(name.isEmpty ? 0.95 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: name.isEmpty)
                            
                            Button(action: { dismiss() }) {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAnimating = false
                }
            }
        }
    }
    
    private func saveItem() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccessAnimation = true
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let editingItem = editingItem {
                let updatedItem = GroceryItem(
                    name: name,
                    category: category,
                    isPurchased: editingItem.isPurchased,
                    isFavorite: isFavorite,
                    notes: notes,
                    dateAdded: editingItem.dateAdded
                )
                viewModel.updateItem(updatedItem)
            } else {
                let newItem = GroceryItem(
                    name: name,
                    category: category,
                    isPurchased: false,
                    isFavorite: isFavorite,
                    notes: notes
                )
                viewModel.addItem(newItem)
            }
            dismiss()
        }
    }
}

struct CategorySelectionCard: View {
    let category: GroceryItem.Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
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
                
                Text(category.rawValue)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? ColorTheme.categoryColors[category] : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ColorTheme.categoryColors[category])
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        ColorTheme.categoryColors[category]?.opacity(isSelected ? 0.6 : 0.2) ?? .gray.opacity(0.2),
                                        ColorTheme.categoryColors[category]?.opacity(isSelected ? 0.3 : 0.1) ?? .gray.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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