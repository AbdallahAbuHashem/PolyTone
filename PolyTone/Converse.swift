//
//  Converse.swift
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

class Converse: UIViewController, UITextViewDelegate, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var oppTextView: UITextView!
    @IBOutlet var oppView: UIView!
    @IBOutlet var typeButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var splitButton: UIButton!
    @IBOutlet var header: UILabel!
    
    private var isSplit = false
    private var isRunning = false

    
    //recording utils
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var recorder: AVAudioRecorder!
    private var levelTimer = Timer()
    private var lowPassResults: Double = 0.0
    private var levels = [Float]()

    override func viewDidLoad() {
        super.viewDidLoad()

        recordButton.isEnabled = true
        self.view.bringSubview(toFront: recordButton)
        textView.isEditable = true
        textView.returnKeyType = UIReturnKeyType.done
        textView.delegate = self
        

        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        if(oppView.superview === self.view) {
            oppTextView.attributedText = textView.attributedText
        }
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
    
    private func startRecording() throws {
        recordButton.setImage(#imageLiteral(resourceName: "Image 7"), for: .normal)
        
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
                    self.oppTextView.attributedText = self.textView.attributedText
                } else {
                    let addition: NSMutableAttributedString = NSMutableAttributedString(string:"\n\n" + result.bestTranscription.formattedString)
                    let temp = NSMutableAttributedString(string: "")
                    addition.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, addition.length))
                    temp.append(prev!)
                    temp.append(addition)
                    self.textView.attributedText = temp
                    self.oppTextView.attributedText = self.textView.attributedText

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
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        textView.resignFirstResponder()
        textView.endEditing(true)
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
    
    @IBAction func terminate(_ sender: Any) {
        stop()
    }
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
            stop()
            print("Stopping")
        } else {
            try! startRecording()
            print("Starting")
            isRunning = true
        }
    }
    
    func stop() {
        recordButton.setImage(#imageLiteral(resourceName: "Image 6"), for: .normal)
        audioEngine.pause()
        recorder.stop()
        recorder.isMeteringEnabled = false
        self.levelTimer.invalidate()
        recognitionRequest?.endAudio()
        isRunning = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchViews() {
        if(isSplit) {
            mergeViews()
        } else {
            splitViews()
        }
        
        isSplit = !isSplit
    }
    
    func mergeViews() {
        UIView.animate(withDuration: 1, animations: {
            self.textView.frame = CGRect(x: self.textView.frame.minX, y: 74, width: self.textView.frame.width, height: 490)
            self.header.center.y = 36
            self.header.text = "Converse"
            self.recordButton.center.x = 321
            self.recordButton.center.y = 621
            self.splitButton.center.y = 36
        }, completion: {finished in
            self.oppView.transform = self.oppView.transform.rotated(by: CGFloat(M_PI));
            self.oppView.removeFromSuperview()
        })
        self.splitButton.setImage(#imageLiteral(resourceName: "split icon"), for: .normal)
        self.closeButton.setImage(#imageLiteral(resourceName: "close"), for: .normal)

    }
    
    func splitViews() {
        UIView.animate(withDuration: 1, animations: {
            self.textView.frame = CGRect(x: self.textView.frame.minX, y: 370, width: self.textView.frame.width, height: 210)
            self.header.center.y = self.view.center.y
            self.header.text = ""
            self.recordButton.center = self.view.center
            self.splitButton.center.y = self.view.center.y
        })
        self.view.addSubview(oppView)
        self.view.sendSubview(toBack: oppView)
        oppTextView.attributedText = textView.attributedText
        splitButton.setImage(#imageLiteral(resourceName: "merge icon"), for: .normal)
        closeButton.setImage(#imageLiteral(resourceName: "blue close"), for: .normal)
        oppView.transform = oppView.transform.rotated(by: CGFloat(M_PI))
    }
    
    @IBAction func tappedType() {
        textView.becomeFirstResponder()
        //textView.font = UIFont(name: "Avenir-Medium", size: 18.0)
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
