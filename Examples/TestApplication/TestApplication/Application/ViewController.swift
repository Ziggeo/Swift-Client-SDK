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


final class ViewController: UIViewController {
    
    let ZIGGEO_APP_TOKEN  = "ZIGGEO_APP_TOKEN"
    let SERVER_AUTH_TOKEN = "SERVER_AUTH_TOKEN"
    let CLIENT_AUTH_TOKEN = "CLIENT_AUTH_TOKEN"
    
    var LAST_VIDEO_TOKEN = "LAST_VIDEO_TOKEN"
    var LAST_AUDIO_TOKEN = "LAST_AUDIO_TOKEN"
    var LAST_IMAGE_TOKEN = "LAST_IMAGE_TOKEN"
    
    private lazy var m_ziggeo: Ziggeo = {
        let ziggeo = Ziggeo(token: ZIGGEO_APP_TOKEN)
        ziggeo.hardwarePermissionDelegate = self
        ziggeo.uploadingDelegate = self
        ziggeo.fileSelectorDelegate = self
        ziggeo.recorderDelegate = self
        ziggeo.sensorDelegate = self
        ziggeo.playerDelegate = self
        ziggeo.screenRecorderDelegate = self
        return ziggeo
    }()
    fileprivate var currentType: MediaTypes?
}

// MARK: - @IBActions
private extension ViewController {
    @IBAction func onRecordVideo(_ sender: AnyObject) {
        currentType = .video
        
        let recorderConfig = RecorderConfig()
        recorderConfig.shouldAutoStartRecording = true
        recorderConfig.startDelay = DEFAULT_START_DELAY
        recorderConfig.shouldDisableCameraSwitch = false
        recorderConfig.videoQuality = QUALITY_HIGH
        recorderConfig.facing = FACING_BACK
        recorderConfig.maxDuration = 0
        recorderConfig.shouldSendImmediately = false
        recorderConfig.isPausedMode = true
        recorderConfig.resolution.aspectRatio = DEFAULT_ASPECT_RATIO
        recorderConfig.shouldConfirmStopRecording = true
        
        let stopRecordingConfirmationDialogConfig = StopRecordingConfirmationDialogConfig()
        stopRecordingConfirmationDialogConfig.titleText = "Ziggeo"
        stopRecordingConfirmationDialogConfig.mesText = "Do you want to stop recording?"
        stopRecordingConfirmationDialogConfig.posBtnText = "Yes"
        stopRecordingConfirmationDialogConfig.negBtnText = "No"
        recorderConfig.stopRecordingConfirmationDialogConfig = stopRecordingConfirmationDialogConfig
        
        recorderConfig.extraArgs = ["tags": "iOS,Video,Record",
                                    "client_auth": "CLIENT_AUTH_TOKEN",
                                    "server_auth": "SERVER_AUTH_TOKEN",
                                    "data": ["foo": "bar"],
                                    "effect_profile": "1234,5678"]
        self.m_ziggeo.setRecorderConfig(recorderConfig)
        
        self.m_ziggeo.record()
    }
    
    @IBAction func onPlayVideo(_ sender: AnyObject) {
        let playerConfig = PlayerConfig()
        playerConfig.adsUri = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator="
        self.m_ziggeo.setPlayerConfig(playerConfig)
        
        self.m_ziggeo.playVideo(LAST_VIDEO_TOKEN)
    }
    
    @IBAction func onChooseMedia(_ sender: Any) {
        currentType = nil
        
        let fileSelectorConfig = FileSelectorConfig()
        fileSelectorConfig.maxDuration = 0
        fileSelectorConfig.minDuration = 0
        fileSelectorConfig.shouldAllowMultipleSelection = true
        fileSelectorConfig.mediaType = [.video, .audio, .image]
        fileSelectorConfig.extraArgs = ["tags": "iOS,Choose,Media"]
        self.m_ziggeo.setFileSelectorConfig(fileSelectorConfig)
        
        self.m_ziggeo.startFileSelector()
    }
    
