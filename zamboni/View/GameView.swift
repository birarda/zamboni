//
//  GameView.swift
//  zamboni
//
//  Created by Stephen on 2024-04-23.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Streams")
            
            ForEach(viewModel.game.streams, id: \.id) { stream in
                if stream.isFullGame() {
                    Button(action: {
                        navigationPath.append(stream)
                    }) {
                        HStack {
                            Text(stream.label())
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
