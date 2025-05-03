//
//  ContentView.swift
//  music
//
//  Created by macbook on 30.04.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = MusicPlayerViewModel()
    @State private var searchText = ""
    @State private var playbackPosition: Double = 0.0
    @State private var isPlaying = false

    var body: some View {
        VStack {
            // Search Field
            TextField("Search music...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Track List
            List(viewModel.tracks) { track in
                Text(track.title)
                    .onTapGesture {
                        viewModel.play(track: track)
                        playbackPosition = 0.0
                        isPlaying = true
                    }
            }

            Spacer()
            
            VStack {
                if let track = viewModel.currentTrack {
                    Text(track.title)
                        .font(.headline)
                        .padding(.bottom, 4)
                }

                Slider(
                    value: Binding(
                        get: {
                            viewModel.currentTime / (viewModel.duration == 0 ? 1 : viewModel.duration)
                        },
                        set: { newValue in
                            viewModel.seek(to: newValue)
                        }
                    ),
                    in: 0...1
                )
                .padding(.horizontal)

                Button(action: {
                    if(isPlaying){
                        viewModel.pause()
                    } else {
                        viewModel.resume()
                    }
                    
                    isPlaying.toggle()
                    // Future enhancement: actually pause/resume AVPlayer here
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding()
        }
        .onAppear {
            if let url = URL(string: "https://z3.fm/") {
                viewModel.loadMusic(from: url)
            }
        }
    }
}
