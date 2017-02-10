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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZiggeoRecorderDelegate, ZiggeoVideosDelegate {
    
    var m_ziggeo: Ziggeo! = nil;
    var m_embeddedPlayer:AVPlayer! = nil;
    var m_embeddedPlayerLayer:AVPlayerLayer! = nil;
    @IBOutlet weak var videoViewPlaceholder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        m_ziggeo = Ziggeo(token: "ZIGGEO_APP_ID");
        m_ziggeo.enableDebugLogs = false;
        m_ziggeo.videos.delegate = self;
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

    @IBAction func uploadExisting(_ sender: Any) {
        let imagePickerController = UIImagePickerController();
        imagePickerController.sourceType = .photoLibrary;
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = ["public.movie"];
        present(imagePickerController, animated: true, completion: nil);
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        picker.dismiss(animated:true, completion: nil)
        let videoURL = info["UIImagePickerControllerMediaURL"] as? NSURL;
        m_ziggeo.videos.CreateVideo(nil, file: videoURL!.path!, cover: nil, callback: nil, progress: nil);
    }
    
    @IBAction func record(_ sender: AnyObject) {
        let recorder = ZiggeoRecorder(application: m_ziggeo);
        recorder.coverSelectorEnabled = true;
        recorder.cameraFlipButtonVisible = true;
        recorder.cameraDevice = UIImagePickerControllerCameraDevice.rear;
        recorder.recorderDelegate = self;
        self.present(recorder, animated: true, completion: nil);
    }
    
    public func ziggeoRecorderDidCancel() {
        NSLog("cancellation");
    }
    
    public func ziggeoRecorderRetake(_ oldFile: URL!) {
        NSLog("file \(oldFile) removed, recording restarted");
    }

    public func VideoPreparingToUpload(_ sourcePath: String) {
        NSLog("preparing to upload \(sourcePath) video");
    }
    
    public func VideoPreparingToUpload(_ sourcePath: String, token: String) {
        NSLog("preparing to upload \(sourcePath) video with token \(token)");
    }
    
    public func VideoFailedToUpload(_ sourcePath: String) {
        NSLog("failed to upload \(sourcePath) video");
    }
    
    public func VideoUploadStarted(_ sourcePath: String, token: String, backgroundTask: URLSessionTask) {
        NSLog("upload started with \(sourcePath) video and token \(token)");
    }
    
    public func VideoUploadComplete(_ sourcePath: String, token: String, response: URLResponse?, error: NSError?, json:  NSDictionary?) {
        NSLog("upload complete with \(sourcePath) video and token \(token)");
    }
    
    public func VideoUploadProgress(_ sourcePath: String, token: String, totalBytesSent: Int64, totalBytesExpectedToSend:  Int64) {
        NSLog("upload progress is \(totalBytesSent) from total \(totalBytesExpectedToSend)");
    }

}

