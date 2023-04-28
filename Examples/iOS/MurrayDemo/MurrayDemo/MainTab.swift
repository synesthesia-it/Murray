//
//  ContentView.swift
//  MurrayDemo
//
//  Created by Stefano Mondino on 28/04/23.
//

import SwiftUI

struct MainTab: View {
    @ObservedObject var viewModel: MainTabViewModel
    var body: some View {
        TabView {
            // murray: tab
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTab(viewModel: .init())
    }
}
