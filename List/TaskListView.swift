//
//  ContentView.swift
//  List
//
//  Created by Daniel Rudnick on 8/12/24.
//

import CoreData
import SwiftUI

// Define your GPT API-related details
let apiToken;
let apiUrl = "https://api.openai.com/v1/chat/completions"

struct TaskListView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @ObservedObject var list: TaskList

  @State private var isShowingSheetAdd = false
  @State private var isShowingSheetGPT = false
  @State private var itemName: String = ""
  @State private var dishName: String = ""
  @State private var numPeople: Int = 0
  @State private var itemDescription: String = ""

  @FetchRequest var items: FetchedResults<ListItem>

  init(list: TaskList) {
    self.list = list
    _items = FetchRequest<ListItem>(
      sortDescriptors: [NSSortDescriptor(keyPath: \ListItem.completedDate, ascending: true)],
      predicate: NSPredicate(format: "listItemToTaskList == %@", list)
    )
  }

  var body: some View {
    GeometryReader { geometry in
      NavigationView {
        VStack {
          if list.title != nil {
            Text(list.title ?? "Please add list")
              .font(.largeTitle)
              .bold()
              .padding(.top, 20)
              .padding(.bottom, 20)

            List {
              ForEach(items) { item in
                VStack(alignment: .leading) {
                  HStack {
                    Toggle(
                      isOn: Binding(
                        get: { item.completedDate != nil },
                        set: { isChecked in
                          if isChecked {
                            item.completedDate = Date()
                          } else {
                            item.completedDate = nil
                          }
                          saveContext()
                        }
                      )
                    ) {
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
                  HStack {
                    if let description = item.desc {
                      Text(description)
                        .font(.footnote)
                        .foregroundColor(.gray)

                      Spacer()

                      if let completedDate = item.completedDate {
                        Text("Completed on: \(completedDate, formatter: itemFormatter)")
                          .font(.footnote)
                          .foregroundColor(.gray)
                      }
                    }
                  }
                }
                .padding(.vertical, 10)
              }
              .onDelete(perform: deleteItems)
            }
            .listStyle(DefaultListStyle())
            .frame(width: geometry.size.width)  // Full width of the window

            Spacer()

            HStack {
              Button(action: { isShowingSheetAdd = true }) {
                Label("Add Item", systemImage: "plus")
              }
              .padding()
              .disabled(list.title == nil)

              Spacer()

              Button(action: { isShowingSheetGPT = true }) {
                Image("gpt")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 20, height: 20)
              }
              .padding()
            }
            .padding(.bottom, 20)
          } else {
            Text("No list available. Please create a list first.")
              .font(.headline)
              .padding()
          }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .sheet(isPresented: $isShowingSheetAdd) {
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
                isShowingSheetAdd = false
              }
              .padding()
              .disabled(itemName.isEmpty)
              Spacer()
              Button("Cancel") {
                isShowingSheetAdd = false
              }
              .padding()
            }
          }
          .padding()
        }
        .sheet(isPresented: $isShowingSheetGPT) {
          VStack {
            Text("What do you want to make?")
              .font(.headline)
            TextField("Dish", text: $dishName)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .padding()
            Text("How many are you serving?")
              .font(.headline)
            Text("Number of people: \(numPeople)")
              .font(.headline)
              .padding()
            Slider(
              value: Binding(
                get: { Double(numPeople) },
                set: { numPeople = Int($0) }
              ),
              in: 1...100,
              step: 1
            )
            .padding()
            HStack {
              Button("Ask your AI assistant") {
                isShowingSheetGPT = false
                askAi()
              }
              .padding()
              .disabled(dishName.isEmpty)
              .disabled(numPeople == 0)
              Spacer()
              Button("Cancel") {
                isShowingSheetGPT = false
              }
              .padding()
            }
          }
          .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
  }

  private func saveContext() {
    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }

  private func addItem() {
    if list.title != nil {
      withAnimation {
        let newItem = ListItem(context: viewContext)
        newItem.completedDate = nil
        newItem.name = itemName
        newItem.desc = itemDescription
        newItem.listItemToTaskList = list
        saveContext()
      }
      itemName = ""
      itemDescription = ""
    }
  }

  private func deleteItem(_ item: ListItem) {
    withAnimation {
      viewContext.delete(item)
      saveContext()
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { items[$0] }.forEach(viewContext.delete)
      saveContext()
    }
  }

  func askAi() {

    // Prepare the request
    let messages = [
      [
        "role": "system",
        "content": "You are a helpful assistant that provides recipe and ingredient information.",
      ],
      [
        "role": "user",
        "content":
          "Provide a list of ingredients for \(dishName) for \(numPeople) people. The response should be in a structured format listing each item and the amount needed. Do not respond with ANYTHING besides a structured list of items and amounts so the response json is easy to parse",
      ],
    ]

    let requestBody: [String: Any] = [
      "model": "gpt-3.5-turbo",
      "messages": messages,
    ]

    guard let url = URL(string: apiUrl) else {
      print("Invalid URL: \(apiUrl)")
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch {
      print("Failed to serialize request body: \(error)")
      return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Request error: \(error.localizedDescription)")  // Debugging: Request error
        return
      }

      guard let data = data else {
        print("No data received")
        return
      }

      do {
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
          as? [String: Any],
          let choices = jsonResponse["choices"] as? [[String: Any]],
          let message = choices.first?["message"] as? [String: Any],
          let content = message["content"] as? String
        {
          DispatchQueue.main.async {
            //Todo here
            print("JSON Response: \(jsonResponse)")
          }
        } else {
          print("Failed to parse response, unexpected format")
        }
      } catch {
        print("Failed to parse response: \(error)")
      }
    }
    task.resume()
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
  ListManagerView().environment(
    \.managedObjectContext, PersistenceController.preview.container.viewContext)
}
