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
    
    @IBOutlet var startAllButton: UIButton!
    var audioEngine = AVAudioEngine()
    var playerNode = AVAudioPlayerNode()
    let timeShift = AVAudioUnitTimePitch()
    let pedoMeter = CMPedometer()
    let bpm: Float = 120
    var avgStarted: Bool = false
    
    var steps: Int = 0
    var timer = Timer()
    var adjustedBpm: Float = 120
    
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
    @IBOutlet weak var avgLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        label.text = "120"
        audioEngine.attach(playerNode)
        audioEngine.attach(timeShift)
        audioEngine.connect(playerNode, to: timeShift, format: nil)
        audioEngine.connect(timeShift, to: audioEngine.mainMixerNode, format: nil)
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
        adjustedBpm = sender.value
        timeShift.rate = adjustedBpm/bpm
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
       playKeys()
    }
    
    @IBAction func tappedTempo(_ sender: UIButton) {
        let currentTap = Date()
        if let lastTap = self.lastTap {
            
            let interval = currentTap.timeIntervalSince(lastTap)
            adjustedBpm = Float(60/interval)
            timeShift.rate = adjustedBpm/bpm
            label.text = String(adjustedBpm)
            
        }
        self.lastTap = currentTap
    }
    
    @IBAction func getSpmTapped(_ sender: UIButton) {
        getSpm()
    }
    
    @IBAction func avgWalkTapped(_ sender: UIButton) {
        if !avgStarted {
            avgStarted = true
            self.view.backgroundColor = UIColor.blue
            averageOutSteps()
            avgLabel.setTitle("Stop", for: .normal)
        } else {
            self.view.backgroundColor = UIColor.green
            avgStarted = false
            stopAveragingSteps()
            avgLabel.setTitle("Start", for: .normal)
        }
    }
  
    @IBAction func startAllTapped(_ sender: Any) {
        startAllButton.setTitle("Playing", for: .normal)
        playKeys()
        let timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { (_) in
            self.playKeys()
            let now = Date()
            self.averageOutStepsFrom(now - 30, to: now)
        }
    }
    
    private func playKeys() {
        let url = Bundle.main.url(forResource: "keys", withExtension: ".wav")
        if let url = url {
            do {
                let audioFile = try AVAudioFile(forReading: url)
                timeShift.rate = adjustedBpm/bpm
                playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            } catch {
                print("could not load audio file")
            }
        } else {
            print("could not load audio file")
        }
        playerNode.play()
    }
    
    private func getSpm() {
        guard !timer.isValid else {return}
        startCountingSteps()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.timerCount -= 1
            self.timerLabel.text = String(self.timerCount)
        }
    }
    
    func startCountingSteps() {
        self.view.backgroundColor = UIColor.red
        if CMPedometer.isStepCountingAvailable() {
            pedoMeter.startUpdates(from: Date()) { (data, _) in
                if let dataSteps = data?.numberOfSteps.intValue {
                    self.steps = dataSteps
                    DispatchQueue.main.async {
                        self.stepCountLabel.text = String(dataSteps)
                    }
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
        adjustedBpm = Float(steps)*6
        timeShift.rate = adjustedBpm/bpm
        label.text = String(adjustedBpm)
        timerCount = 10
    }
    
    func averageOutSteps() {
        let startDate = Date()
        pedoMeter.startUpdates(from: Date()) { (data, error) in
            if let dataSteps = data?.numberOfSteps.intValue {
                print("STEP UPDATE")
                let timeInterval = startDate.timeIntervalSinceNow
                self.steps = dataSteps
                let sps: Float = -Float(self.steps)/Float(timeInterval)
                let spm: Float = sps*60
                self.adjustedBpm = spm
                self.timeShift.rate = self.adjustedBpm/self.bpm
                DispatchQueue.main.async {
                    self.label.text = String(self.adjustedBpm)
                    self.stepCountLabel.text = String(dataSteps)
                }
            }
        }
    }
    
    func averageOutStepsFrom(_ startDate: Date, to endDate: Date) {
        if(CMPedometer.isStepCountingAvailable()){
            self.pedoMeter.queryPedometerData(from: startDate, to: endDate, withHandler: { (data, _) in
                if let steps = data?.numberOfSteps.floatValue {
                    let interval = Float(endDate.timeIntervalSince(startDate))
                    let mult: Float = 60.0/interval
                    let spm = steps*mult
                    self.adjustedBpm = spm
                    self.timeShift.rate = self.adjustedBpm/self.bpm
                    DispatchQueue.main.async {
                        self.label.text = String(self.adjustedBpm)
                        self.stepCountLabel.text = String(steps)
                    }
                }
            })
        }
    }
    
    func stopAveragingSteps() {
        pedoMeter.stopUpdates()
    }
}

