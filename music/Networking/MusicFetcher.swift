//
//  MusicFetcher.swift
//  music
//
//  Created by macbook on 30.04.2025.
//

import Foundation
import SwiftSoup

class MusicFetcher {
    func fetchTracks(from url: URL, completion: @escaping ([Track]) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let cookieString = "zvAuth=1; Expires=Thu, 30 Oct 2025 10:26:41 GMT; Max-Age=15552000; Domain=z3.fm; Path=/"
        request.setValue(cookieString, forHTTPHeaderField: "Cookie")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                completion([])
                return
            }
 
            do {
                let doc = try SwiftSoup.parse(html)
                let sources = try doc.select("#container .songs-list .songs-list-item span.song-play") // adjust this selector
                let tracks = sources.compactMap { element -> Track? in
                    guard let src = try? element.attr("data-url"),
                          let url = URL(string: src, relativeTo: url) else {
                        return nil
                    }
                    
                    guard let title = try? element.attr("data-title") else {
                        return nil
                    }
                    
                    return Track(title: title, streamURL: url)
                }
                completion(tracks)
            } catch {
                completion([])
            }
        }.resume()
    }
}
