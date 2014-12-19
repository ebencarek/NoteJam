//
//  SongDetailViewController.swift
//  NoteJam
//
//  Created by Eben Carek on 12/12/14.
//  Copyright (c) 2014 Eben Carek. All rights reserved.
//

import UIKit

class SongDetailViewController: UITableViewController {
    
    var detailSong: Song? {
        didSet {
            self.navigationItem.title = detailSong?.name
        }
    }
    
    @IBAction func displayNewItemAlert() {
        
        var newItemAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        newItemAlert.addAction(UIAlertAction(title: "New Note", style: .Default, handler: {
            alertAction in
            self.newNote()
            //self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        newItemAlert.addAction(UIAlertAction(title: "New Sound", style: .Default, handler: {
            alertAction in
            self.newSound()
        }))
        
        newItemAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            alertAction in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(newItemAlert, animated: true, completion: nil)
    }
    
    func newNote() {
        
        var newNoteAlert = UIAlertController(title: "New Note", message: nil, preferredStyle: .Alert)
        
        newNoteAlert.addTextFieldWithConfigurationHandler {
            textField in
            textField.placeholder = "Name"
        }
        
        newNoteAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            alertAction in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        newNoteAlert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            if let textField = newNoteAlert.textFields?[0] as? UITextField {
                
                if textField.hasText() {
                    
                    self.detailSong?.noteArray.insert(Note(titled: textField.text, song: self.detailSong!), atIndex: 0)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                    let noteTextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NoteTextViewController") as NoteTextViewController
                    noteTextViewController.detailNote = self.detailSong?.noteArray[0]
                    
                    self.navigationController?.pushViewController(noteTextViewController, animated: true)
                }
            }
        }))
        
        self.presentViewController(newNoteAlert, animated: true, completion: nil)
    }
    
    func newSound() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // Sort songs according their dateLastEdited property
        SongStore.sharedStore.songs.sort() {
            (s1: Song, s2: Song) -> Bool in
            
            let comparison = s1.dateLastEdited.compare(s2.dateLastEdited)
            
            return comparison == NSComparisonResult.OrderedDescending
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if let count = self.detailSong?.noteArray.count { return count }
        }
        else if section == 1 {
            if let count = self.detailSong?.audioArray.count { return count }
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell;
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath) as UITableViewCell
            
            let note = self.detailSong?.noteArray[indexPath.row];
            cell.textLabel?.text = note?.noteTitle
            cell.detailTextLabel?.text = note?.dateString()
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("AudioCell", forIndexPath: indexPath) as UITableViewCell
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "NOTES"
        }
        else {
            return "SOUNDS"
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete the row from the data source
            self.detailSong?.noteArray.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if let destinationViewController = segue.destinationViewController as? NoteTextViewController {
            
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let note = self.detailSong?.noteArray[indexPath.row];
                destinationViewController.detailNote = note;
                note?.dateLastEdited = NSDate()
            }
        }
    }
}
