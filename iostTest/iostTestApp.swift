//
//  iostTestApp.swift
//  iostTest
//
//  Created by Hugo Andersson on 10/6/26.
//

import SwiftUI

@main
struct iostTestApp: App {
    
    var store : DeadlineStore = DeadlineStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
