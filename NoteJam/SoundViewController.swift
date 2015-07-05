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
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // temporary for making sure detailSound is getting set
    @IBOutlet weak var soundNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playButton.enabled = false
        self.stopButton.enabled = false
        
        self.soundNameLabel.text = self.detailSound?.name
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        AVAudioSession.sharedInstance().setActive(false, error: nil)
        
//        self.detailSound?.song?.soundArray.sort() {
//            (s1: Sound, s2: Sound) -> Bool in
//            
//            var comparison = s1.dateCreated.compare(s2.dateCreated)
//            
//            return comparison == NSComparisonResult.OrderedDescending
//        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - User Interface Actions
    
    @IBAction func recordAudio(sender: AnyObject) {
        self.saveButton.enabled = false
        
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
            
            //NSFileManager().removeItemAtURL(audioRecorder!.url, error: nil)
            
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
