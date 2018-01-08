//
//  CustomPreviewController.swift
//  CustomPreview
//
//  Created by alex on 08/01/2018.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit
import ZiggeoSwiftFramework
import AVKit


class CustomPreviewController: UIViewController, VideoPreviewProtocol {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var videoPlaceholder: UIView!
    
    open var videoURL: URL!;
    open var previewDelegate: VideoPreviewDelegate!;
    
    var m_embeddedPlayer:AVPlayer!;
    var m_embeddedPlayerLayer: AVPlayerLayer!;
    var m_playing: Bool = false;
    
    
    public init() {
        super.init(nibName: "CustomPreviewController", bundle: Bundle(for: CustomPreviewController.self));
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open var shouldAutorotate : Bool {
        return false;
    }

    func killPlayer() {
        if m_embeddedPlayer != nil {
            m_embeddedPlayer.pause();
            NotificationCenter.default.removeObserver(self);
            m_embeddedPlayerLayer.removeFromSuperlayer();
            m_embeddedPlayerLayer = nil;
            m_embeddedPlayer = nil;
            m_playing = false;
            DispatchQueue.main.async(execute: {
                self.playButton.setTitle("Play", for: UIControlState.normal)
            });
        }
    }
    
    func initPlayer(_ url: URL) {
        if self.videoURL != nil && self.isViewLoaded
        {
            self.killPlayer();
            let playerItem: AVPlayerItem  = AVPlayerItem(url: url);
            NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem);
            m_embeddedPlayer = AVPlayer(playerItem: playerItem);
            m_embeddedPlayerLayer = AVPlayerLayer(player: m_embeddedPlayer);
            m_embeddedPlayerLayer.frame = self.videoPlaceholder.frame;
            videoPlaceholder.layer.addSublayer(m_embeddedPlayerLayer);
            m_playing = false;
        }
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        DispatchQueue.main.async(execute: {
            self.playButton.setTitle("Play", for: UIControlState.normal)
            self.m_embeddedPlayer.pause();
            self.m_embeddedPlayer.seek(to: CMTimeMake(0, 1));
        });
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        if(self.videoURL != nil) {
            self.initPlayer(self.videoURL);
        }
    }
    
    @IBAction func retake(_ sender: AnyObject) {
        self.killPlayer();
        super.dismiss(animated: false, completion: nil);
        self.previewDelegate?.retake(videoURL);
    }
    
    @IBAction func play(_ sender: AnyObject) {
        if(m_embeddedPlayer != nil) {
            if(m_playing) {
                m_embeddedPlayer.pause();
                m_playing = false;
            } else {
                m_embeddedPlayer.play();
                m_playing = true;
            }
            DispatchQueue.main.async(execute: {
                self.playButton.setTitle((self.m_playing ? "Pause" : "Play"), for: UIControlState.normal);
            });
        }
    }
    
    @IBAction func upload(_ sender: AnyObject) {
        self.killPlayer();
        self.dismiss(animated: false, completion: nil);
        self.previewDelegate?.upload(videoURL);
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
