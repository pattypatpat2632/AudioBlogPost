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
    var buffer: AVAudioBuffer?
    var frameCount: AVAudioFrameCount = 30000
    var player: AVAudioPlayer?
    let changePitch = AVAudioUnitTimePitch()
    
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
        audioEngine.attach(changePitch)
        audioEngine.connect(playerNode, to: changePitch, format: nil)//format can be buffer.format
        audioEngine.connect(changePitch, to: audioEngine.mainMixerNode, format: nil)//format can be buffer.format
        audioEngine.prepare()
        try! audioEngine.start()
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        label.text = String(sender.value)
        changePitch.rate = sender.value/120
        
        
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        let url = Bundle.main.url(forResource: "keys", withExtension: ".wav")
        if let url = url {
            
            do {
                let audioFile = try AVAudioFile(forReading: url)
                changePitch.rate = slider.value/120
                playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            } catch {
                
            }
        }
        playerNode.play()
    }



}

