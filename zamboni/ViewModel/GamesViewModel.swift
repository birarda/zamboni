//
//  HomeViewModel.swift
//  zamboni
//
//  Created by Stephen on 2024-04-22.
//

import Foundation

class GamesViewModel : ObservableObject {
    @Published var games: [PlainDate: [Game]] = [:]
    
    func loadGames() {
        let loadDate = PlainDate()
        
        APIService.shared.loadGames(date: loadDate, daysBack: 3, completion: { loadedGames in
            if let loadedGames = loadedGames {
                var newGames: [PlainDate: [Game]] = [:]
                
                for game in loadedGames {
                    let gameDate = PlainDate(apiString: game.startTimeET)
                    
                    if newGames[gameDate] == nil {
                        newGames[gameDate] = []
                    }
                    
                    newGames[gameDate]!.append(game)
                }
                
                self.games = newGames
            }
        })
    }
}
