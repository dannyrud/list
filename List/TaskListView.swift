//
//  ContentView.swift
//  List
//
//  Created by Daniel Rudnick on 8/12/24.
//

import SwiftUI
import CoreData

struct TaskListView: View {
    @State private var isShowingSheet = false
    @State private var itemName: String = ""
    @State private var itemDescription: String = ""
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ListItem.completedDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ListItem>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    HStack {
                        NavigationLink(destination: Text("Item at \(item.completedDate!, formatter: itemFormatter)\nDescription: \(item.description)")) {
                            Text(item.name!)
                        }

                        Spacer()

                        Button(action: {
                            deleteItem(item)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle()) // Ensures the button doesn't interfere with the row selection
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: {isShowingSheet = true}) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingSheet) {
                            VStack {
                                Text("Enter Item Name")
                                    .font(.headline)
                                TextField("Name", text: $itemName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                Text("Enter Description (optional)")
                                    .font(.headline)
                                    TextField("Description", text: $itemDescription) // Added text field for description
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                HStack {
                                    Button("Add Item") {
                                        addItem()
                                        isShowingSheet = false
                                    }
                                    .padding()
                                    .disabled(itemName.isEmpty)
                                    Spacer()
                                    Button("Cancel") {
                                        isShowingSheet = false
                                    }
                                    .padding()
                                }
                            }
                            .padding()
                        }
                        Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let ListItem = ListItem(context: viewContext)
            ListItem.completedDate = Date()
            ListItem.name = itemName
            ListItem.desc = itemDescription
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        itemName = ""
        itemDescription = ""
    }

    private func deleteItem(_ item: ListItem) {
        withAnimation {
            viewContext.delete(item)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    TaskListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
