@_private(sourceFile: "TaskListView.swift") import List
import func SwiftUI.__designTimeBoolean
import func SwiftUI.__designTimeInteger
import protocol SwiftUI.PreviewProvider
import func SwiftUI.__designTimeString
import func SwiftUI.__designTimeFloat
import struct SwiftUI.EmptyView
import protocol SwiftUI.View
import CoreData
import SwiftUI

extension CheckBoxToggleStyle {
    @_dynamicReplacement(for: makeBody(configuration:)) private func __preview__makeBody(configuration: Configuration) -> some View {
        #sourceLocation(file: "/Users/elianadaugherty/Developer/Personal/list/List/TaskListView.swift", line: 149)
        HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? __designTimeString("#5074.[3].[0].[0].arg[0].value.[2].arg[0].value.then", fallback: "checkmark.square") : __designTimeString("#5074.[3].[0].[0].arg[0].value.[2].arg[0].value.else", fallback: "square"))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
                .font(.system(size: __designTimeInteger("#5074.[3].[0].[0].arg[0].value.[2].modifier[1].arg[0].value.arg[0].value", fallback: 24)))
                .foregroundColor(configuration.isOn ? .blue : .gray)
        }
    
#sourceLocation()
    }
}

extension TaskListView {
    @_dynamicReplacement(for: deleteItems(offsets:)) private func __preview__deleteItems(offsets: IndexSet) {
        #sourceLocation(file: "/Users/elianadaugherty/Developer/Personal/list/List/TaskListView.swift", line: 134)
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    
#sourceLocation()
    }
}

extension TaskListView {
    @_dynamicReplacement(for: deleteItem(_:)) private func __preview__deleteItem(_ item: ListItem) {
        #sourceLocation(file: "/Users/elianadaugherty/Developer/Personal/list/List/TaskListView.swift", line: 122)
        withAnimation {
            viewContext.delete(item)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    
#sourceLocation()
    }
}

extension TaskListView {
    @_dynamicReplacement(for: addItem()) private func __preview__addItem() {
        #sourceLocation(file: "/Users/elianadaugherty/Developer/Personal/list/List/TaskListView.swift", line: 105)
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
        itemName = __designTimeString("#5074.[2].[6].[1].[0]", fallback: "")
        itemDescription = __designTimeString("#5074.[2].[6].[2].[0]", fallback: "")
    
#sourceLocation()
    }
}

extension TaskListView {
    @_dynamicReplacement(for: body) private var __preview__body: some View {
        #sourceLocation(file: "/Users/elianadaugherty/Developer/Personal/list/List/TaskListView.swift", line: 23)
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
                            Text(item.name ?? __designTimeString("#5074.[2].[5].property.[0].[0].arg[0].value.[0].arg[0].value.[0].arg[1].value.[0].arg[0].value.[0].arg[1].value.[0].arg[0].value.[0]", fallback: "Unknown Item"))
                        }
                        .toggleStyle(CheckBoxToggleStyle())

                        Spacer()

                        Button(action: {
                            deleteItem(item)
                        }) {
                            Image(systemName: __designTimeString("#5074.[2].[5].property.[0].[0].arg[0].value.[0].arg[0].value.[0].arg[1].value.[0].arg[0].value.[2].arg[1].value.[0].arg[0].value", fallback: "trash"))
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
                    Button(action: {isShowingSheet = __designTimeBoolean("#5074.[2].[5].property.[0].[0].arg[0].value.[0].modifier[0].arg[0].value.[1].arg[0].value.[0].arg[0].value.[0].[0]", fallback: true)}) {
                        Label(__designTimeString("#5074.[2].[5].property.[0].[0].arg[0].value.[0].modifier[0].arg[0].value.[1].arg[0].value.[0].arg[1].value.[0].arg[0].value", fallback: "Add Item"), systemImage: __designTimeString("#5074.[2].[5].property.[0].[0].arg[0].value.[0].modifier[0].arg[0].value.[1].arg[0].value.[0].arg[1].value.[0].arg[1].value", fallback: "plus"))
                    }
                }
            }
            .sheet(isPresented: $isShowingSheet) {
                VStack {
                    Text(__designTimeString("#5074.[2].[5].property.[0].[0].arg[0].value.[0].modifier[1].arg[1].value.[0].arg[0].value.[0].arg[0].value", fallback: "Enter Item Name"))
                        .font(.headline)
                    TextField(__designTimeString("#5074.[2].[5].property.[0].[0].arg[0].value.[0].modifier[1].arg[1].value.[0].arg[0].value.[1].arg[0].value", fallback: "Name"), text: $itemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Text(__designTimeString("#5074.[2].[5].property.[0].[0].arg[0].value.[0].modifier[1].arg[1].value.[0].arg[0].value.[2].arg[0].value", fallback: "Enter Description (optional)"))
                        .font(.headline)
                    TextField(__designTimeString("#5074.[2].[5].property.[0].[0].arg[0].value.[0].modifier[1].arg[1].value.[0].arg[0].value.[3].arg[0].value", fallback: "Description"), text: $itemDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    HStack {
                        Button(__designTimeString("#5074.[2].[5].property.[0].[0].arg[0].value.[0].modifier[1].arg[1].value.[0].arg[0].value.[4].arg[0].value.[0].arg[0].value", fallback: "Add Item")) {
                            addItem()
                            isShowingSheet = __designTimeBoolean("#5074.[2].[5].property.[0].[0].arg[0].value.[0].modifier[1].arg[1].value.[0].arg[0].value.[4].arg[0].value.[0].arg[1].value.[1].[0]", fallback: false)
                        }
                        .padding()
                        .disabled(itemName.isEmpty)
                        Spacer()
                        Button(__designTimeString("#5074.[2].[5].property.[0].[0].arg[0].value.[0].modifier[1].arg[1].value.[0].arg[0].value.[4].arg[0].value.[2].arg[0].value", fallback: "Cancel")) {
                            isShowingSheet = __designTimeBoolean("#5074.[2].[5].property.[0].[0].arg[0].value.[0].modifier[1].arg[1].value.[0].arg[0].value.[4].arg[0].value.[2].arg[1].value.[0].[0]", fallback: false)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            Text(__designTimeString("#5074.[2].[5].property.[0].[0].arg[0].value.[1].arg[0].value", fallback: "Select an item"))
        }
    
#sourceLocation()
    }
}

import struct List.TaskListView
import struct List.CheckBoxToggleStyle
#Preview {
    TaskListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}



