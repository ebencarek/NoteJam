//
//  Song.swift
//  NoteJam
//
//  Created by Eben Carek on 12/12/14.
//  Copyright (c) 2014 Eben Carek. All rights reserved.
//

import UIKit

// if uncommenting encode and decode methods, add the NSCoding protocol

class Song: NSObject {
    
    var name = "New Song"
    var noteArray: [Note]
    var soundArray: [Sound]
    var dateLastEdited: NSDate
    
    init(name: String, noteArray: [Note], soundArray: [Sound], dateLastEdited: NSDate) {
        self.name = name
        self.noteArray = noteArray
        self.soundArray = soundArray
        self.dateLastEdited = dateLastEdited
        super.init()
    }
    
    convenience init(named name: String) {
        self.init(name: name, noteArray: [Note](), soundArray: [Sound](), dateLastEdited: NSDate())
    }
    
//    required convenience init(coder aDecoder: NSCoder) {
//        let name = aDecoder.decodeObjectOfClass(NSString.classForCoder(), forKey: "name") as! String
//        let noteArray = aDecoder.decodeObjectForKey("noteArray") as! [Note]
//        let soundArray = aDecoder.decodeObjectForKey("soundArray") as! [Sound]
//        let dateLastEdited = aDecoder.decodeObjectOfClass(NSDate.classForCoder(), forKey: "dateLastEdited") as! NSDate
//        
//        self.init(name: name, noteArray: noteArray, soundArray: soundArray, dateLastEdited: dateLastEdited)
//        
//        for n in self.noteArray {
//            n.song = self
//        }
//        
//        for s in self.soundArray {
//            s.song = self
//        }
//    }
    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(self.name, forKey: "name")
//        aCoder.encodeObject(self.dateLastEdited, forKey: "dateLastEdited")
//        aCoder.encodeObject(self.noteArray, forKey: "noteArray")
//        aCoder.encodeObject(self.soundArray, forKey: "soundArray")
//    }
    
    func dateString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let dateString = dateFormatter.stringFromDate(self.dateLastEdited)
        
        return dateString
    }
    
    func deleteSounds() {
        for sound in soundArray {
            do {
                try NSFileManager().removeItemAtURL(sound.filePathURL!)
            } catch _ {
            }
        }
    }
}
