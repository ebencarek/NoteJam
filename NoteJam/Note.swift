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
    
    // String representation of the date last edited
    var dateString: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let dateString = dateFormatter.stringFromDate(self.dateLastEdited)
        
        return dateString
    }
    
    init(title: String, contents: String, dateLastEdited: NSDate, song: Song?) {
        self.noteTitle = title
        self.contents = contents
        self.dateLastEdited = dateLastEdited
        self.song = song
        
        super.init()
    }
    
    convenience init(titled t: String, song: Song) {
        self.init(title: t, contents: "", dateLastEdited: NSDate(), song: song)
    }
    
//    required convenience init(coder aDecoder: NSCoder) {
//        let title = aDecoder.decodeObjectOfClass(NSString.classForCoder(), forKey: "title") as! String
//        let contents = aDecoder.decodeObjectOfClass(NSString.classForCoder(), forKey: "contents") as! String
//        let date = aDecoder.decodeObjectOfClass(NSDate.classForCoder(), forKey: "dateLastEdited") as! NSDate
//        
//        self.init(title: title, contents: contents, dateLastEdited: date, song: nil)
//    }
//    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(self.noteTitle, forKey: "title")
//        aCoder.encodeObject(self.contents, forKey: "contents")
//        aCoder.encodeObject(self.dateLastEdited, forKey: "dateLastEdited")
//    }
}
