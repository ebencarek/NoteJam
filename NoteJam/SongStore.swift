//
//  SongStore.swift
//  NoteJam
//
//  Created by Eben Carek on 12/12/14.
//  Copyright (c) 2014 Eben Carek. All rights reserved.
//

import UIKit

class SongStore: NSObject {
    
    var songs = [Song]()
    
    class var sharedStore: SongStore {
        return _sharedStore
    }
    
    func newSongNamed(name: String) -> Song {
        
        println("creating new song")
        
        var song = Song(named: name)
        
        songs.insert(song, atIndex: 0)
        
        println("songs holds \(songs.count) songs")
        
        for songItem: Song in songs {
            println("\(songItem.name)")
        }
        
        return song
    }
}

private let _sharedStore = SongStore()