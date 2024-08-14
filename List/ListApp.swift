//
//  ListApp.swift
//  List
//
//  Created by Daniel Rudnick on 8/12/24.
//

import SwiftUI

@main
struct ListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ListManagerView() // Change to ListManagerView
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

