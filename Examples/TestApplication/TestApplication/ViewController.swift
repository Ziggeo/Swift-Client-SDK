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
    fileprivate var currentType = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.m_ziggeo = Ziggeo(token: ZIGGEO_APP_TOKEN)
        self.m_ziggeo.hardwarePermissionDelegate = self
        self.m_ziggeo.uploadingDelegate = self
        self.m_ziggeo.fileSelectorDelegate = self
        self.m_ziggeo.recorderDelegate = self
        self.m_ziggeo.sensorDelegate = self
        self.m_ziggeo.playerDelegate = self
        self.m_ziggeo.screenRecorderDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: Button Click Action
    @IBAction func onRecordVideo(_ sender: AnyObject) {
        currentType = VIDEO
        
        let recorderConfig = RecorderConfig()
        recorderConfig.setShouldAutoStartRecording(true)
        recorderConfig.setStartDelay(DEFAULT_START_DELAY)
        recorderConfig.setShouldDisableCameraSwitch(false)
        recorderConfig.setVideoQuality(QUALITY_HIGH)
        recorderConfig.setFacing(FACING_BACK)
        recorderConfig.setMaxDuration(0)
        recorderConfig.setShouldSendImmediately(false)
        recorderConfig.setIsPausedMode(true)
        recorderConfig.resolution.setAspectRatio(DEFAULT_ASPECT_RATIO)
        recorderConfig.setShouldConfirmStopRecording(true)
        
        let stopRecordingConfirmationDialogConfig = StopRecordingConfirmationDialogConfig()
        stopRecordingConfirmationDialogConfig.setTitleText("Ziggeo")
        stopRecordingConfirmationDialogConfig.setMesText("Do you want to stop recording?")
        stopRecordingConfirmationDialogConfig.setPosBtnText("Yes")
        stopRecordingConfirmationDialogConfig.setNegBtnText("No")
        recorderConfig.setStopRecordingConfirmationDialogConfig(stopRecordingConfirmationDialogConfig)
        
        recorderConfig.setExtraArgs(["tags": "iOS,Video,Record",
                                     "client_auth" : "CLIENT_AUTH_TOKEN",
                                     "server_auth" : "SERVER_AUTH_TOKEN",
                                     "data" : ["foo": "bar"],
                                     "effect_profile" : "1234,5678"])
        self.m_ziggeo.setRecorderConfig(recorderConfig)
        
        self.m_ziggeo.record()
    }

    @IBAction func onPlayVideo(_ sender: AnyObject) {
        let playerConfig = PlayerConfig()
        playerConfig.setAdsUri("https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=")
        self.m_ziggeo.setPlayerConfig(playerConfig)

        self.m_ziggeo.playVideo(LAST_VIDEO_TOKEN)
    }

    @IBAction func onChooseMedia(_ sender: Any) {
        currentType = 0

        let fileSelectorConfig = FileSelectorConfig()
        fileSelectorConfig.setMaxDuration(0)
        fileSelectorConfig.setMinDuration(0)
        fileSelectorConfig.setShouldAllowMultipleSelection(true)
        fileSelectorConfig.setMediaType(VIDEO | AUDIO | IMAGE)
        fileSelectorConfig.setExtraArgs(["tags" : "iOS,Choose,Media"])
        self.m_ziggeo.setFileSelectorConfig(fileSelectorConfig)
        
        self.m_ziggeo.startFileSelector()
    }

    @IBAction func onRecordAudio(_ sender: Any) {
        currentType = AUDIO

        let recorderConfig = RecorderConfig()
        recorderConfig.setIsPausedMode(true)
        recorderConfig.setExtraArgs(["tags": "iOS,Audio,Record"])
        self.m_ziggeo.setRecorderConfig(recorderConfig)
        
        self.m_ziggeo.startAudioRecorder()
    }

    @IBAction func onPlayAudio(_ sender: Any) {
        self.m_ziggeo.startAudioPlayer(LAST_AUDIO_TOKEN)
    }

    @IBAction func onTakePhoto(_ sender: Any) {
        currentType = IMAGE
        
        let uploadingConfig = UploadingConfig()
        uploadingConfig.setExtraArgs(["tags": "iOS,Take,Photo"])
        self.m_ziggeo.setUploadingConfig(uploadingConfig)
        
        self.m_ziggeo.startImageRecorder()
    }

    @IBAction func onShowImage(_ sender: Any) {
        self.m_ziggeo.showImage(LAST_IMAGE_TOKEN)
    }
    
    @IBAction func onCustomUIRecorder(_ sender: Any) {
        let recorderConfig = RecorderConfig()
        recorderConfig.setShouldAutoStartRecording(false)
        recorderConfig.setVideoQuality(QUALITY_HIGH)
        recorderConfig.setFacing(FACING_BACK)
        recorderConfig.setMaxDuration(0)
        recorderConfig.setShouldSendImmediately(true)
        recorderConfig.style.setHideControls(true)
        recorderConfig.resolution.setAspectRatio(DEFAULT_ASPECT_RATIO)
        recorderConfig.setExtraArgs(["tags": "iOS,Video,Custom UI Record",
                                       "client_auth" : "CLIENT_AUTH_TOKEN",
                                       "server_auth" : "SERVER_AUTH_TOKEN",
                                       "data" : ["foo": "bar"],
                                       "effect_profile" : "1234,5678"])
        self.m_ziggeo.setRecorderConfig(recorderConfig)
        
        let m_recorder = ZiggeoRecorder(application: m_ziggeo)
        
        let customUIRecroderVC = CustomUIRecroderViewController(nibName: "CustomUIRecroderView", bundle: nil)
        customUIRecroderVC.m_recorder = m_recorder
        customUIRecroderVC.view.frame = CGRect(x: 0, y: 0, width: m_recorder.view.bounds.size.width, height: m_recorder.view.bounds.size.height)
        m_recorder.view.addSubview(customUIRecroderVC.view)
        self.addChild(customUIRecroderVC)
        
        m_recorder.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(m_recorder, animated: true, completion: nil)
    }
}

