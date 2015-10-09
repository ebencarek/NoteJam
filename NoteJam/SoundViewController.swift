//
//  SoundViewController.swift
//  NoteJam
//
//  Created by Eben Carek on 5/8/15.
//  Copyright (c) 2015 Eben Carek. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var detailSound: Sound?
    var updateTimer: NSTimer?
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var timeElapsed: UILabel!
    @IBOutlet weak var timeRemaining: UILabel!
    
    // temporary for making sure detailSound is getting set
    @IBOutlet weak var soundNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.soundNameLabel.text = self.detailSound?.name
        
        let audioSession = AVAudioSession.sharedInstance()
        
        // Request permission to use the microphone
        audioSession.requestRecordPermission({ [unowned self] (allowed: Bool) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if allowed {
                    self.loadRecordingUI()
                }
                else {
                    self.loadFailUI()
                }
            })
        })
    }
    
    // Configure UI appropriately if recording permissions are granted
    func loadRecordingUI() {
        self.recordButton.enabled = true
    }
    
    // Display warning to user that they must allow the app access to the microphone
    func loadFailUI() {
        let alert = UIAlertController(title: "NoteJam needs access to your microphone", message: "Please ensure the app has access to your microphone in your Settings", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Update the labels showing the time elapsed and the time remaining
    func updateCurrentTime() {
        progressSlider.value = Float(audioPlayer!.currentTime as Double)
        
        // update timeElapsed label
        let minutesElapsed = Int(audioPlayer!.currentTime) / 60
        let secondsElapsed = Int(audioPlayer!.currentTime) % 60
        let minutesElapsedString = minutesElapsed > 9 ? "\(minutesElapsed)" : "0\(minutesElapsed)"
        let secondsElapsedString = secondsElapsed > 9 ? "\(secondsElapsed)" : "0\(secondsElapsed)"
        timeElapsed.text = minutesElapsedString + ":" + secondsElapsedString
        
        // update timeRemaining label
        let minutesRemaining = Int(audioPlayer!.duration) / 60 - minutesElapsed
        let secondsRemaining = Int(audioPlayer!.duration) % 60 - secondsElapsed
        let minutesRemainingString = minutesRemaining > 9 ? "\(minutesRemaining)" : "0\(minutesRemaining)"
        let secondsRemainingString = secondsRemaining > 9 ? "\(secondsRemaining)" : "0\(secondsRemaining)"
        timeRemaining.text = "-" + minutesRemainingString + ":" + secondsRemainingString
    }
    
    // Reset time labels when the player finishes playing the sound file
    func resetTimeLabels() {
        timeElapsed.text = "00:00"
        
        var minutes = 0, seconds = 0
        
        if let player = audioPlayer {
            minutes = Int(player.duration) / 60
            seconds = Int(player.duration) % 60
        }
        else if let recorder = audioRecorder {
            print(recorder.currentTime)
            minutes = Int(recorder.currentTime) / 60
            seconds = Int(recorder.currentTime) % 60
        }
        
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        
        timeRemaining.text = "-" + minutesString + ":" + secondsString
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - User Interface Actions
    
    // User starts sliding the progress bar
    // Pause player and invalidate the timer that updates the time labels
    @IBAction func userDidBeginSliding(sender: AnyObject) {
        if let player = audioPlayer {
            player.pause()
            updateTimer?.invalidate()
        }
    }
    
    // User stopped sliding the progress bar
    // Begin playing at the appropriate time, start timer that updates the time labels
    @IBAction func userDidEndSliding(sender: AnyObject) {
        if let player = audioPlayer {
            player.currentTime = (Double(progressSlider.value))
            player.play()
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateCurrentTime", userInfo: nil, repeats: true)
        }
    }
    
    // User is sliding the progress bar
    // Update the time labels based on the position of the slider
    @IBAction func userIsSliding(sender: AnyObject) {
        if let player = audioPlayer {
            player.currentTime = (Double(progressSlider.value))
            self.updateCurrentTime()
        }
    }
    
    // Record audio
    @IBAction func recordAudio(sender: AnyObject) {
        self.saveButton.enabled = false
        self.recordButton.enabled = false
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setActive(true)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        // Settings for the recorder object
        let recordingSettings: [String : AnyObject] = [
            AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatAppleIMA4), // file extension ".caf"
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 12800,
            AVLinearPCMBitDepthKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: (self.detailSound?.filePathURL)!, settings: recordingSettings)
            audioRecorder?.delegate = self
            print("audioRecorder created successfully")
            
            
            self.stopButton.enabled = true
            self.playButton.enabled = false
            
            audioRecorder?.record()
        }
        catch let error as NSError {
            print("audioRecorder error: \(error.localizedDescription)")
        }
    }
    
    // Play the recorded sound file
    @IBAction func playAudio(sender: AnyObject) {
        stopButton.enabled = true
        recordButton.enabled = false
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        }
        catch let error as NSError {
            print("audioSession error: \(error.description)")
        }
        
        do {
            // Create audio player
            audioPlayer = try AVAudioPlayer(contentsOfURL: (self.detailSound?.filePathURL)!)
            audioPlayer?.delegate = self
            
            // Configure and start audio player
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            // Configure slider so that bounds match duration of sound file
            progressSlider.enabled = true
            progressSlider.maximumValue = Float(audioPlayer!.duration as Double)
            
            // Start timer to update labels as sound plays
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateCurrentTime", userInfo: nil, repeats: true)
        }
        catch let error as NSError {
            print("audioPlayer error: \(error.localizedDescription)")
        }
    }
    
    // Stop button pressed
    @IBAction func stopAudio(sender: AnyObject) {
        self.stopButton.enabled = false
        self.playButton.enabled = true
        self.recordButton.enabled = true
        
        // If user stopped a recording
        if audioRecorder?.recording == true {
            self.resetTimeLabels()
            audioRecorder?.stop()
            audioRecorder = nil
            self.saveButton.enabled = true
        }
        // If user stopped playing sound
        else {
            audioPlayer?.stop()
            audioPlayer = nil
            progressSlider.value = 0.0
            updateTimer?.invalidate()
            progressSlider.enabled = false
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    // Save the sound
    @IBAction func saveSound(sender: AnyObject) {
        self.audioRecorder?.stop()
        self.audioPlayer?.stop()
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            return
        })
    }
    
    // Cancel pressed
    @IBAction func cancel(sender: AnyObject) {
        self.audioRecorder?.stop()
        self.audioPlayer?.stop()
        
        // delete the sound file
        if let sound = self.detailSound {
            do {
                try NSFileManager().removeItemAtURL(sound.filePathURL!)
            } catch _ {
            }
        }
        
        // delete the table cell created for the sound
        let songDetailViewController = (self.presentingViewController as! UINavigationController).childViewControllers.last as! SongDetailViewController
        
        songDetailViewController.tableView(songDetailViewController.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            return
        })
    }
    
    
    // MARK: - AVAudioPlayer Delegate Methods
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.enabled = true
        stopButton.enabled = false
        updateTimer?.invalidate()
        progressSlider.value = 0.0
        progressSlider.enabled = false
        
        self.resetTimeLabels()

        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("Audio Play Decode Error")
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer) {
        
    }
    
    
    // MARK: - AVAudioRecorder Delegate Methods
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        print("Audio Record Encode Error")
    }
    
    func audioRecorderBeginInterruption(recorder: AVAudioRecorder) {
        
    }
    
    func audioRecorderEndInterruption(recorder: AVAudioRecorder) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
