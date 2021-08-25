//
//  MusicPlayingController.swift
//  TestApplication
//
//  Created by alex on 18/08/16.
//  Copyright © 2016 Ziggeo Inc. All rights reserved.
//

import UIKit
import ZiggeoSwiftFramework
import AVKit
import AVFoundation

class MusicPlayingController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    
    var audioPlayer: ZiggeoAudioPlayer!
    var m_ziggeo: Ziggeo!
    var m_audioToken: String = ""
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, ziggeo: Ziggeo, audioToken: String) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.m_ziggeo = ziggeo
        self.m_audioToken = audioToken
        self.audioPlayer = ZiggeoAudioPlayer(ziggeo: self.m_ziggeo, audioToken: self.m_audioToken)
        self.audioPlayer.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.statusLabel.text = "Loading"
        self.playOrPauseButton.setTitle("", for: UIControl.State.normal)
        self.timeSlider.value = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.audioPlayer.pause()
        self.playOrPauseButton.setTitle("Play", for: UIControl.State.normal)
    }
    
    @IBAction func onChangeCurrentTime(_ sender: UISlider) {
        self.audioPlayer.seekToTime(sender.value)
    }
    
    @IBAction func onPlayOrPause(_ sender: Any) {
        if self.audioPlayer.isPlaying() {
            self.audioPlayer.pause()
            self.statusLabel.text = "Paused"
            self.playOrPauseButton.setTitle("Play", for: UIControl.State.normal)
        } else {
            self.audioPlayer.play()
            self.statusLabel.text = "Playing"
            self.playOrPauseButton.setTitle("Pause", for: UIControl.State.normal)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MusicPlayingController: ZiggeoAudioPlayerDelegate {
    func audioPlayerDidLoadedItem(_ audioPlayer: ZiggeoSwiftFramework.ZiggeoAudioPlayer) {
        self.statusLabel.text = ""
        self.playOrPauseButton.setTitle("Play", for: UIControl.State.normal)
        self.timeSlider.minimumValue = 0
        self.timeSlider.maximumValue = Float(audioPlayer.duration())
        self.timeSlider.value = 0
        print ("Duration : \(audioPlayer.duration())")
        
    }

    func audioPlayerPlayWith(_ audioPlayer: ZiggeoSwiftFramework.ZiggeoAudioPlayer, _ progress: Float) {
        let hours = Int(progress) / 3600
        let minutes = (Int(progress) % 3600) / 60
        let seconds = Int(progress) % 60
        self.currentTimeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        self.timeSlider.value = progress
        print ("\(progress)")
    }

    func audioPlayerDidFinishItem(_ audioPlayer: ZiggeoSwiftFramework.ZiggeoAudioPlayer) {
        self.statusLabel.text = ""
        self.playOrPauseButton.setTitle("Play", for: UIControl.State.normal)
    }
}

