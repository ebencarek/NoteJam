//
//  Note.swift
//  NoteJam
//
//  Created by Eben Carek on 12/12/14.
//  Copyright (c) 2014 Eben Carek. All rights reserved.
//

import UIKit

class Note: NSObject {
    
    var contents: String = ""
    var noteTitle: String
    var dateLastEdited: NSDate
    weak var song: Song?
    
    var dateString: String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        var dateString = dateFormatter.stringFromDate(self.dateLastEdited)
        
        return dateString
    }
    
    init(titled t: String, song: Song) {
        self.noteTitle = t
        self.song = song
        self.dateLastEdited = NSDate()
        
        super.init()
    }
}
