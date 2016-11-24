//
//  Caption.swift
//  PolyTone
//
//  Created by Abdallah Abuhashem on 11/22/16.
//  Copyright © 2016 Abdallah AbuHashem. All rights reserved.
//

import UIKit
import  Speech

class Caption: UIViewController, SFSpeechRecognizerDelegate {

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
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
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
        
        try audioEngine.start()
        
        let text = textView.text as String
        textView.text = "\(text)\n\n(Starting)"
        isRunning = true

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
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.setImage(#imageLiteral(resourceName: "Image 6"), for: .normal)
            print("Stopping")
            isRunning = false
            let text = textView.text as String
            textView.text = "\(text)\n\n(Stopping)"
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