    @IBAction func onRecordAudio(_ sender: Any) {
        currentType = .audio
        
        let recorderConfig = RecorderConfig()
        recorderConfig.isPausedMode = true
        recorderConfig.extraArgs = ["tags": "iOS,Audio,Record"]
        self.m_ziggeo.setRecorderConfig(recorderConfig)
        
        self.m_ziggeo.startAudioRecorder()
    }
    
    @IBAction func onPlayAudio(_ sender: Any) {
        self.m_ziggeo.startAudioPlayer(LAST_AUDIO_TOKEN)
    }
    
    @IBAction func onTakePhoto(_ sender: Any) {
        currentType = .image
        
        let uploadingConfig = UploadingConfig()
        uploadingConfig.extraArgs = ["tags": "iOS,Take,Photo"]
        self.m_ziggeo.setUploadingConfig(uploadingConfig)
        
        self.m_ziggeo.startImageRecorder()
    }
    
    @IBAction func onShowImage(_ sender: Any) {
        self.m_ziggeo.showImage(LAST_IMAGE_TOKEN)
    }
    
    @IBAction func onCustomUIRecorder(_ sender: Any) {
        let recorderConfig = RecorderConfig()
        recorderConfig.shouldAutoStartRecording = false
        recorderConfig.videoQuality = QUALITY_HIGH
        recorderConfig.facing = FACING_BACK
        recorderConfig.maxDuration = 0
        recorderConfig.shouldSendImmediately = true
        recorderConfig.style.hideControls = true
        recorderConfig.resolution.setAspectRatio(DEFAULT_ASPECT_RATIO)
        recorderConfig.extraArgs = ["tags": "iOS,Video,Custom UI Record",
                                    "client_auth": "CLIENT_AUTH_TOKEN",
                                    "server_auth": "SERVER_AUTH_TOKEN",
                                    "data": ["foo": "bar"],
                                    "effect_profile": "1234,5678"]
        self.m_ziggeo.setRecorderConfig(recorderConfig)
        
        let recorder = ZiggeoRecorder(application: m_ziggeo)
        
        let customUIRecroderVC = CustomUIRecroderViewController(recorder: recorder)
        customUIRecroderVC.view.frame = CGRect(origin: .zero, size: recorder.view.bounds.size)
        recorder.view.addSubview(customUIRecroderVC.view)
        addChild(customUIRecroderVC)
        
        recorder.modalPresentationStyle = .fullScreen
        present(recorder, animated: true)
    }
}

// MARK: - ZiggeoHardwarePermissionDelegate
extension ViewController: ZiggeoHardwarePermissionDelegate {
    func checkCameraPermission(_ granted: Bool) {
        print("CheckCameraPermission : \(granted)")
    }
    
    func checkMicrophonePermission(_ granted: Bool) {
        print("CheckMicrophonePermission : \(granted)")
    }
    
    func checkPhotoLibraryPermission(_ granted: Bool) {
        print("CheckPhotoLibraryPermission : \(granted)")
    }
    
    func checkHasCamera(_ hasCamera: Bool) {
        print("CheckHasCamera : \(hasCamera)")
    }
    
    func checkHasMicrophone(_ hasMicrophone: Bool) {
        print("CheckHasMicrophone : \(hasMicrophone)")
    }
}

// MARK: - ZiggeoUploadingDelegate
extension ViewController: ZiggeoUploadingDelegate {
    func preparingToUpload(_ path: String) {
        print("Preparing To Upload : \(path)")
    }
    
    func error(_ info: RecordingInfo?, _ error: Error, _ lostConnectionAction: Int) {
        print("Failed To Upload : \(info?.token ?? "")")
    }
    
    func uploadStarted(_ path: String, token: String, streamToken: String, backgroundTask: URLSessionTask) {
        print("Upload Started : \(token) - \(streamToken)")
    }
    
