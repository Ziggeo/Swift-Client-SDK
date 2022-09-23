//
//  ViewController.swift
//  TestApplication
//
//  Created by alex on 18/08/16.
//  Copyright © 2016 Ziggeo Inc. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import ReplayKit
import MobileCoreServices
import ZiggeoMediaSwiftSDK


class ViewController: UIViewController {

    let ZIGGEO_APP_TOKEN  = "ZIGGEO_APP_TOKEN"
    let SERVER_AUTH_TOKEN = "SERVER_AUTH_TOKEN"
    let CLIENT_AUTH_TOKEN = "CLIENT_AUTH_TOKEN"

    var LAST_VIDEO_TOKEN = "LAST_VIDEO_TOKEN"
    var LAST_AUDIO_TOKEN = "LAST_AUDIO_TOKEN"
    var LAST_IMAGE_TOKEN = "LAST_IMAGE_TOKEN"
    
    var m_ziggeo: Ziggeo!
    
    enum CurrentType {
        case Video
        case Audio
        case Image
        case Unknown
    }
    
    fileprivate var currentType = CurrentType.Unknown
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.m_ziggeo = Ziggeo(token: ZIGGEO_APP_TOKEN, delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: Button Click Action
    @IBAction func onRecordVideo(_ sender: AnyObject) {
        currentType = CurrentType.Video

        var config: [String: Any] = [:]
        config["tags"] = "iOS_Video_Record"
        self.m_ziggeo.setUploadingConfig(config)
        
        var themeMap: [String: Any] = [:]
        self.m_ziggeo.setThemeArgsForRecorder(themeMap)
        
        self.m_ziggeo.setBlurMode(true)
        self.m_ziggeo.setCamera(REAR_CAMERA)
        
        var map: [String: Any] = [:]
//        map["effect_profile"] = "12345"
//        map["data"] = [:]
//        map["client_auth"] = "CLIENT_AUTH_TOKEN"
//        map["server_auth"] = "SERVER_AUTH_TOKEN"
        self.m_ziggeo.setExtraArgsForRecorder(map)

        self.m_ziggeo.record()
    }

    @IBAction func onPlayVideo(_ sender: AnyObject) {
        var map: [String: Any] = [:]
        map["hidePlayerControls"] = "false"
        self.m_ziggeo.setThemeArgsForPlayer(map)

        self.m_ziggeo.playVideo(LAST_VIDEO_TOKEN)
    }

    @IBAction func onChooseMedia(_ sender: Any) {
        currentType = CurrentType.Video

        var config: [String: Any] = [:]
        config["tags"] = "iOS_Choose_Media"
        self.m_ziggeo.setUploadingConfig(config)
        
        var data: [String: Any] = [:]
//        data["media_types"] = ["video", "audio", "image"]
        self.m_ziggeo.uploadFromFileSelector(data)
    }

    @IBAction func onRecordAudio(_ sender: Any) {
        currentType = CurrentType.Audio

        var config: [String: Any] = [:]
        config["tags"] = "iOS_Audio_Record"
        self.m_ziggeo.setUploadingConfig(config)
        self.m_ziggeo.startAudioRecorder()
    }

    @IBAction func onPlayAudio(_ sender: Any) {
        self.m_ziggeo.startAudioPlayer(LAST_AUDIO_TOKEN)
    }

    @IBAction func onTakePhoto(_ sender: Any) {
        currentType = CurrentType.Image
        
        var config: [String: Any] = [:]
        config["tags"] = "iOS_Take_Photo"
        self.m_ziggeo.setUploadingConfig(config)
        self.m_ziggeo.startImageRecorder()
    }

    @IBAction func onShowImage(_ sender: Any) {
        self.m_ziggeo.showImage(LAST_IMAGE_TOKEN)
    }
}




//MARK: - ZiggeoDelegate
extension ViewController: ZiggeoDelegate {
    // ZiggeoRecorderDelegate
    func ziggeoRecorderLuxMeter(_ luminousity: Double) {
        //print ("luminousity: \(luminousity)")
    }

    func ziggeoRecorderAudioMeter(_ audioLevel: Double) {
        //print ("audio level: \(audioLevel)")
    }

