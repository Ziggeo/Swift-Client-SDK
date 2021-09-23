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
    
    var audioPlayer: AVAudioPlayer!
    var m_ziggeo: Ziggeo!
    var m_audioToken: String = ""
    var timer: Timer?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, ziggeo: Ziggeo, audioToken: String) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.m_ziggeo = ziggeo
        self.m_audioToken = audioToken
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.audioPlayer != nil && self.audioPlayer.isPlaying {
            self.audioPlayer.stop()
        }
        self.playOrPauseButton.setTitle("Play", for: UIControl.State.normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.statusLabel.text = "Loading"
        self.playOrPauseButton.setTitle("", for: UIControl.State.normal)
        self.timeSlider.value = 0
        
        self.m_ziggeo.audios.downloadAudio(self.m_audioToken) { (filePath) in
            DispatchQueue.main.async {
                guard let fileUrl = URL(string: filePath) else {
                    return
                }
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: fileUrl)
                    self.audioPlayer.delegate = self
                    
                    self.statusLabel.text = ""
                    self.playOrPauseButton.setTitle("Play", for: UIControl.State.normal)
                    self.timeSlider.minimumValue = 0
                    if self.audioPlayer != nil {
                        self.timeSlider.maximumValue = Float(self.audioPlayer.duration)
                    }
                    self.timeSlider.value = 0
                } catch {
                    
                }
            }
        }
    }
    
    @IBAction func onChangeCurrentTime(_ sender: UISlider) {
        if self.audioPlayer != nil {
            self.audioPlayer.currentTime = TimeInterval(sender.value)
        }
    }
    
    @IBAction func onPlayOrPause(_ sender: Any) {
        if self.audioPlayer == nil {
            return
        }
        
        if self.audioPlayer.isPlaying {
            self.audioPlayer.pause()
            self.statusLabel.text = "Paused"
            self.playOrPauseButton.setTitle("Play", for: UIControl.State.normal)
        } else {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(playingAction), userInfo: nil, repeats: true)
            self.audioPlayer.play()
            self.statusLabel.text = "Playing"
            self.playOrPauseButton.setTitle("Pause", for: UIControl.State.normal)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.stopTimer()
        if self.audioPlayer != nil && self.audioPlayer.isPlaying {
            self.audioPlayer.stop()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    @objc func playingAction() {
        let progress = self.audioPlayer.currentTime
        let hours = Int(progress) / 3600
        let minutes = (Int(progress) % 3600) / 60
        let seconds = Int(progress) % 60
        DispatchQueue.main.async {
            self.currentTimeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            self.timeSlider.value = Float(progress)
        }
    }
}

extension MusicPlayingController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (flag == true) {
            self.statusLabel.text = ""
            self.playOrPauseButton.setTitle("Play", for: UIControl.State.normal)
            self.currentTimeLabel.text = "00:00:00";
            self.timeSlider.value = 0
            self.stopTimer()
        }
    }
}

