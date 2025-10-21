import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: GroceryListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingClearConfirmation = false
    @State private var showingResetConfirmation = false
    @State private var showingClearPurchasedConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("List Management")) {
                    Button(action: {
                        showingClearConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Clear All Items")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: {
                        showingClearPurchasedConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.orange)
                            Text("Clear Purchased Items")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Button(action: {
                        showingResetConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.blue)
                            Text("Reset to Sample Data")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .alert("Clear All Items", isPresented: $showingClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.clearAllItems()
                }
            } message: {
                Text("Are you sure you want to clear all items? This action cannot be undone.")
            }
            .alert("Clear Purchased Items", isPresented: $showingClearPurchasedConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.clearPurchasedItems()
                }
            } message: {
                Text("Are you sure you want to clear all purchased items? This action cannot be undone.")
            }
            .alert("Reset to Sample Data", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetToSampleData()
                }
            } message: {
                Text("Are you sure you want to reset to sample data? This will clear all current items.")
            }
        }
    }
} 