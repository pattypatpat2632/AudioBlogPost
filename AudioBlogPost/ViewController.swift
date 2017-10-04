//
//  ViewController.swift
//  AudioBlogPost
//
//  Created by Patrick O'Leary on 9/28/17.
//  Copyright © 2017 Patrick O'Leary. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

class ViewController: UIViewController {
    
    var audioEngine = AVAudioEngine()
    var playerNode = AVAudioPlayerNode()
    let timeChange = AVAudioUnitTimePitch()
    let pedoMeter = CMPedometer()
    var bpm: Float = 120
    var newBpm: Float = 120
    var steps: Int = 0
    var timer = Timer()
    var timerCount = 10 {
        didSet {
            if timerCount == 0 {
                stopCountingSteps()
            }
        }
    }
    
    var lastTap: Date? = nil
    
    @IBOutlet weak var tempoTap: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        label.text = "120"
        audioEngine.attach(playerNode)
        audioEngine.attach(timeChange)
        audioEngine.connect(playerNode, to: timeChange, format: nil)
        audioEngine.connect(timeChange, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.prepare()
        timerLabel.text = ""
        stepCountLabel.text = ""
        do {
            try audioEngine.start()
        } catch {
            print("Could not start audio engine")
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        label.text = String(sender.value)
        newBpm = sender.value
        timeChange.rate = newBpm/bpm
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        let url = Bundle.main.url(forResource: "keys", withExtension: ".wav")
        if let url = url {
            
            do {
                let audioFile = try AVAudioFile(forReading: url)
                timeChange.rate = newBpm/bpm
                playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            } catch {
                print("could not load audio file")
            }
        } else {
            print("could not load audio file")
        }
        playerNode.play()
    }
    
    @IBAction func tappedTempo(_ sender: UIButton) {
        let currentTap = Date()
        if let lastTap = self.lastTap {
            
            let interval = currentTap.timeIntervalSince(lastTap)
            newBpm = Float(60/interval)
            timeChange.rate = newBpm/bpm
            label.text = String(newBpm)
            
        }
        self.lastTap = currentTap
    }
    
    @IBAction func getSpmTapped(_ sender: UIButton) {
        startCountingSteps()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.timerCount -= 1
            self.timerLabel.text = String(self.timerCount)
        }
    }
    
    func startCountingSteps() {
        self.view.backgroundColor = UIColor.red
        if CMPedometer.isStepCountingAvailable() {
            pedoMeter.startUpdates(from: Date()) { (data, error) in
                if let dataSteps = data?.numberOfSteps.intValue {
                    print("VALID STEPS")
                    self.steps = dataSteps
                    self.stepCountLabel.text = String(dataSteps)
                }
            }
        } else {
            print("step counting not available")
        }
    }
    
    func stopCountingSteps() {
        timer.invalidate()
        self.view.backgroundColor = UIColor.green
        pedoMeter.stopUpdates()
        newBpm = Float(steps)*6
        timeChange.rate = newBpm
        label.text = String(newBpm)
        timerCount = 10
    }
}

