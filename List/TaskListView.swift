//
//  ContentView.swift
//  List
//
//  Created by Daniel Rudnick on 8/12/24.
//

import SwiftUI
import CoreData

struct DetailView: View {
    var item: ListItem

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(item.name ?? "Unnamed Item")
                .font(.largeTitle)
                .bold()


            if let description = item.desc, !description.isEmpty {
                           Text(description)
                    .font(.body)
                               .padding(.top, 10)
                       }

            if let completedDate = item.completedDate {
                Text("Completed on: \(completedDate, formatter: itemFormatter)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Item Details")
    }
}

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var list: TaskList

    @State private var isShowingSheet = false
    @State private var itemName: String = ""
    @State private var itemDescription: String = ""

    @State private var items: [ListItem] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    HStack {
                        NavigationLink(destination: DetailView(item: item) ) {
                        }
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
                    Button(action: { isShowingSheet = true }) {
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
        .onAppear {
            loadItems()
        }
    }

    private func loadItems() {
        let request: NSFetchRequest<ListItem> = ListItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ListItem.completedDate, ascending: true)]
        request.predicate = NSPredicate(format: "listItemToTaskList == %@", list)

        do {
            items = try viewContext.fetch(request)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = ListItem(context: viewContext)
            newItem.completedDate = nil
            newItem.name = itemName
            newItem.desc = itemDescription
            newItem.listItemToTaskList = list
            do {
                try viewContext.save()
                loadItems() // Refresh items
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
                loadItems()
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
                loadItems()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}


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
    ListManagerView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
