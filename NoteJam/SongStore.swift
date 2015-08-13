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
        var song = Song(named: name)
        songs.insert(song, atIndex: 0)
        
        return song
    }
    
//    func archivePath() -> String {
//        let directoryPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//        let documentsPath = directoryPaths[0] as! String
//        let archivePath = documentsPath.stringByAppendingPathComponent("SongArchives")
//        
//        return archivePath
//    }
//    
//    func archivePathForSongNamed(n: String) -> String {
//        return self.archivePath().stringByAppendingPathComponent("\(n).archive")
//    }
//    
//    func saveSongsToFile() {
//        for song in songs {
//            NSKeyedArchiver.archiveRootObject(song, toFile: archivePathForSongNamed(song.name))
//        }
//    }
//    
//    func loadSongsFromFile() {
//        let fileManager = NSFileManager()
//        let enumerator = fileManager.enumeratorAtPath(self.archivePath())
//        
//        var file: String?
//        file = enumerator?.nextObject() as! String?
//        
//        while (file != nil) {
//            if file?.pathExtension == "archive" {
//                let song = NSKeyedUnarchiver.unarchiveObjectWithFile(file!) as! Song
//                
//                songs.insert(song, atIndex: 0)
//            }
//            
//            file = enumerator?.nextObject() as! String?
//        }
//    }
}

private let _sharedStore = SongStore()