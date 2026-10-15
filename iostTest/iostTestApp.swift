//
//  iostTestApp.swift
//  iostTest
//
//  Created by Hugo Andersson on 10/6/26.
//

import SwiftUI
import UserNotifications

@main
struct iostTestApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var store = DeadlineStore()
    private let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .task { store.refreshIntegrations() }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { store.refreshIntegrations() }
                }
        }
    }
}
