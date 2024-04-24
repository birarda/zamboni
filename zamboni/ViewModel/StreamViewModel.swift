//
//  StreamViewModel.swift
//  zamboni
//
//  Created by Stephen on 2024-04-23.
//

import Foundation

class StreamViewModel : ObservableObject {
    @Published var stream: Stream
    @Published var streamURL: URL? = nil
    @Published var hasStreamURL: Bool = false
    
    init(stream: Stream) {
        self.stream = stream
    }
    
    func loadStreamManifest() {
        APIService.shared.loadStreamManifest(stream: self.stream) { streamURLString in
            if let streamURLString = streamURLString {
                self.streamURL = URL(string: streamURLString)!
                self.hasStreamURL = true
            }
        }
    }
}
