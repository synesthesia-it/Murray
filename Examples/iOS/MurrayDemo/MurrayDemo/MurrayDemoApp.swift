//
//  MurrayDemoApp.swift
//  MurrayDemo
//
//  Created by Stefano Mondino on 28/04/23.
//

import SwiftUI

@main
struct MurrayDemoApp: App {
    var body: some Scene {
        WindowGroup {
            MainTab(viewModel: .init())
        }
    }
}
