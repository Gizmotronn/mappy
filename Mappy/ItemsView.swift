//
//  ItemsView.swift
//  Mappy
//
//  Created by Liam Arbuckle on 10/1/2026.
//

import SwiftUI
import SwiftData

struct ItemsView: View {
    let items: [Item]
    let modelContext: ModelContext
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                }
                .onDelete { offsets in
                    for index in offsets {
                        modelContext.delete(items[index])
                    }
                }
            }
            .navigationTitle("Items")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addItem) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private func addItem() {
        let newItem = Item(timestamp: Date())
        modelContext.insert(newItem)
    }
}

#Preview {
    let container = try! ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    ItemsView(items: [], modelContext: ModelContext(container))
}
