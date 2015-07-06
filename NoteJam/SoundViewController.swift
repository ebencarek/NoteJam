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
        
//        self.playButton.enabled = false
//        self.stopButton.enabled = false
//        self.progressSlider.enabled = false
        
        self.soundNameLabel.text = self.detailSound?.name
    }
    
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
    
    func resetTimeLabels() { // TODO: figure out way to set labels before player is created
        timeElapsed.text = "00:00"
        
        var minutes = 0, seconds = 0
        
        if let player = audioPlayer {
            minutes = Int(audioPlayer!.duration) / 60
            seconds = Int(audioPlayer!.duration) % 60
        }
        
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        
        timeRemaining.text = "-" + minutesString + ":" + secondsString
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        AVAudioSession.sharedInstance().setActive(false, error: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - User Interface Actions
    
    @IBAction func userDidBeginSliding(sender: AnyObject) {
        if let player = audioPlayer {
            player.pause()
            updateTimer?.invalidate()
        }
    }
    
    @IBAction func userDidEndSliding(sender: AnyObject) {
        if let player = audioPlayer {
            player.currentTime = (Double(progressSlider.value))
            player.play()
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateCurrentTime", userInfo: nil, repeats: true)
        }
    }
    
    // TODO: use the deleteRecording() method on the audio recorder and move audioRecorder initialization back to viewDidLoad() in order to improve performance
    
    @IBAction func recordAudio(sender: AnyObject) {
        self.saveButton.enabled = false
        self.recordButton.enabled = false
        
        var error: NSError?
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryRecord, error: &error)
        audioSession.setActive(true, error: nil)
        
        if let err = error {
            println("audioSession error: \(err.localizedDescription)")
        }

        let recordingSettings =
            [AVFormatIDKey: kAudioFormatAppleIMA4, // file extension ".caf"
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 12800,
            AVLinearPCMBitDepthKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue]
        
        audioRecorder = AVAudioRecorder(URL: self.detailSound?.filePathURL, settings: recordingSettings as [NSObject : AnyObject], error: &error)
        
        if let err = error {
            println("audioRecorder error: \(err.localizedDescription)")
        }
        else {
            println("preparing to record")
            audioRecorder?.prepareToRecord()
        }
        
        if audioRecorder?.recording == false {
            
            println("RECORDING")
            
            audioRecorder?.prepareToRecord()
            self.stopButton.enabled = true
            self.playButton.enabled = false
            audioRecorder?.record()
        }
    }
    
    @IBAction func playAudio(sender: AnyObject) {
        if let recorder = audioRecorder {
            if audioRecorder?.recording == false {
                stopButton.enabled = true
                recordButton.enabled = false
                
                var error: NSError?
                
                let audioSession = AVAudioSession.sharedInstance()
                audioSession.setCategory(AVAudioSessionCategoryPlayback, error: &error)
                audioSession.setActive(true, error: nil)
                
                if let err = error {
                    println("audioSession error: \(err.localizedDescription)")
                }
                
                audioPlayer = AVAudioPlayer(contentsOfURL: audioRecorder?.url, error:&error)
                audioPlayer?.delegate = self
                
                if let err = error {
                    println("audioPlayer error: \(err.localizedDescription)")
                }
                else {
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                    
                    progressSlider.enabled = true
                    progressSlider.maximumValue = Float(audioPlayer!.duration as Double)
                    
                    updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateCurrentTime", userInfo: nil, repeats: true)
                    
                }
            }
        }
    }
    
    @IBAction func stopAudio(sender: AnyObject) {
        self.stopButton.enabled = false
        self.playButton.enabled = true
        self.recordButton.enabled = true
        
        if audioRecorder?.recording == true {
            audioRecorder?.stop()
            self.saveButton.enabled = true
        }
        else {
            audioPlayer?.stop()
            progressSlider.value = 0.0
            updateTimer?.invalidate()
            progressSlider.enabled = false
            self.resetTimeLabels()
        }
        
        AVAudioSession.sharedInstance().setActive(false, error: nil)
    }
    
    @IBAction func saveSound(sender: AnyObject) {
        self.audioRecorder?.stop()
        self.audioPlayer?.stop()
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            return
        })
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.audioRecorder?.stop()
        self.audioPlayer?.stop()
        
        if let sound = self.detailSound {
            NSFileManager().removeItemAtURL(sound.filePathURL!, error: nil)
        }
        
        let songDetailViewController = (self.presentingViewController as! UINavigationController).childViewControllers.last as! SongDetailViewController
        
        songDetailViewController.tableView(songDetailViewController.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            return
        })
    }
    
    
    // MARK: - AVAudioPlayer Delegate Methods
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        recordButton.enabled = true
        stopButton.enabled = false
        updateTimer?.invalidate()
        progressSlider.value = 0.0
        progressSlider.enabled = false
        
        self.resetTimeLabels()

        AVAudioSession.sharedInstance().setActive(false, error: nil)
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("Audio Play Decode Error")
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer!) {
        
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer!) {
        
    }
    
    
    // MARK: - AVAudioRecorder Delegate Methods
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        AVAudioSession.sharedInstance().setActive(false, error: nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println("Audio Record Encode Error")
    }
    
    func audioRecorderBeginInterruption(recorder: AVAudioRecorder!) {
        
    }
    
    func audioRecorderEndInterruption(recorder: AVAudioRecorder!) {
        
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