    func uploadProgress(_ path: String, token: String, streamToken: String, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("Upload Progress : \(totalBytesSent) - \(totalBytesExpectedToSend)")
    }
    
    func uploadFinished(_ path: String, token: String, streamToken: String) {
        
    }
    
    func uploadVerified(_ path: String, token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
        print("Upload Verified : \(token) - \(streamToken)")
        switch currentType {
        case .video: LAST_VIDEO_TOKEN = token
        case .audio: LAST_AUDIO_TOKEN = token
        case .image: LAST_IMAGE_TOKEN = token
        default: break
        }
    }
    
    func uploadProcessing(_ path: String, token: String, streamToken: String) {
        print("Upload Processing : \(token) - \(streamToken)")
    }
    
    func uploadProcessed(_ path: String, token: String, streamToken: String) {
        print("Upload Processed : \(token) - \(streamToken)")
    }
    
    func delete(_ token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
        print("delete : \(token) - \(streamToken)")
    }
    
    func cancelUpload(_ path: String, deleteFile: Bool) {
        print("cancelUpload : \(path)")
    }
    
    func cancelCurrentUpload(_ deleteFile: Bool) {
        print("cancelCurrentUpload")
    }
}

// MARK: - ZiggeoFileSelectorDelegate
extension ViewController: ZiggeoFileSelectorDelegate {
    func uploadCancelledByUser() {
        print("Upload cancelled by User")
    }
    
    func uploadSelected(_ paths: [String]) {
        print("Upload Selected: \(paths)")
    }
}

// MARK: - ZiggeoRecorderDelegate
extension ViewController: ZiggeoRecorderDelegate {
    func recorderReady() {
        print("Recorder Ready")
    }
    
    func recorderCountdown(_ secondsLeft: Int) {
        print("Recorder Countdown left: \(secondsLeft)")
    }
    
    func recorderStarted() {
        print("Recorder Started")
    }
    
    func recorderStopped(_ path: String) {
        print("Recorder Stopped")
    }
    
    func recorderCurrentRecordedDurationSeconds(_ seconds: Double) {
        print("Recorder Recording Duration: \(seconds)")
    }
    
    func recorderPlaying() {
        print("Recorder Playing")
    }
    
    func recorderPaused() {
        print("Recorder Paused")
    }
    
    func recorderRerecord() {
        print("Recorder Rerecord")
    }
    
    func recorderManuallySubmitted() {
        print("Recorder Manually Submitted")
    }
    
    func streamingStarted() {
        print("Streaming Started")
    }
    
    func streamingStopped() {
        print("Streaming Stopped")
    }
    
    func recorderCancelledByUser() {
        print("Recorder Canceled")
    }
}

// MARK: - ZiggeoSensorDelegate
extension ViewController: ZiggeoSensorDelegate {
    func luxMeter(_ luminousity: Double) {
        // print("luminousity: \(luminousity)")
    }
    
    func audioMeter(_ audioLevel: Double) {
        // print("audio level: \(audioLevel)")
    }
    
    func faceDetected(_ faceID: Int, rect: CGRect) {
        // print("face \(faceID) detected with bounds: \(rect.origin.x):\(rect.origin.y) \(rect.size.width) x \(rect.size.height)")
    }
}

// MARK: - ZiggeoPlayerDelegate
extension ViewController: ZiggeoPlayerDelegate {
    func playerPlaying() {
        print("Player Playing")
    }
    
    func playerPaused() {
        print("Player Paused")
    }
    
    func playerEnded() {
        print("Player Ended")
    }
    
    func playerSeek(_ positionMillis: Double) {
        print("Player Seek : \(positionMillis)")
    }
    
    func playerReadyToPlay() {
        print("Player Ready To Play")
    }
    
    func playerCancelledByUser() {
        print("Player Cancelled By User")
    }
}

// MARK: - ZiggeoScreenRecorderDelegate
extension ViewController: ZiggeoScreenRecorderDelegate {
}
