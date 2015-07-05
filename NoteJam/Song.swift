//
//  Song.swift
//  NoteJam
//
//  Created by Eben Carek on 12/12/14.
//  Copyright (c) 2014 Eben Carek. All rights reserved.
//

import UIKit

class Song: NSObject {
    
    var name = "New Song"
    var noteArray: [Note]
    var soundArray: [Sound]
    var dateLastEdited: NSDate
    
    init(named name: String) {
        
        self.name = name
        self.noteArray = [Note]()
        self.soundArray = [Sound]()
        self.dateLastEdited = NSDate()
        
        super.init()
    }
    
    func dateString() -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        var dateString = dateFormatter.stringFromDate(self.dateLastEdited)
        
        return dateString
    }
    
    func deleteSounds() {
        for sound in soundArray {
            NSFileManager().removeItemAtURL(sound.filePathURL!, error: nil)
        }
    }
}