// MARK: - ZiggeoHardwarePermissionDelegate
extension ViewController: ZiggeoHardwarePermissionDelegate {
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
}

// MARK: - ZiggeoUploadingDelegate
extension ViewController: ZiggeoUploadingDelegate {
    func preparingToUpload(_ path: String) {
        print ("Preparing To Upload : \(path)")
    }

    func error(_ info: RecordingInfo?, _ error: Error, _ lostConnectionAction: Int) {
        print ("Failed To Upload : \(info?.getToken() ?? "")")
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
        if (currentType == VIDEO) {
            LAST_VIDEO_TOKEN = token
        } else if (currentType == AUDIO) {
            LAST_AUDIO_TOKEN = token
        } else if (currentType == IMAGE) {
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
    
    func cancelUpload(_ path: String, deleteFile: Bool) {
        print ("cancelUpload : \(path)")
    }
    
    func cancelCurrentUpload(_ deleteFile: Bool) {
        print ("cancelCurrentUpload")
    }
}

// MARK: - ZiggeoFileSelectorDelegate
extension ViewController: ZiggeoFileSelectorDelegate {
    func uploadCancelledByUser() {
        print ("Upload cancelled by User")
    }
    
    func uploadSelected(_ paths: [String]) {
        print ("Upload Selected: \(paths)")
    }
}

// MARK: - ZiggeoRecorderDelegate
extension ViewController: ZiggeoRecorderDelegate {
    func recorderReady() {
        print ("Recorder Ready")
    }
    
    func recorderCountdown(_ secondsLeft: Int) {
        print ("Recorder Countdown left: \(secondsLeft)")
    }
    
    func recorderStarted() {
        print ("Recorder Started")
    }
    
    func recorderStopped(_ path: String) {
        print ("Recorder Stopped")
    }
    
    func recorderCurrentRecordedDurationSeconds(_ seconds: Double) {
        print ("Recorder Recording Duration: \(seconds)")
    }
    
    func recorderPlaying() {
        print ("Recorder Playing")
    }
    
    func recorderPaused() {
        print ("Recorder Paused")
    }
    
    func recorderRerecord() {
        print ("Recorder Rerecord")
    }
    
    func recorderManuallySubmitted() {
        print ("Recorder Manually Submitted")
    }
    
    func streamingStarted() {
        print ("Streaming Started")
    }
    
    func streamingStopped() {
        print ("Streaming Stopped")
    }
    
    func recorderCancelledByUser() {
        print ("Recorder Canceled")
    }
    
}

// MARK: - ZiggeoSensorDelegate
extension ViewController: ZiggeoSensorDelegate {
    func luxMeter(_ luminousity: Double) {
        //print ("luminousity: \(luminousity)")
    }

    func audioMeter(_ audioLevel: Double) {
        //print ("audio level: \(audioLevel)")
    }

    func faceDetected(_ faceID: Int, rect: CGRect) {
        //print ("face \(faceID) detected with bounds: \(rect.origin.x):\(rect.origin.y) \(rect.size.width) x \(rect.size.height)")
    }
}

// MARK: - ZiggeoPlayerDelegate
extension ViewController: ZiggeoPlayerDelegate {
    func playerPlaying() {
        print ("Player Playing")
    }
    
    func playerPaused() {
        print ("Player Paused")
    }
    
    func playerEnded() {
        print ("Player Ended")
    }
    
    func playerSeek(_ positionMillis: Double) {
        print ("Player Seek : \(positionMillis)")
    }
    
    func playerReadyToPlay() {
        print ("Player Ready To Play")
    }
    
    func playerCancelledByUser() {
        print ("Player Cancelled By User")
    }
}

// MARK: - ZiggeoScreenRecorderDelegate
extension ViewController: ZiggeoScreenRecorderDelegate {
}
