//
//  GamesView.swift
//  zamboni
//
//  Created by Stephen on 2024-04-23.
//

import SwiftUI

struct GamesView : View {
    @ObservedObject var viewModel: GamesViewModel = GamesViewModel()
    
    @Binding var navigationPath: NavigationPath
    
#if os(tvOS)
    private let cardWidth = CGFloat(375)
#else
    private let cardWidth = CGFloat(375)
#endif
    
    var body: some View {
        if viewModel.games.isEmpty {
            ProgressView().frame(maxWidth: .infinity, alignment: .center).task {
                viewModel.loadGames()
            }
        } else {
            ScrollView {
                VStack {
                    ForEach(viewModel.games.sorted(by: { a, b in
                        a.key > b.key
                    }), id: \.key) { plainDate, games in
                        Label(plainDate.label(), systemImage: "calendar")
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: cardWidth))]) {
                            ForEach(games, id: \.id) { game in
                                Button(action: {
                                    navigationPath.append(game)
                                }) {
                                    VStack {
                                        Text(game.away.name)
                                        Text("vs")
                                        Text(game.home.name)
                                        Text(game.startTimeLabel())
                                    }
                                    .foregroundColor(Color.white)
                                    .frame(width: cardWidth, height: cardWidth * (2/3))
                                    .background(Color.black)
                                }
                                
#if os(tvOS)
                                .buttonStyle(.card)
#else
                                .buttonStyle(.plain)
#endif
                            }
                        }
                    }
                }
            }
        }
    }
}

