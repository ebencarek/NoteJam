//
//  SongDetailViewController.swift
//  NoteJam
//
//  Created by Eben Carek on 12/12/14.
//  Copyright (c) 2014 Eben Carek. All rights reserved.
//

import UIKit
import AVFoundation

class SongDetailViewController: UITableViewController, AVAudioPlayerDelegate {
    
    var detailSong: Song? {
        didSet {
            self.navigationItem.title = detailSong?.name
        }
    }
    
    var audioPlayer: AVAudioPlayer?
    var selectedSound: Sound?
    var selectedIndexPath: NSIndexPath?
    
    @IBAction func displayNewItemAlert() {
        
        let newItemAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
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
        
        let newNoteAlert = UIAlertController(title: "New Note", message: nil, preferredStyle: .Alert)
        
        newNoteAlert.addTextFieldWithConfigurationHandler {
            textField in
            textField.placeholder = "Name"
            textField.spellCheckingType = UITextSpellCheckingType.Yes
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.autocorrectionType = UITextAutocorrectionType.Yes
        }
        
        newNoteAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            alertAction in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        newNoteAlert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            if let textField = newNoteAlert.textFields?[0] {
                
                if textField.hasText() {
                    
                    self.detailSong?.noteArray.insert(Note(titled: textField.text!, song: self.detailSong!), atIndex: 0)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                    let noteTextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NoteTextViewController") as! NoteTextViewController
                    noteTextViewController.detailNote = self.detailSong?.noteArray[0]
                    
                    self.navigationController?.pushViewController(noteTextViewController, animated: true)
                }
            }
        }))
        
        self.presentViewController(newNoteAlert, animated: true, completion: nil)
    }
    
    func newSound() {
        
        let newSoundAlert = UIAlertController(title: "New Sound", message: nil, preferredStyle: .Alert)
        
        newSoundAlert.addTextFieldWithConfigurationHandler {
            textField in
            textField.placeholder = "Name"
            textField.spellCheckingType = UITextSpellCheckingType.Yes
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.autocorrectionType = UITextAutocorrectionType.Yes
        }
        
        newSoundAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) {
            alertAction in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        newSoundAlert.addAction(UIAlertAction(title: "Done", style: .Default) {
            alertAction in
            if let textField = newSoundAlert.textFields?[0] {
                if textField.hasText() {
                    if let soundArray = self.detailSong?.soundArray {
                        for sound in soundArray {
                            if textField.text == sound.name {
                                self.displaySoundNameError()
                                return
                            }
                        }
                    }
                    
                    self.detailSong?.soundArray.insert(Sound(named: textField.text!, song: self.detailSong!), atIndex: 0)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 1)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    
                    let soundViewControllerNavigation = self.storyboard?.instantiateViewControllerWithIdentifier("SoundViewControllerNavigation") as! UINavigationController
                    
                    self.presentViewController(soundViewControllerNavigation, animated: true) { () -> Void in
                        self.tableView.reloadData()
                    }
                    
                    let soundViewController = soundViewControllerNavigation.topViewController as! SoundViewController
                    soundViewController.detailSound = self.detailSong?.soundArray[0]
                }
            }
        })
        
        self.presentViewController(newSoundAlert, animated: true, completion: nil)
    }
    
    func displaySoundNameError() {
        let errorAlert = UIAlertController(title: "A sound by this name already exists, please choose a different name.", message: nil, preferredStyle: .Alert)
        
        errorAlert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        
        self.presentViewController(errorAlert, animated: true, completion: nil)
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
        SongStore.sharedStore.songs.sortInPlace() {
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
            if let count = self.detailSong?.soundArray.count { return count }
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell;
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath) 
            
            let note = self.detailSong?.noteArray[indexPath.row]
            cell.textLabel?.text = note?.noteTitle
            cell.detailTextLabel?.text = note?.dateString
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("AudioCell", forIndexPath: indexPath) 
            
            let sound = self.detailSong?.soundArray[indexPath.row]
            cell.textLabel?.text = sound?.name
            cell.detailTextLabel?.text = sound?.dateString
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // if the user selects a note, this is handled by the storyboard segue
        if indexPath.section == 0 {
            return
        }
        
        // Play the sound that was selected
        self.selectedSound = self.detailSong?.soundArray[indexPath.row]
        self.selectedIndexPath = indexPath
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOfURL: (self.selectedSound?.filePathURL)!)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error as NSError {
            print("audioPlayer error: \(error.localizedDescription)")
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
            
            if indexPath.section == 0 {
                self.detailSong?.noteArray.removeAtIndex(indexPath.row)
            }
            else {
                let url = self.detailSong?.soundArray[indexPath.row].filePathURL
                do {
                    try NSFileManager().removeItemAtURL(url!)
                } catch _ {
                }
                self.detailSong?.soundArray.removeAtIndex(indexPath.row)
            }
            
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
    
    
    // MARK: - AVAudioPlayer Delegate Methods
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if let indexPath = self.selectedIndexPath {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer) {
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if let destinationViewController = segue.destinationViewController as? NoteTextViewController {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let note = self.detailSong?.noteArray[indexPath.row];
                destinationViewController.detailNote = note;
                note?.dateLastEdited = NSDate()
            }
        }
    }
}
