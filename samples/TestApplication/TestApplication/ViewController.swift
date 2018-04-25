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
    @IBOutlet weak var videoViewPlaceholder: UIView!
    var m_recorder: ZiggeoRecorder! = nil;


    //custom UI
    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var toggleRecordingButton: UIBarButtonItem!
    @IBOutlet weak var switchCameraButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        m_ziggeo = Ziggeo(token: "ZIGGEO_APP_TOKEN");
        m_ziggeo.enableDebugLogs = true;
        m_ziggeo.videos.delegate = self;
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func index(_ sender: AnyObject) {
        m_ziggeo.videos.index(nil) { (jsonArray, error) in
            NSLog("index error: \(error), response: \(jsonArray)");
        };
    }

   
    
    @IBAction func playFullScreen(_ sender: AnyObject) {
        ZiggeoPlayer.createPlayerWithAdditionalParams(application: m_ziggeo, videoToken: "VIDEO_TOKEN", params: ["client_auth":"CLIENT_AUTH_TOKEN"]) { (player:ZiggeoPlayer?) in
            DispatchQueue.main.async {
                let playerController: AVPlayerViewController = AVPlayerViewController();
                playerController.player = player;
                self.present(playerController, animated: true, completion: nil);
                playerController.player?.play();
            }
        }
    }
    
    @IBAction func playEmbedded(_ sender: AnyObject) {
        let playerController: AVPlayerViewController = AVPlayerViewController();
        playerController.player = ZiggeoPlayer(application: m_ziggeo, videoToken: "VIDEO_TOKEN");
        self.addChildViewController(playerController);
        self.videoViewPlaceholder.addSubview(playerController.view);
        playerController.view.frame = CGRect(x:0,y:0,width:videoViewPlaceholder.frame.width, height:videoViewPlaceholder.frame.height);
        playerController.player?.play();
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
        m_ziggeo.videos.createVideo(nil, file: videoURL!.path!, cover: nil, callback: nil, progress: nil);
    }
    
    @IBAction func record(_ sender: AnyObject) {
        let recorder = ZiggeoRecorder(application: m_ziggeo);
        recorder.coverSelectorEnabled = true;
        recorder.recordedVideoPreviewEnabled = true;
        recorder.cameraFlipButtonVisible = true;
        recorder.cameraDevice = UIImagePickerControllerCameraDevice.rear;
        recorder.recorderDelegate = self;
        recorder.maxRecordedDurationSeconds = 0; //infinite
        //recorder.extraArgsForCreateVideo = ["client_auth":"CLIENT_AUTH_TOKEN"];
        //m_ziggeo.connect.clientAuthToken = "CLIENT_AUTH_TOKEN";
        self.present(recorder, animated: true, completion: nil);
    }
    
    //
    // ZiggeoRecorder main delegate
    //
    
    public func ziggeoRecorderDidCancel() {
        NSLog("cancellation");
    }
    
    public func ziggeoRecorderRetake(_ oldFile: URL!) {
        NSLog("file \(oldFile) removed, recording restarted");
    }

    //
    // ziggeo.videos delegate
    //
    public func videoPreparingToUpload(_ sourcePath: String) {
        NSLog("preparing to upload \(sourcePath) video");
    }
    
    public func videoPreparingToUpload(_ sourcePath: String, token: String) {
        NSLog("preparing to upload \(sourcePath) video with token \(token)");
    }
    
    public func videoFailedToUpload(_ sourcePath: String) {
        NSLog("failed to upload \(sourcePath) video");
    }
    
    public func videoUploadStarted(_ sourcePath: String, token: String, backgroundTask: URLSessionTask) {
        NSLog("upload started with \(sourcePath) video and token \(token)");
    }
    
    public func videoUploadComplete(_ sourcePath: String, token: String, response: URLResponse?, error: NSError?, json:  NSDictionary?) {
        NSLog("upload complete with \(sourcePath) video and token \(token)");
    }
    
    public func videoUploadProgress(_ sourcePath: String, token: String, totalBytesSent: Int64, totalBytesExpectedToSend:  Int64) {
        NSLog("upload progress is \(totalBytesSent) from total \(totalBytesExpectedToSend)");
    }
    
    //
    // Custom UI
    //

    @IBAction func recordCustomUI(_ sender: Any) {
        m_recorder = ZiggeoRecorder(application: m_ziggeo);
        m_recorder.coverSelectorEnabled = true;
        m_recorder.recordedVideoPreviewEnabled = true;
        m_recorder.cameraFlipButtonVisible = true;
        m_recorder.cameraDevice = UIImagePickerControllerCameraDevice.rear;
        m_recorder.recorderDelegate = self;
        m_recorder.showControls = false;
        m_recorder.extraArgsForCreateVideo = ["effect_profile": "12345"];
        Bundle.main.loadNibNamed("CustomRecorderControls", owner: self, options: nil);
        m_recorder.overlayView = self.overlayView;
        self.present(m_recorder, animated: true, completion: nil);
    }

    
    @IBAction func closeButtonCustomUI(_ sender: Any) {
        m_recorder?.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func toggleRecordingCustomUI(_ sender: Any) {
        m_recorder?.toggleMovieRecording(self);
    }
    
    @IBAction func switchCameraCustomUI(_ sender: Any) {
        m_recorder?.changeCamera(self);
    }
    
    //
    // custom UI recorder delegate
    //
    public func ziggeoRecorderDidStartRecording() {
        toggleRecordingButton?.title = "stop";
        switchCameraButton?.isEnabled = false;
    }
    
    public func ziggeoRecorderDidFinishRecording() {
        toggleRecordingButton?.title = "record";
        switchCameraButton?.isEnabled = true;
    }

    //enable camera control buttons after capture session initialization
    public func ziggeoRecorderCaptureSessionStateChanged(_ runningNow: Bool) {
        toggleRecordingButton?.isEnabled = true;
        switchCameraButton?.isEnabled = true;
    }
    
    public func ziggeoRecorderCurrentRecordedDuration(_ seconds: Double) {
        NSLog("recording duration: \(seconds)");
    }

}

