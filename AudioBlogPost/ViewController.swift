//
//  ViewController.swift
//  AudioBlogPost
//
//  Created by Patrick O'Leary on 9/28/17.
//  Copyright © 2017 Patrick O'Leary. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var audioEngine = AVAudioEngine()
    var playerNode = AVAudioPlayerNode()
    let timeChange = AVAudioUnitTimePitch()
    var bpm: Float = 120
    var newBpm: Float = 120
    
    var lastTap: Date? = nil
    
    @IBOutlet weak var tempoTap: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        label.text = "120"
        audioEngine.attach(playerNode)
        audioEngine.attach(timeChange)
        audioEngine.connect(playerNode, to: timeChange, format: nil)//format can be buffer.format
        audioEngine.connect(timeChange, to: audioEngine.mainMixerNode, format: nil)//format can be buffer.format
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {}
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
                
            }
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
}

