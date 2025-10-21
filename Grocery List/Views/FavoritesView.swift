import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: GroceryListViewModel
    @State private var selectedItem: GroceryItem?
    
    var favoriteItems: [GroceryItem] {
        viewModel.items.filter { $0.isFavorite }
    }
    
    var body: some View {
        ScrollView {
            if favoriteItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Favorite Items")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("Add items to favorites by tapping the star icon")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 50)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(favoriteItems) { item in
                        FavoriteItemCard(item: item, viewModel: viewModel)
                            .onTapGesture {
                                selectedItem = item
                            }
                    }
                }
                .padding()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 120)
        }
        .sheet(item: $selectedItem) { item in
            AddEditItemView(viewModel: viewModel, editingItem: item)
        }
    }
}

struct FavoriteItemCard: View {
    let item: GroceryItem
    @ObservedObject var viewModel: GroceryListViewModel
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(ColorTheme.categoryColors[item.category])
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        var updatedItem = item
                        updatedItem.isFavorite.toggle()
                        viewModel.updateItem(updatedItem)
                    }
                }) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            Text(item.name)
                .font(.headline)
                .lineLimit(1)
            
            if !item.notes.isEmpty {
                Text(item.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Button(action: {
                    withAnimation(.spring()) {
                        var updatedItem = item
                        updatedItem.isPurchased.toggle()
                        viewModel.updateItem(updatedItem)
                    }
                }) {
                    Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isPurchased ? .green : .gray)
                }
                
                Spacer()
                
                Text(item.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .glassBackground()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ColorTheme.categoryColors[item.category]?.opacity(0.5) ?? .gray.opacity(0.5),
                            ColorTheme.categoryColors[item.category]?.opacity(0.2) ?? .gray.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(), value: isPressed)
        .onTapGesture {
            withAnimation(.spring()) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
    }
    
    private var iconName: String {
        switch item.category {
        case .fruit: return "applelogo"
        case .dairy: return "cup.and.saucer.fill"
        case .meat: return "fork.knife"
        case .vegetables: return "leaf.fill"
        case .bakery: return "birthday.cake.fill"
        case .other: return "cart.fill"
        }
    }
} 