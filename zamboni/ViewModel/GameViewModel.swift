//
//  GameViewModel.swift
//  zamboni
//
//  Created by Stephen on 2024-04-23.
//

import Foundation

class GameViewModel : ObservableObject {
    @Published var game: Game
    
    init(game: Game) {
        self.game = game
    }
}
