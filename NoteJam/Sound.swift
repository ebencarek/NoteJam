//
//  Sound.swift
//  NoteJam
//
//  Created by Eben Carek on 5/12/15.
//  Copyright (c) 2015 Eben Carek. All rights reserved.
//

import UIKit

class Sound: NSObject {
    
    var name: String
    var dateCreated: NSDate
    weak var song: Song?
    
    // name of the file associated with the object
    var fileName: String {
        return self.name + ".caf"
    }
    
    // path in which the file is stored
    var filePathURL: NSURL? {
        let directoryPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsPath = directoryPaths[0]
        return NSURL(fileURLWithPath: documentsPath).URLByAppendingPathComponent((self.song?.name)! + self.fileName)
    }
    
    // String representation of the date created
    var dateString: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let dateString = dateFormatter.stringFromDate(self.dateCreated)
        
        return dateString
    }
    
    init(name: String, dateCreated: NSDate, song: Song?) {
        self.name = name
        self.dateCreated = dateCreated
        self.song = song
    }
    
    convenience init(named n: String, song s: Song) {
        self.init(name: n, dateCreated: NSDate(), song: s)
    }
    
//    required convenience init(coder aDecoder: NSCoder) {
//        let name = aDecoder.decodeObjectOfClass(NSString.classForCoder(), forKey: "name") as! String
//        let dateCreated = aDecoder.decodeObjectOfClass(NSDate.classForCoder(), forKey: "dateCreated") as! NSDate
//        self.init(name: name, dateCreated: dateCreated, song: nil)
//    }
//    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(self.name, forKey: "name")
//        aCoder.encodeObject(self.dateCreated, forKey: "dateCreated")
//    }
}
