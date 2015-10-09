//
//  SongViewController.swift
//  NoteJam
//
//  Created by Eben Carek on 12/12/14.
//  Copyright (c) 2014 Eben Carek. All rights reserved.
//

import UIKit

class SongViewController: UITableViewController {
    
    // Displays alert prompting user to enter the name of the new song
    @IBAction func displayNewSongAlert() {
        print("display alert view")
        
        let newSongAlert = UIAlertController(title: "New Song", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Configure the text field
        newSongAlert.addTextFieldWithConfigurationHandler({
            (textField: UITextField) in
            textField.placeholder = "Name"
            textField.spellCheckingType = UITextSpellCheckingType.Yes
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.autocorrectionType = UITextAutocorrectionType.Yes
        })
        
        newSongAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            alertAction in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // Create a new song with the entered name, add a cell to the table, and present the SongDetailViewController
        newSongAlert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            if let textField = newSongAlert.textFields?[0] {
                
                if textField.hasText() {
                    for song in SongStore.sharedStore.songs {
                        if song.name == textField.text! {
                            // Display error to user if entered name matches existing song name
                            self.displaySongNameErrorAlert()
                            return
                        }
                    }
                    
                    SongStore.sharedStore.newSongNamed(textField.text!)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                    let songDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SongDetailViewController") as! SongDetailViewController
                    songDetailViewController.detailSong = SongStore.sharedStore.songs[0]
                    
                    self.navigationController?.pushViewController(songDetailViewController, animated: true)
                }
            }
        }))
        
        self.presentViewController(newSongAlert, animated:true, completion:nil)
    }
    
    // Displays error for song name conflicts
    func displaySongNameErrorAlert() {
        let errorAlert = UIAlertController(title: "A song by this name already exists, please choose a different name.", message: nil, preferredStyle: .Alert)
        
        errorAlert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Reload data in table view
        self.tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return SongStore.sharedStore.songs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) 
        
        // Cell displays the name of the song and the date it was last edited
        let song = SongStore.sharedStore.songs[indexPath.row]
        cell.textLabel?.text = song.name
        cell.detailTextLabel?.text = song.dateString()
        
        return cell
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
            
            // Delete any sound files associated with the song before deleting song
            SongStore.sharedStore.songs[indexPath.row].deleteSounds()
            
            SongStore.sharedStore.songs.removeAtIndex(indexPath.row)
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
        
        let destinationViewController = segue.destinationViewController as! SongDetailViewController
        
        // Pass the selected song to the detail controller
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let song = SongStore.sharedStore.songs[indexPath.row]
            destinationViewController.detailSong = song
            song.dateLastEdited = NSDate()
        }
    }
    
}