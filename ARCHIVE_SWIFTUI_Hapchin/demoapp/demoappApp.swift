//
//  demoappApp.swift
//  demoapp
//
//  Created by Iron Bae on 2023/05/06.
//

import SwiftUI

@main
struct demoappApp: App {
    @StateObject private var camera = Camera()
    var body: some Scene { 
        WindowGroup {
            ContentView()
                .environmentObject(camera)
        }
    }
}
