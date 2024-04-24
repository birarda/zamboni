//
//  HomeView.swift
//  zamboni
//
//  Created by Stephen Birarda on 2024-04-22.
//

import SwiftUI

struct HomeView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TabView {
                GamesView(navigationPath: $navigationPath).tabItem {
                    Label("Games", systemImage: "hockey.puck.fill")
                }
                SettingsView().tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }.navigationDestination(for: Game.self) { game in
                GameView(viewModel: GameViewModel(game: game), navigationPath: $navigationPath)
            }.navigationDestination(for: Stream.self) { stream in
                StreamView(viewModel: StreamViewModel(stream: stream))
            }
        }.task {
            APIService.shared.hasValidToken { _result in }
        }
    }
}

#Preview {
    HomeView()
}
