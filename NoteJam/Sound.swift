//
//  Sound.swift
//  NoteJam
//
//  Created by Eben Carek on 5/12/15.
//  Copyright (c) 2015 Eben Carek. All rights reserved.
//

import UIKit

class Sound: NSObject {
    
    // TODO: implement this class
    
    var name: String
    var dateCreated: NSDate
    weak var song: Song?
    
    var fileName: String {
        return self.name + ".caf"
    }
    
    var filePathURL: NSURL? {
        let directoryPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsPath = directoryPaths[0] as! String
        let soundFilePath = documentsPath.stringByAppendingPathComponent(self.fileName)
        return NSURL(fileURLWithPath: soundFilePath)
    }
    
    var dateString: String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        var dateString = dateFormatter.stringFromDate(self.dateCreated)
        
        return dateString
    }
    
    init(named n: String, song s: Song) {
        self.name = n
        self.song = s
        self.dateCreated = NSDate()
    }
}
