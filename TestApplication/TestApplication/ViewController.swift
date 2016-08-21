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
        m_ziggeo = Ziggeo(token: "30392b6a5591929ddd19242c1225b349");
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func index(sender: AnyObject) {
        m_ziggeo.videos.Index(nil) { (jsonArray, error) in
            NSLog("index error: \(error), response: \(jsonArray)");
        };
    }

    func createPlayer()->AVPlayer {
        //return ZiggeoPlayer(application: m_ziggeo, videoToken: "99c641539cfcd1792fcd24631630b29b");
        let player = AVPlayer(URL: NSURL(string: m_ziggeo.videos.GetURLForVideo("99c641539cfcd1792fcd24631630b29b"))!);
        return player;
    }
    
    
    @IBAction func playFullScreen(sender: AnyObject) {
        let playerController: AVPlayerViewController = AVPlayerViewController();
        playerController.player = createPlayer();
        self.presentViewController(playerController, animated: true, completion: nil);
        playerController.player?.play();
    }
    
    @IBAction func playEmbedded(sender: AnyObject) {
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

    @IBAction func record(sender: AnyObject) {
        let recorder = ZiggeoRecorder(application: m_ziggeo);
        recorder.coverSelectorEnabled = true;
        recorder.cameraFlipButtonVisible = true;
        recorder.cameraDevice = UIImagePickerControllerCameraDevice.Rear;
        self.presentViewController(recorder, animated: true, completion: nil);
    }
}

