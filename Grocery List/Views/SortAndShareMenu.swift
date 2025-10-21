import SwiftUI

struct SortAndShareMenu: View {
    @ObservedObject var viewModel: GroceryListViewModel
    @State private var showingSortOptions = false
    @State private var showingShareSheet = false
    
    var body: some View {
        Menu {
            Button(action: {
                showingSortOptions = true
            }) {
                Label("Sort Items", systemImage: "arrow.up.arrow.down")
            }
            
            Button(action: {
                showingShareSheet = true
            }) {
                Label("Share List", systemImage: "square.and.arrow.up")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
        }
        .confirmationDialog("Sort Items", isPresented: $showingSortOptions) {
            ForEach(GroceryListViewModel.SortOption.allCases, id: \.self) { option in
                Button(option.rawValue) {
                    viewModel.sortOption = option
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [viewModel.shareList()])
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 