    func ziggeoRecorderFaceDetected(_ faceID: Int, rect: CGRect) {
        //print ("face \(faceID) detected with bounds: \(rect.origin.x):\(rect.origin.y) \(rect.size.width) x \(rect.size.height)")
    }
    
    func ziggeoRecorderReady() {
        print ("Ziggeo Recorder Ready")
    }
    
    func ziggeoRecorderCanceled() {
        print ("Ziggeo Recorder Canceled")
    }
    
    func ziggeoRecorderStarted() {
        print ("Ziggeo Recorder Started")
    }
    
    func ziggeoRecorderStopped(_ path: String) {
        print ("Ziggeo Recorder Stopped")
    }
    
    func ziggeoRecorderCurrentRecordedDurationSeconds(_ seconds: Double) {
        print ("Ziggeo Recorder Recording Duration: \(seconds)")
    }
    
    func ziggeoRecorderPlaying() {
        print ("Ziggeo Recorder Playing")
    }
    
    func ziggeoRecorderPaused() {
        print ("Ziggeo Recorder Paused")
    }
    
    func ziggeoRecorderRerecord() {
        print ("Ziggeo Recorder Rerecord")
    }
    
    func ziggeoRecorderManuallySubmitted() {
        print ("Ziggeo Recorder Manually Submitted")
    }
    
    
    func ziggeoStreamingStarted() {
        print ("Ziggeo Streaming Started")
    }
    
    func ziggeoStreamingStopped() {
        print ("Ziggeo Streaming Stopped")
    }


    // ZiggeoUploadDelegate
    func preparingToUpload(_ path: String) {
        print ("Preparing To Upload : \(path)")
    }

    func failedToUpload(_ path: String) {
        print ("Failed To Upload : \(path)")
    }

    func uploadStarted(_ path: String, token: String, streamToken: String, backgroundTask: URLSessionTask) {
        print ("Upload Started : \(token) - \(streamToken)")
    }

    func uploadProgress(_ path: String, token: String, streamToken: String, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print ("Upload Progress : \(totalBytesSent) - \(totalBytesExpectedToSend)")
    }
    
    func uploadFinished(_ path:String, token: String, streamToken: String) {
        
    }
    
    func uploadVerified(_ path:String, token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
        print ("Upload Verified : \(token) - \(streamToken)")
        if (currentType == CurrentType.Video) {
            LAST_VIDEO_TOKEN = token
        } else if (currentType == CurrentType.Audio) {
            LAST_AUDIO_TOKEN = token
        } else if (currentType == CurrentType.Image) {
            LAST_IMAGE_TOKEN = token
        }
    }
    
    func uploadProcessing(_ path: String, token: String, streamToken: String) {
        print ("Upload Processing : \(token) - \(streamToken)")
    }
    
    func uploadProcessed(_ path: String, token: String, streamToken: String) {
        print ("Upload Processed : \(token) - \(streamToken)")
    }

    func delete(_ token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
        print ("delete : \(token) - \(streamToken)")
    }

    
    // ZiggeoHardwarePermissionCheckDelegate
    func checkCameraPermission(_ granted: Bool) {
        print ("CheckCameraPermission : \(granted)")
    }
    
    func checkMicrophonePermission(_ granted: Bool) {
        print ("CheckMicrophonePermission : \(granted)")
    }
    
    func checkPhotoLibraryPermission(_ granted: Bool) {
        print ("CheckPhotoLibraryPermission : \(granted)")
    }
    
    func checkHasCamera(_ hasCamera: Bool) {
        print ("CheckHasCamera : \(hasCamera)")
    }
    
    func checkHasMicrophone(_ hasMicrophone: Bool) {
        print ("CheckHasMicrophone : \(hasMicrophone)")
    }


    // ZiggeoPlayerDelegate
    func ziggeoPlayerPlaying() {
        print ("ziggeo Player Playing")
    }
    
    func ziggeoPlayerPaused() {
        print ("ziggeo Player Paused")
    }
    
    func ziggeoPlayerEnded() {
        print ("ziggeo Player Ended")
    }
    
    func ziggeoPlayerSeek(_ positionMillis: Double) {
        print ("ziggeo Player Seek : \(positionMillis)")
    }
    
    func ziggeoPlayerReadyToPlay() {
        print ("Ziggeo Player Ready To Play")
    }
}
