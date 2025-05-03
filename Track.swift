//
//  Track.swift
//  music
//
//  Created by macbook on 30.04.2025.
//

import Foundation

struct Track: Identifiable {
    let id = UUID()
    let title: String
    let streamURL: URL
}
