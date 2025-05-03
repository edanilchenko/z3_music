//
//  MusicPlayerViewModel.swift
//  music
//
//  Created by macbook on 30.04.2025.
//

import AVFoundation
import Combine

class MusicPlayerViewModel: ObservableObject {
    @Published var tracks: [Track] = []
    @Published var currentTrack: Track?
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 1.0 // Default 1 to prevent divide by 0
    @Published var searchText: String = ""
    
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private let fetcher = MusicFetcher()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.search(for: text)
            }
            .store(in: &cancellables)
    }

    func search(for query: String) {
        guard let url = URL(string: "https://z3.fm/mp3/search?keywords=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            return
        }
        loadMusic(from: url)
    }

    func loadMusic(from url: URL) {
        fetcher.fetchTracks(from: url) { [weak self] fetchedTracks in
            DispatchQueue.main.async {
                self?.tracks = fetchedTracks
            }
        }
    }

    func play(track: Track) {
        player?.pause()
        removePeriodicTimeObserver()
        
        currentTrack = track
        player = AVPlayer(url: track.streamURL)
        addPeriodicTimeObserver()
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func resume() {
        player?.play()
    }

    func seek(to progress: Double) {
        guard let duration = player?.currentItem?.duration.seconds, duration.isFinite else { return }
        let newTime = CMTime(seconds: duration * progress, preferredTimescale: 600)
        player?.seek(to: newTime)
    }

    private func addPeriodicTimeObserver() {
        guard let player = player else { return }

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = player.currentItem?.duration.seconds,
                  duration.isFinite else { return }

            self.duration = duration
            self.currentTime = time.seconds
        }
    }
    
    private func removePeriodicTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
    }
}
