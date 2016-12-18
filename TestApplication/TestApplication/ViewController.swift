//
//  ViewController.swift
//  TestApplication
//
//  Created by alex on 18/08/16.
//  Copyright © 2016 Ziggeo Inc. All rights reserved.
//

import UIKit
import ZiggeoSwiftFramework
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    var m_ziggeo: Ziggeo! = nil;
    var m_embeddedPlayer:AVPlayer! = nil;
    var m_embeddedPlayerLayer:AVPlayerLayer! = nil;
    @IBOutlet weak var videoViewPlaceholder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        m_ziggeo = Ziggeo(token: "ZIGGEO_APPLICATION_ID");
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func index(_ sender: AnyObject) {
        m_ziggeo.videos.Index(nil) { (jsonArray, error) in
            NSLog("index error: \(error), response: \(jsonArray)");
        };
    }

    func createPlayer()->AVPlayer {
        let player = AVPlayer(url: URL(string: m_ziggeo.videos.GetURLForVideo("ZIGGEO_VIDEO_ID"))!);
        return player;
    }
    
    
    @IBAction func playFullScreen(_ sender: AnyObject) {
        let playerController: AVPlayerViewController = AVPlayerViewController();
        playerController.player = createPlayer();
        self.present(playerController, animated: true, completion: nil);
        playerController.player?.play();
    }
    
    @IBAction func playEmbedded(_ sender: AnyObject) {
        if m_embeddedPlayer != nil {
            m_embeddedPlayer.pause();
            m_embeddedPlayerLayer.removeFromSuperlayer();
            m_embeddedPlayer = nil;
            m_embeddedPlayerLayer = nil;
        }
        m_embeddedPlayer = createPlayer();
        m_embeddedPlayerLayer = AVPlayerLayer(player: m_embeddedPlayer);
        m_embeddedPlayerLayer.frame = videoViewPlaceholder.frame;
        videoViewPlaceholder.layer.addSublayer(m_embeddedPlayerLayer);
        m_embeddedPlayer.play();
    }

    @IBAction func record(_ sender: AnyObject) {
        let recorder = ZiggeoRecorder(application: m_ziggeo);
        recorder.coverSelectorEnabled = true;
        recorder.cameraFlipButtonVisible = true;
        recorder.cameraDevice = UIImagePickerControllerCameraDevice.rear;
        self.present(recorder, animated: true, completion: nil);
    }
}

