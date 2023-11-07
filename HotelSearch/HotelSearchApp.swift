//
//  HotelSearchApp.swift
//  HotelSearch
//
//  Created by Khakim on 07/11/23.
//

import SwiftUI

@main
struct HotelSearchApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
