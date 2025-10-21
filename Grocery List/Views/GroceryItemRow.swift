import SwiftUI

struct GroceryItemRow: View {
    @ObservedObject var viewModel: GroceryListViewModel
    let item: GroceryItem
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var isPressed = false
    @State private var showDeleteButton = false
    @State private var animationPhase: AnimationPhase = .idle
    
    enum AnimationPhase {
        case idle, pressing, completing, favoriting
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox with enhanced animation
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    animationPhase = .completing
                    var updatedItem = item
                    updatedItem.isPurchased.toggle()
                    viewModel.updateItem(updatedItem)
                    
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animationPhase = .idle
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: item.isPurchased ? 
                                    [ColorTheme.successColor, ColorTheme.successColor.opacity(0.7)] :
                                    [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                    
                    if item.isPurchased {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(animationPhase == .completing ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animationPhase)
                    }
                }
            }
            .scaleEffect(animationPhase == .completing ? 1.1 : 1.0)
            
            // Item details with enhanced typography
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(item.isPurchased ? .secondary : .primary)
                    .strikethrough(item.isPurchased, color: ColorTheme.successColor)
                    .lineLimit(1)
                
                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Category badge with enhanced design
                HStack(spacing: 4) {
                    Image(systemName: iconName)
                        .font(.system(size: 10))
                        .foregroundColor(ColorTheme.categoryColors[item.category])
                    
                    Text(item.category.rawValue)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(ColorTheme.categoryColors[item.category])
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(ColorTheme.categoryColors[item.category]?.opacity(0.15) ?? .gray.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(
                                    ColorTheme.categoryColors[item.category]?.opacity(0.3) ?? .gray.opacity(0.3),
                                    lineWidth: 0.5
                                )
                        )
                )
            }
            
            Spacer()
            
            // Favorite button with enhanced animation
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    animationPhase = .favoriting
                    var updatedItem = item
                    updatedItem.isFavorite.toggle()
                    viewModel.updateItem(updatedItem)
                    
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animationPhase = .idle
                }
            }) {
                Image(systemName: item.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(
                        item.isFavorite ?
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
                    .scaleEffect(animationPhase == .favoriting ? 1.3 : 1.0)
                    .rotationEffect(.degrees(animationPhase == .favoriting ? 180 : 0))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ColorTheme.categoryColors[item.category]?.opacity(0.3) ?? .gray.opacity(0.3),
                                    ColorTheme.categoryColors[item.category]?.opacity(0.1) ?? .gray.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: ColorTheme.categoryColors[item.category]?.opacity(0.1) ?? .black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .offset(x: offset)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: offset)
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.width < 0 {
                        offset = gesture.translation.width
                        showDeleteButton = gesture.translation.width < -50
                    }
                }
                .onEnded { gesture in
                    if gesture.translation.width < -100 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offset = -80
                            showDeleteButton = true
                        }
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offset = 0
                            showDeleteButton = false
                        }
                    }
                }
        )
        .overlay(
            // Delete button overlay
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        viewModel.deleteItem(item)
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                        impactFeedback.impactOccurred()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Delete")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 100, height: 60)
                    .background(
                        LinearGradient(
                            colors: [ColorTheme.errorColor, ColorTheme.errorColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .opacity(showDeleteButton ? 1 : 0)
                .scaleEffect(showDeleteButton ? 1.0 : 0.8)
            }
            .padding(.trailing, 20)
        )
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