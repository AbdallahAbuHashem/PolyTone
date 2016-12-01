//
//  Caption.swift
//  PolyTone
//
//  Created by Abdallah Abuhashem on 11/22/16.
//  Copyright © 2016 Abdallah AbuHashem. All rights reserved.
//

import UIKit
import Speech
import Foundation
import AVFoundation
import CoreAudio

class Caption: UIViewController, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {

    @IBOutlet var exitView: UIView!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet var textView: UITextView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var isRunning = false
    
    private var recorder: AVAudioRecorder!
    private var levelTimer = Timer()
    private var lowPassResults: Double = 0.0
    private var levels = [Float]()
    
    var effect:UIVisualEffect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        save.layer.cornerRadius = 15
        exitButton.layer.cornerRadius = 15
        cancel.layer.cornerRadius = 15
        exitView.layer.cornerRadius = 15
        
        recordButton.isEnabled = false
        
        try! startRecording()
    }
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
           
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    print("Speech recognition authorized on this device")
                case .denied:
                    self.recordButton.isEnabled = false
                    print("User denied access to speech recognition")
                case .restricted:
                    self.recordButton.isEnabled = false
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    print("Speech recognition not yet authorized")
                }
            }
        }

    }
    
    // Caption audio, yay!
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        self.levels.removeAll()
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        let settings: [String: AnyObject] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0 as AnyObject,
            AVNumberOfChannelsKey: 1 as AnyObject,
        ]
        
        do {
            let URL = self.directoryURL()!
            try! recorder = AVAudioRecorder(url: URL as URL, settings: settings)
        }
        recorder.delegate = self
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        //var lastStylized: NSMutableAttributedString = NSMutableAttributedString(string:"")
        let prev = textView.attributedText
        let font:UIFont? = UIFont(name: "Avenir-Medium", size: 18.0)
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                var segs = result.bestTranscription.segments
                
                let finalText = NSMutableAttributedString(string: "")
                finalText.append(prev!)
                let newLine = NSMutableAttributedString(string: "\n\n")
                newLine.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, newLine.length))
                finalText.append(newLine)
                if (segs.count > 0 && segs[0].timestamp != 0) {
                    print("got here")
                    for i in 0...segs.count-1 {
                        //let base = segs[i].timestamp
                        let str = NSMutableAttributedString(string: segs[i].substring+" ")
                        //In ranges, first number is start position, and second number is length of the effect
                        let currSeg = segs[i]
                        let time: Float = Float(currSeg.timestamp)
                        let idx: Int = Int(time/0.2)
                        print("Attempting Index")
                        print("Time: ", time)
                        print("Val: ",  idx)
                        let fontSize = (self.levels[0]/self.levels[idx])*18.0
                        print("Got Index")
                        if fontSize > 32.0 {
                            let font:UIFont? = UIFont(name: "Avenir-Heavy", size: CGFloat(fontSize))
                            str.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, str.length))
                        } else {
                            let font:UIFont? = UIFont(name: "Avenir-Medium", size: CGFloat(fontSize))
                            str.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, str.length))
                        }
                        finalText.append(str)
                    }
                    self.textView.attributedText = finalText
                } else {
                    let addition: NSMutableAttributedString = NSMutableAttributedString(string:"\n\n" + result.bestTranscription.formattedString)
                    let temp = NSMutableAttributedString(string: "")
                    addition.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, addition.length))
                    temp.append(prev!)
                    temp.append(addition)
                    self.textView.attributedText = temp
                }
                let range = NSMakeRange(self.textView.text.characters.count - 1, 0)
                self.textView.scrollRangeToVisible(range)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start Recording", for: [])
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        
        
        try audioEngine.start()
        
        recorder.record()
        
        //instantiate a timer to be called with whatever frequency we want to grab metering values
        self.levelTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.levelTimerCallback), userInfo: nil, repeats: true)
        recorder.updateMeters()
        isRunning = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)

    }
    func levelTimerCallback() {
        //we have to update meters before we can get the metering values
        recorder.updateMeters()
        
        //print to the console if we are beyond a threshold value. Here I've used -7
        print (recorder.averagePower(forChannel: 0))
        self.levels.append(recorder.averagePower(forChannel: 0))
//        if recorder.averagePower(forChannel: 0) > -7 {
//            print("Dis be da level I'm hearin' you in dat mic ")
//            print(recorder.averagePower(forChannel: 0))
//            print("Do the thing I want, mofo")
//        }
    }
    func directoryURL() -> NSURL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
        return soundURL as NSURL?
    }
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            print("Recording available")
        } else {
            recordButton.isEnabled = false
            print("Recognition not available")
        }
    }
    @IBAction func recordButtonTapped() {
        if isRunning {
            audioEngine.pause()
            recorder.stop()
            recorder.isMeteringEnabled = false
            self.levelTimer.invalidate()
            recognitionRequest?.endAudio()
            recordButton.setImage(#imageLiteral(resourceName: "Image 6"), for: .normal)
            print("Stopping")
            isRunning = false
        } else {
            try! startRecording()
            recordButton.setImage(#imageLiteral(resourceName: "Image 7"), for: .normal)
            print("Starting")
            isRunning = true
        }
    }

    func animateIn() {
        self.view.addSubview(exitView)
        exitView.center = self.view.center
        exitView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.isHidden = false
            self.exitView.alpha = 1
        }
    }
    @IBAction func exit(_ sender: Any) {
        animateIn()
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.exitView.alpha = 0
            self.visualEffectView.isHidden = true
        }) { (success:Bool) in
            self.exitView.removeFromSuperview()
        }
    }
    @IBAction func cancelButton(_ sender: Any) {
        animateOut()
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
