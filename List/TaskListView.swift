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
                        Toggle(isOn: Binding(
                            get: { item.completedDate != nil },
                            set: { isChecked in
                                if isChecked {
                                    item.completedDate = Date()
                                } else {
                                    item.completedDate = nil
                                }
                                do {
                                    try viewContext.save()
                                } catch {
                                    let nsError = error as NSError
                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                }
                            }
                        )) {
                            Text(item.name ?? "Unknown Item")
                        }
                        .toggleStyle(CheckBoxToggleStyle())

                        Spacer()

                        Button(action: {
                            deleteItem(item)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
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
                    TextField("Description", text: $itemDescription)
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
            let newItem = ListItem(context: viewContext)
            newItem.completedDate = nil // Initialize with nil
            newItem.name = itemName
            newItem.desc = itemDescription
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

// Custom Toggle style to display a checkbox
struct CheckBoxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .onTapGesture {
                    configuration.isOn.toggle()
                }
                .font(.system(size: 24))
                .foregroundColor(configuration.isOn ? .blue : .gray)
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
