//
//  StreamView.swift
//  zamboni
//
//  Created by Stephen on 2024-04-23.
//

import SwiftUI
import AVKit

struct StreamView: View {
    @ObservedObject var viewModel: StreamViewModel
    
    @State var streamIsReady: Bool = false
    
    var body: some View {
        VStack {
            if !viewModel.hasStreamURL {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(.black)
                    .onAppear() {
                        viewModel.loadStreamManifest()
                    }
            } else {
                PlayerViewController(videoURL: viewModel.streamURL, streamIsReady: $streamIsReady).edgesIgnoringSafeArea(.all).overlay {
                    if !streamIsReady {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .background(.black)
                    }
                }
            }
        }
    }
    
}
