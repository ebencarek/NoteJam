//
//  NoteTextViewController.swift
//  NoteJam
//
//  Created by Eben Carek on 12/12/14.
//  Copyright (c) 2014 Eben Carek. All rights reserved.
//

import UIKit

class NoteTextViewController: UIViewController {
    
    var detailNote: Note? {
        didSet {
            self.navigationItem.title = detailNote?.noteTitle
            //self.textView.text = detailNote?.contents
        }
    }
    
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.text = detailNote?.contents
        
        if textView.text == "" {
            self.textView.becomeFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        detailNote?.contents = self.textView.text;
        
        //Sort the detailSong's notes array based on the date last edited
        detailNote?.song?.noteArray.sort() {
            (n1: Note, n2: Note) -> Bool in
            
            var comparison = n1.dateLastEdited.compare(n2.dateLastEdited)
            
            return comparison == NSComparisonResult.OrderedDescending
        }
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}