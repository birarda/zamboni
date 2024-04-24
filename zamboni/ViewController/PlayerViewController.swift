//
//  PlayerViewController.swift
//  zamboni
//
//  Created by Stephen on 2024-04-23.
//

import AVKit
import SwiftUI

class LandscapeOnlyPlayer : AVPlayerViewController {
#if !os(tvOS)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
#endif
}

struct PlayerViewController: UIViewControllerRepresentable {
    var videoURL: URL?
    @Binding var streamIsReady: Bool

    func makeUIViewController(context: Context) -> LandscapeOnlyPlayer {
        let controller = LandscapeOnlyPlayer()
        controller.modalPresentationStyle = .fullScreen
        
        let asset = AVURLAsset(url: videoURL!)
        let playerItem = AVPlayerItem(asset: asset)
        
        let _ = playerItem.addObserver(context.coordinator, forKeyPath: "status", options: [.new], context: nil)
        
        controller.player = AVPlayer(playerItem: playerItem)
        controller.player?.play()

        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }

    func updateUIViewController(_ playerController: LandscapeOnlyPlayer, context: Context) {}
}

class Coordinator: NSObject {
    var owner : PlayerViewController

    init(owner: PlayerViewController) {
        self.owner = owner
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let item = object as? AVPlayerItem else { return }
        
        if keyPath == "status" && item.status == .readyToPlay {
            item.seek(to: .zero) { hasSeeked in
                if hasSeeked {
                    print("Setting stream ready TRUE")
                    self.owner.streamIsReady = true
                }
            }
        }
    }
}
