//
//  BindableTorrentManager.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/12/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import Combine
import SwiftUI

class TorrentsViewModel : NSObject, BindableObject, TorrentManagerDelegate {
    
    private let updateSubject = PassthroughSubject<Void, Never>()
    
    let didChange: AnyPublisher<Void, Never>
    
    var torrents: [Torrent]! {
        didSet {
            updateSubject.send()
        }
    }
    
    override init() {
        didChange = updateSubject
            .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
        super.init()
        TorrentManager.shared().addDelegate(self)
    }
    
    func addTestTorrentFiles() {
        TorrentManager.shared().add(TorrentFile.test_1())
        TorrentManager.shared().add(TorrentFile.test_2())
    }
    
    func addTestMagnetLinks() {
        TorrentManager.shared().add(MagnetURI.test_1())
    }
    
    func addTestTorrents() {
        addTestTorrentFiles()
        addTestMagnetLinks()
    }

    func remove(_ torrent: Torrent) {
        TorrentManager.shared().remove(torrent.infoHash)
    }
    
    // MARK: - TorrentManagerDelegate
    
    func torrentManagerDidReceiveUpdate(_ manager: TorrentManager) {
        torrents = manager.torrents().sorted(by: { $0.name < $1.name })
    }
}