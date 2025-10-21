import Foundation
import SwiftUI

class GroceryListViewModel: ObservableObject {
    @Published var items: [GroceryItem] = []
    @Published var showingClearConfirmation = false
    @Published var sortOption: SortOption = .name
    @Published var showingShareSheet = false
    @Published var recentlyAddedItems: [GroceryItem] = []
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case category = "Category"
        case purchased = "Purchased Status"
        case dateAdded = "Date Added"
        case favorites = "Favorites First"
    }
    
    init() {
        loadItems()
        if items.isEmpty {
            addSampleData()
        }
        updateRecentlyAddedItems()
    }
    
    var sortedItems: [GroceryItem] {
        switch sortOption {
        case .name:
            return items.sorted { $0.name < $1.name }
        case .category:
            return items.sorted { $0.category.rawValue < $1.category.rawValue }
        case .purchased:
            return items.sorted { !$0.isPurchased && $1.isPurchased }
        case .dateAdded:
            return items.sorted { $0.dateAdded > $1.dateAdded }
        case .favorites:
            return items.sorted { $0.isFavorite && !$1.isFavorite }
        }
    }
    
    var favoriteItems: [GroceryItem] {
        return items.filter { $0.isFavorite }
    }
    
    var purchasedItems: [GroceryItem] {
        return items.filter { $0.isPurchased }
    }
    
    var unpurchasedItems: [GroceryItem] {
        return items.filter { !$0.isPurchased }
    }
    
    var itemsByCategory: [GroceryItem.Category: [GroceryItem]] {
        return Dictionary(grouping: items) { $0.category }
    }
    
    var categoryStats: [GroceryItem.Category: CategoryStats] {
        var stats: [GroceryItem.Category: CategoryStats] = [:]
        
        for category in GroceryItem.Category.allCases {
            let categoryItems = items.filter { $0.category == category }
            let purchased = categoryItems.filter { $0.isPurchased }.count
            let total = categoryItems.count
            
            stats[category] = CategoryStats(
                total: total,
                purchased: purchased,
                remaining: total - purchased,
                percentage: total > 0 ? Double(purchased) / Double(total) : 0
            )
        }
        
        return stats
    }
    
    func addItem(_ item: GroceryItem) {
        items.append(item)
        saveItems()
        updateRecentlyAddedItems()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func updateItem(_ item: GroceryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveItems()
            updateRecentlyAddedItems()
        }
    }
    
    func deleteItem(_ item: GroceryItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
        updateRecentlyAddedItems()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    func togglePurchased(_ item: GroceryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isPurchased.toggle()
            saveItems()
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    func toggleFavorite(_ item: GroceryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFavorite.toggle()
            saveItems()
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    func clearAllItems() {
        items.removeAll()
        saveItems()
        updateRecentlyAddedItems()
    }
    
    func clearPurchasedItems() {
        items.removeAll { $0.isPurchased }
        saveItems()
        updateRecentlyAddedItems()
    }
    
    func resetToSampleData() {
        items.removeAll()
        addSampleData()
        updateRecentlyAddedItems()
    }
    
    func getSmartSuggestions() -> [String] {
        let commonItems = [
            "Milk", "Bread", "Eggs", "Bananas", "Apples", "Chicken", "Rice", "Pasta",
            "Tomatoes", "Onions", "Cheese", "Yogurt", "Butter", "Olive Oil", "Salt",
            "Sugar", "Flour", "Potatoes", "Carrots", "Broccoli", "Spinach", "Lettuce"
        ]
        
        let existingItems = Set(items.map { $0.name.lowercased() })
        return commonItems.filter { !existingItems.contains($0.lowercased()) }
    }
    
    func getCategorySuggestions(for category: GroceryItem.Category) -> [String] {
        let suggestions: [GroceryItem.Category: [String]] = [
            .fruit: ["Apples", "Bananas", "Oranges", "Strawberries", "Grapes", "Pineapple", "Mango", "Kiwi"],
            .dairy: ["Milk", "Cheese", "Yogurt", "Butter", "Cream", "Cottage Cheese", "Sour Cream"],
            .meat: ["Chicken", "Beef", "Pork", "Fish", "Turkey", "Lamb", "Bacon", "Sausage"],
            .vegetables: ["Carrots", "Broccoli", "Spinach", "Lettuce", "Tomatoes", "Onions", "Potatoes", "Bell Peppers"],
            .bakery: ["Bread", "Croissants", "Muffins", "Bagels", "Cake", "Cookies", "Donuts"],
            .other: ["Rice", "Pasta", "Olive Oil", "Salt", "Sugar", "Flour", "Spices", "Canned Goods"]
        ]
        
        let existingItems = Set(items.map { $0.name.lowercased() })
        return suggestions[category]?.filter { !existingItems.contains($0.lowercased()) } ?? []
    }
    
    func shareList() -> String {
        var shareText = "🛒 My Shopping List\n\n"
        
        // Group items by category
        let groupedItems = Dictionary(grouping: items) { $0.category }
        
        for (category, items) in groupedItems.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            shareText += "📂 \(category.rawValue):\n"
            for item in items.sorted(by: { $0.name < $1.name }) {
                let checkmark = item.isPurchased ? "✅" : "⬜️"
                let star = item.isFavorite ? "⭐️" : ""
                shareText += "\(checkmark) \(item.name)\(star)\n"
            }
            shareText += "\n"
        }
        
        let totalItems = items.count
        let purchasedItems = items.filter { $0.isPurchased }.count
        let remainingItems = totalItems - purchasedItems
        
        shareText += "📊 Summary:\n"
        shareText += "Total: \(totalItems) items\n"
        shareText += "Purchased: \(purchasedItems) items\n"
        shareText += "Remaining: \(remainingItems) items\n"
        
        return shareText
    }
    
    private func updateRecentlyAddedItems() {
        let sortedByDate = items.sorted { $0.dateAdded > $1.dateAdded }
        recentlyAddedItems = Array(sortedByDate.prefix(5))
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "groceryItems")
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "groceryItems"),
           let decoded = try? JSONDecoder().decode([GroceryItem].self, from: data) {
            items = decoded
        }
    }
    
    private func addSampleData() {
        let sampleItems = [
            GroceryItem(name: "Apples", category: .fruit, isPurchased: false, isFavorite: true),
            GroceryItem(name: "Bananas", category: .fruit, isPurchased: false),
            GroceryItem(name: "Milk", category: .dairy, isPurchased: false, isFavorite: true),
            GroceryItem(name: "Cheese", category: .dairy, isPurchased: false),
            GroceryItem(name: "Chicken", category: .meat, isPurchased: false),
            GroceryItem(name: "Beef", category: .meat, isPurchased: false),
            GroceryItem(name: "Carrots", category: .vegetables, isPurchased: false),
            GroceryItem(name: "Broccoli", category: .vegetables, isPurchased: false),
            GroceryItem(name: "Bread", category: .bakery, isPurchased: false),
            GroceryItem(name: "Cereal", category: .other, isPurchased: false)
        ]
        
        items = sampleItems
        saveItems()
    }
}

struct CategoryStats {
    let total: Int
    let purchased: Int
    let remaining: Int
    let percentage: Double
} 