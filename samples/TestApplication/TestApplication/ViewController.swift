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
import ReplayKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZiggeoRecorderDelegate, ZiggeoVideosDelegate {

    let appGroup = "group.Ziggeo.TestApplication.Group"

    let adsUrl: String? = nil

    var m_ziggeo: Ziggeo {
        AppDelegate.ziggeo.videos.delegate = self
        return AppDelegate.ziggeo
    }

    @IBOutlet weak var videoViewPlaceholder: UIView!
    var m_recorder: ZiggeoRecorder! = nil;

    var lastRecordedToken: String! = "aceba4c0a3bc5db81e67cb9861703634"; //will be updated when new recording is done
    var uploaderTask: URLSessionTask! = nil;

    var queuePlayer: AVQueuePlayer! = nil;
    var playerLayer: AVPlayerLayer! = nil;

    //custom UI
    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var toggleRecordingButton: UIBarButtonItem!
    @IBOutlet weak var switchCameraButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func index(_ sender: AnyObject) {
        m_ziggeo.videos.index([
            "skip": "0",
        ]) {
            jsonArray, error in
            NSLog("index error: \(error), response: \(jsonArray)")
        }
    }



    @IBAction func playFullScreen(_ sender: AnyObject) {

        ZiggeoPlayer.createPlayerWithAdditionalParams(application: m_ziggeo, videoToken: lastRecordedToken/*VIDEO_TOKEN*/, params: ["client_auth":"CLIENT_AUTH_TOKEN"]) { (player:ZiggeoPlayer?) in
            DispatchQueue.main.async {
                let playerController: AVPlayerViewController = AVPlayerViewController();
                playerController.player = player;
                self.present(playerController, animated: true, completion: nil);

                DispatchQueue.main.async {
                    if let player = player {
                        if let adsUrl = self.adsUrl {
                            player.requestAds(adTagURLString: self.adsUrl, adContainer: playerController.view)
                        }
                        player.play()
                    }
                }
            }
        }
    }

    @IBAction func playEmbedded(_ sender: AnyObject) {
        let playerController: AVPlayerViewController = AVPlayerViewController();
        let player = ZiggeoPlayer(application: m_ziggeo, videoToken: lastRecordedToken/*"VIDEO_TOKEN"*/)
        playerController.player = player
        addChild(playerController)
        videoViewPlaceholder.addSubview(playerController.view);
        playerController.view.frame = CGRect(x:0,y:0,width:videoViewPlaceholder.frame.width, height:videoViewPlaceholder.frame.height);

        if let adsUrl = adsUrl {
            player.requestAds(adTagURLString: self.adsUrl, adContainer: playerController.view)
        }
        player.play()
    }

    @IBAction func uploadExisting(_ sender: Any) {
        let imagePickerController = UIImagePickerController();
        imagePickerController.sourceType = .photoLibrary;
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = ["public.movie"];
        present(imagePickerController, animated: true, completion: nil);
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated:true, completion: nil)
        let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL;
        uploaderTask = m_ziggeo.videos.createVideo(["data":"{\"foo\":\"bar\"}"], file: videoURL!.path!, cover: nil, callback: nil, progress: nil);
    }

    @IBAction func record(_ sender: AnyObject) {
        let recorder = ZiggeoRecorder(application: m_ziggeo);
        recorder.coverSelectorEnabled = true;
        recorder.recordedVideoPreviewEnabled = true;
        recorder.cameraFlipButtonVisible = true;
        recorder.cameraDevice = UIImagePickerController.CameraDevice.front;
        recorder.showSoundIndicator = true;
        recorder.showLightIndicator = true;
        recorder.showFaceOutline = true;
        recorder.recorderDelegate = self;

        recorder.maxRecordedDurationSeconds = 0; //infinite
        //recorder.extraArgsForCreateVideo = ["data":"{\"foo\":\"bar\"}"]; //pass custom data
        //recorder.extraArgsForCreateVideo = ["effect_profile": "EFFECT_ID"];
        //recorder.extraArgsForCreateVideo = ["client_auth":"CLIENT_AUTH_TOKEN"]; //recorder-level auth token
        //m_ziggeo.connect.clientAuthToken = "CLIENT_AUTH_TOKEN"; //global auth token

        let customizeButtons = false
        if customizeButtons {
            let recorderUIConfig = ZiggeoRecorderInterfaceConfig()
            recorderUIConfig.recordButton.scale = 0.75
            recorderUIConfig.closeButton.scale = 0.5
            recorderUIConfig.cameraFlipButton.scale = 0.5
            if let flipCameraPath = Bundle.main.url(forResource: "FlipCamera", withExtension: "png")?.path {
                recorderUIConfig.cameraFlipButton.imagePath = flipCameraPath
            }
            recorder.recorderUIConfig = recorderUIConfig
        }

        self.present(recorder, animated: true, completion: nil);
    }

    @IBAction func playSequenceOfVideos(_ sender: Any) {
        ZiggeoPlayer.createPlayerForMultipleVideos(application: m_ziggeo, videoTokens: ["VIDEO_TOKEN_1", "VIDEO_TOKEN_2", "VIDEO_TOKEN_N"], params: nil) { (player) in
            DispatchQueue.main.async {
                self.queuePlayer = player;
                self.playerLayer = AVPlayerLayer(player: player)

                self.playerLayer.frame = self.videoViewPlaceholder.layer.bounds
                self.videoViewPlaceholder.layer.addSublayer(self.playerLayer)
                player?.play();
            }
        }

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
        lastRecordedToken = token;
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
        m_recorder.cameraDevice = UIImagePickerController.CameraDevice.front;
        m_recorder.recorderDelegate = self;
        m_recorder.showControls = false;
        m_recorder.extraArgsForCreateVideo = ["effect_profile": "EFFECT_ID"];
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

    public func ziggeoRecorderLuxMeter(_ luminousity: Double) {
        //NSLog("luminousity: \(luminousity)");
    }

    public func ziggeoRecorderAudioMeter(_ audioLevel: Double) {
        //NSLog("audio level: \(audioLevel)");
    }

    public func ziggeoRecorderFaceDetected(_ faceID: Int, rect: CGRect) {
        //NSLog("face \(faceID) detected with bounds: \(rect.origin.x):\(rect.origin.y) \(rect.size.width) x \(rect.size.height)");
    }

    @IBAction func didTapRecordScreenButton(_ sender: Any) {
        let rect = CGRect(x: 20, y: 100, width: 50, height: 50)
        m_ziggeo.videos.startScreenRecording(addRecordingButtonToView: view, frame: rect, appGroup: appGroup)
    }
    
}

