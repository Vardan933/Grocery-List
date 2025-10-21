import Foundation

struct GroceryItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: Category
    var isPurchased: Bool
    var isFavorite: Bool
    var notes: String
    var dateAdded: Date
    
    init(name: String, category: Category, isPurchased: Bool = false, isFavorite: Bool = false, notes: String = "", dateAdded: Date = Date()) {
        self.name = name
        self.category = category
        self.isPurchased = isPurchased
        self.isFavorite = isFavorite
        self.notes = notes
        self.dateAdded = dateAdded
    }
    
    enum Category: String, Codable, CaseIterable {
        case fruit = "Fruit"
        case dairy = "Dairy"
        case meat = "Meat"
        case vegetables = "Vegetables"
        case bakery = "Bakery"
        case other = "Other"
    }
} 
