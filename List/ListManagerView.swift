//
//  ListManagerView.swift
//  List
//
//  Created by Eliana Daugherty on 8/14/24.
//

import SwiftUI
import CoreData

struct ListManagerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskList.createdDate, ascending: true)],
        animation: .default)
    private var taskLists: FetchedResults<TaskList>

    @State private var isShowingAddListSheet = false
    @State private var newListName = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(taskLists) { taskList in
                        HStack {
                            NavigationLink(destination: TaskListView(list: taskList)) {
                                Text(taskList.title ?? "Unnamed List")
                            }
                            Spacer()
                            Button(action: {
                                deleteList(taskList)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .navigationTitle("Manage Lists")
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { isShowingAddListSheet = true }) {
                        Label("Add List", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddListSheet) {
                VStack {
                    Text("Enter List Name")
                        .font(.headline)
                    TextField("Name", text: $newListName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    HStack {
                        Button("Add List") {
                            addList()
                            isShowingAddListSheet = false
                        }
                        .padding()
                        .disabled(newListName.isEmpty)
                        Spacer()
                        Button("Cancel") {
                            isShowingAddListSheet = false
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
    }

    private func addList() {
        withAnimation {
            let newList = TaskList(context: viewContext)
            newList.title = newListName
            newList.createdDate = Date()
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        newListName = ""
    }

    private func deleteList(_ list: TaskList) {
        withAnimation {
            viewContext.delete(list)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

