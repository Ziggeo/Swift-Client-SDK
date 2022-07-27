//
//  CustomVideoRecorder.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import Foundation
import AVFoundation
import UIKit


enum AVCamSetupResult {
    case none
    case success
    case cameraNotAuthorized
    case micNotAuthorized
    case sessionConfigurationFailed
}

enum RecordingQuality: Int {
    case LowQuality
    case MediumQuality
    case HighestQuality
}

open class CustomVideoRecorder: UIViewController {
    
    // MARK: - Public Properties
    var recordedVideoPreviewEnabled: Bool = true
    var cameraDevice: UIImagePickerController.CameraDevice = UIImagePickerController.CameraDevice.rear
    var videoPreview: CustomVideoPlayer! = nil
    var maxRecordedDurationSeconds: Double = 0
    var extraArgsForCreateVideo: [AnyHashable : Any]? = nil
    var duration: Double = 0
    
    // MARK: - UI Properties
    @IBOutlet weak var previewView: CapturePreviewView!
    @IBOutlet weak var recordingDurationLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Local Properties
    var currentCMTime: CMTime? = nil
    
    //session
    let sessionQueue: DispatchQueue
    var session: AVCaptureSession! = nil
    var videoDeviceInput: AVCaptureDeviceInput! = nil
    var movieAssetWriter: AVAssetWriter? = nil
    var movieAssetWriterAudioInput: AVAssetWriterInput? = nil
    var movieAssetWriterVideoInput: AVAssetWriterInput? = nil
    var movieAssetWriterVideoInputAdaptor: AVAssetWriterInputPixelBufferAdaptor? = nil
    var firstSampleRendered: Bool = false
    var firstSampleTimestamp: Double = 0
    var durationExceeded: Bool = false
    var audioDataOutput: AVCaptureAudioDataOutput? = nil
    var videoDataOutput: AVCaptureVideoDataOutput? = nil
    var metadataOutput: AVCaptureMetadataOutput? = nil
    
    var setupResult: AVCamSetupResult = AVCamSetupResult.none
    var backgroundRecordingID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
    var sessionRunning: Bool = false
    var sessionRunningContext:Int? = nil
    var cleanup:(()->Void)! = nil
    var durationUpdateTimer:Timer! = nil
    
    var videoWidth: Int {
        get {
            let previewLayer = self.previewView.layer as! AVCaptureVideoPreviewLayer
            switch(previewLayer.connection!.videoOrientation) {
            case .landscapeLeft:
                return 1920
            case .landscapeRight:
                return 1920
            case .portrait:
                return 1080
            case .portraitUpsideDown:
                return 1080
            }
        }
    }

    var videoHeight: Int {
        get {
            let previewLayer = self.previewView.layer as! AVCaptureVideoPreviewLayer
            switch(previewLayer.connection!.videoOrientation) {
            case .landscapeLeft:
                return 1080
            case .landscapeRight:
                return 1080
            case .portrait:
                return 1920
            case .portraitUpsideDown:
                return 1920
            }
        }
    }

    
    
    // MARK: - System Functions
    init() {
        self.sessionQueue = DispatchQueue(label: "session queue", attributes: [])
        super.init(nibName: "CustomVideoRecorder", bundle: Bundle(for: CustomVideoRecorder.self))
        self.videoPreview = CustomVideoPlayer()
        self.videoPreview.isRecordingPreview = true
        self.videoPreview.previewDelegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var shouldAutorotate : Bool {
        return !(self.movieAssetWriter != nil && self.movieAssetWriter?.status == .writing)
    }
    
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let deviceOrientation = UIDevice.current.orientation
        if (deviceOrientation.isPortrait || deviceOrientation.isLandscape) {
            self.session.beginConfiguration()
            let previewLayer = self.previewView.layer as! AVCaptureVideoPreviewLayer
            previewLayer.connection!.videoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue)!
            let connection = self.videoDataOutput?.connection(with: AVMediaType.video)
            connection?.videoOrientation = previewLayer.connection!.videoOrientation
            self.session.commitConfiguration()
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.previewView.layer.opacity = 0.0
            self.recordingDurationLabel.text = "00:00"
        }
        self.sessionQueue.async {
            switch ( self.setupResult )
            {
            case .success:
                self.addObservers()
                self.session.startRunning()
                self.sessionRunning = self.session.isRunning
                break
                
            case AVCamSetupResult.cameraNotAuthorized:
                DispatchQueue.main.async(execute: {
                    let message = NSLocalizedString("recorder doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "recorder", message: message, preferredStyle: UIAlertController.Style.alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertAction.Style.cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: UIAlertAction.Style.default, handler: { (action) in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    })
                    alertController.addAction(settingsAction)
                    self.present(alertController, animated: true, completion: nil)
                })
                break
            case AVCamSetupResult.micNotAuthorized:
                DispatchQueue.main.async(execute: {
                    let message = NSLocalizedString("recorder doesn't have permission to use the microphone, please change privacy settings", comment: "Alert message when the user has denied access to the microphone")
                    let alertController = UIAlertController(title: "recorder", message: message, preferredStyle: UIAlertController.Style.alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertAction.Style.cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: UIAlertAction.Style.default, handler: { (action) in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    })
                    alertController.addAction(settingsAction)
                    self.present(alertController, animated: true, completion: nil)
                })
                break
            case .sessionConfigurationFailed:
                DispatchQueue.main.async(execute: {
                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "recorder", message: message, preferredStyle: UIAlertController.Style.alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertAction.Style.cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                })
                break
            default: break
            }
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        self.resetVideoOrientation()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        self.sessionQueue.async {
            if(self.setupResult == AVCamSetupResult.success) {
                self.session.stopRunning()
                self.removeObservers()
            }
        }
        super.viewDidDisappear(animated)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &sessionRunningContext {
            let isSessionRunning = (change?[NSKeyValueChangeKey.newKey] as AnyObject).boolValue
            
            DispatchQueue.main.async {
                
                self.cameraButton.isEnabled = isSessionRunning != nil && isSessionRunning! && (AVCaptureDevice.devices(for: AVMediaType.video).count > 1)
                self.recordButton.isEnabled = isSessionRunning != nil && isSessionRunning!
                self.previewView.layer.opacity = 0.0

                if let isSessionRunning = isSessionRunning, isSessionRunning {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.previewView.layer.opacity = 1.0
                    })
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.cameraButton.isEnabled = false
        self.recordButton.isEnabled = false
        
        // Create the AVCaptureSession.
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSession.Preset.medium
        
        // Setup the preview view.
        self.previewView.session = self.session
        self.setupResult = AVCamSetupResult.success
        
        recordButton.setImage(UIImage(named: "ic_play"), for: .normal)
        recordButton.setImage(UIImage(named: "ic_stop"), for: .selected)
    
        
        // Check video authorization status. Video access is required and audio access is optional.
        // If audio access is denied, audio is not recorded during movie recording.
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            case AVAuthorizationStatus.authorized:
                // The user has previously granted access to the camera.
                break
            
            case AVAuthorizationStatus.notDetermined:
                // The user has not yet been presented with the option to grant video access.
                // We suspend the session queue to delay session setup until the access request has completed to avoid
                // asking the user for audio access if video access is denied.
                // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
                self.sessionQueue.suspend()
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    if(!granted) {
                        self.setupResult = AVCamSetupResult.cameraNotAuthorized
                    }
                    self.sessionQueue.resume()
                })
                break
            default:
                // The user has previously denied access.
                self.setupResult = AVCamSetupResult.cameraNotAuthorized
                break
        }
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) {
            case AVAuthorizationStatus.authorized:
                // The user has previously granted access to the camera.
                break
            
            case AVAuthorizationStatus.notDetermined:
                // The user has not yet been presented with the option to grant video access.
                // We suspend the session queue to delay session setup until the access request has completed to avoid
                // asking the user for audio access if video access is denied.
                // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
                self.sessionQueue.suspend()
                AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted) in
                    if(!granted) {
                        self.setupResult = AVCamSetupResult.micNotAuthorized
                    }
                    self.sessionQueue.resume()
                })
                break
            default:
                // The user has previously denied access.
                self.setupResult = AVCamSetupResult.micNotAuthorized
                break
        }

        // Setup the capture session.
        // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
        // Why not do all of this on the main queue?
        // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
        // so that the main queue isn't blocked, which keeps the UI responsive.
        self.sessionQueue.async {
            if(self.setupResult != AVCamSetupResult.success) {
                return
            }
            
            self.backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
            let videoDevice = self.createDevice(AVMediaType.video.rawValue, preferringPosition: self.cameraDevice == UIImagePickerController.CameraDevice.rear ? AVCaptureDevice.Position.back : AVCaptureDevice.Position.front)
            let videoDeviceInput = try?AVCaptureDeviceInput.init(device: videoDevice!)
            
            if (videoDeviceInput == nil) {
                self.setupResult = AVCamSetupResult.sessionConfigurationFailed
                return
            }
            
            self.session.beginConfiguration()
            if (self.session.canAddInput(videoDeviceInput!)) {
                self.session.addInput(videoDeviceInput!)
                self.videoDeviceInput = videoDeviceInput
                self.resetVideoOrientation()
            } else {
                self.setupResult = AVCamSetupResult.sessionConfigurationFailed
                return
            }
            
            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
            let audioDeviceInput = try?AVCaptureDeviceInput(device: audioDevice!)
            
            if (audioDeviceInput == nil) {
                self.setupResult = AVCamSetupResult.sessionConfigurationFailed
                return
            }
            
            if (self.session.canAddInput(audioDeviceInput!) ) {
                self.session.addInput(audioDeviceInput!)
            } else {
                self.setupResult = AVCamSetupResult.sessionConfigurationFailed
                return
            }

            let movieFileOutput = AVCaptureMovieFileOutput()
            if (self.session.canAddOutput(movieFileOutput)) {
                self.setupMetadataOutput()
                self.setupDataOutputs()
            } else {
                self.setupResult = AVCamSetupResult.sessionConfigurationFailed
                return
            }
            self.session.commitConfiguration()
        }
    }
    
    
    // MARK: - Button Click Actions
    @IBAction open func onCloseButtonTap(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction open func changeCamera(_ sender: AnyObject) {
        DispatchQueue.main.async {
            
            guard self.cameraButton.isEnabled else {
                return
            }

            self.cameraButton.isEnabled = false
            self.recordButton.isEnabled = false

            self.sessionQueue.async {
                defer {
                    // we currently in self.sessionQueue.async so need to switch to DispatchQueue.main
                    DispatchQueue.main.async {
                        self.cameraButton.isEnabled = true
                        self.recordButton.isEnabled = true
                    }
                }

                let currentVideoDevice = self.videoDeviceInput.device
                var preferredPosition = AVCaptureDevice.Position.unspecified
                let currentPosition = currentVideoDevice.position

                switch currentPosition {
                    case .unspecified: preferredPosition = AVCaptureDevice.Position.back
                    case .front: preferredPosition = AVCaptureDevice.Position.back
                    case .back: preferredPosition = AVCaptureDevice.Position.front
                }

                guard let videoDevice = self.createDevice(AVMediaType.video.rawValue, preferringPosition: preferredPosition) else {
                    return
                }

                guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                    return
                }

                self.session.beginConfiguration()

                // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
                self.session.removeInput(self.videoDeviceInput)

                if self.session.canAddInput(videoDeviceInput) {
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
//                    NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: videoDevice)

                    self.session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                } else {
                    self.session.addInput(videoDeviceInput)
                }

                guard let connection = self.videoDataOutput?.connection(with: AVMediaType.video) else {
                    return
                }

                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                }

                connection.isVideoMirrored = preferredPosition == AVCaptureDevice.Position.front


                DispatchQueue.main.async {
                    // work with layers should be done in the main thread
                    if
                        let previewView = self.previewView,
                        let previewLayer = previewView.layer as? AVCaptureVideoPreviewLayer
                    {
                        connection.videoOrientation = previewLayer.connection!.videoOrientation
                    }
                }

                self.session.commitConfiguration()
            }
        }
    }

    @IBAction open func toggleMovieRecording(_ sender: AnyObject) {
        DispatchQueue.main.async {

            guard self.recordButton.isEnabled else {
                return
            }

            self.sessionQueue.async {
                self.updateUIRecordingStartingStopping()

                if self.movieAssetWriter == nil {
                    if UIDevice.current.isMultitaskingSupported {
                        self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                    }

                    // let connection = self.videoDataOutput?.connection(withMediaType: AVMediaTypeVideo)
                    // let previewLayer = self.previewView.layer as! AVCaptureVideoPreviewLayer
                    // connection?.videoOrientation = previewLayer.connection.videoOrientation
                    // do not do it here to avoid blinking on start
                    self.duration = 0
                    self.durationExceeded = false
                    self.setupAssetWriter()

                    self.updateUIRecordingStarted()
                } else {
                    if let movieAssetWriter = self.movieAssetWriter {
                        let outputURL = movieAssetWriter.outputURL

                        movieAssetWriter.finishWriting {
                            self.processRecordedVideo(outputFileURL: outputURL, error: nil)
                        }
                    }

                    self.movieAssetWriter = nil
                    self.movieAssetWriterVideoInput = nil
                    self.movieAssetWriterAudioInput = nil
                    self.movieAssetWriterVideoInputAdaptor = nil
                }
            }
        }
    }
    
    
    
    // MARK: - Custom Functions
    func resetVideoOrientation() {
        //self.sessionQueue.async {
        DispatchQueue.main.async {

            // Why are we dispatching this to the main queue?
            // Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
            // can only be manipulated on the main thread.
            // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
            // on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
            
            // Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
            // -[viewWillTransitionToSize:withTransitionCoordinator:].
            let statusBarOrientation = UIApplication.shared.statusBarOrientation
            var initialVideoOrientation = AVCaptureVideoOrientation.portrait
            
            if ( statusBarOrientation != UIInterfaceOrientation.unknown ) {
                switch statusBarOrientation {
                case .landscapeLeft: initialVideoOrientation = AVCaptureVideoOrientation.landscapeLeft
                case .landscapeRight: initialVideoOrientation = AVCaptureVideoOrientation.landscapeRight
                case .portraitUpsideDown: initialVideoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
                default: initialVideoOrientation = AVCaptureVideoOrientation.portrait
                }
            }
            if(self.previewView != nil) {
                if let previewLayer = self.previewView.layer as? AVCaptureVideoPreviewLayer {
                    previewLayer.connection?.videoOrientation = initialVideoOrientation
                    self.sessionQueue.async {
                        if let connection = self.videoDataOutput?.connection(with: AVMediaType.video) {
                            if(connection.isVideoStabilizationSupported) {
                                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                            }
                            connection.videoOrientation = initialVideoOrientation
                        }
                    }
                }
            }
        }
    }

    func setupMetadataOutput() {
        self.metadataOutput = AVCaptureMetadataOutput()
        if (self.session.canAddOutput(self.metadataOutput!)) {
            self.metadataOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            self.session.addOutput(self.metadataOutput!)
            self.metadataOutput?.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
            NSLog("metadata detector added")
        }
    }
    
    func setupDataOutputs() {
        self.audioDataOutput = AVCaptureAudioDataOutput()
        self.audioDataOutput?.setSampleBufferDelegate(self, queue: self.sessionQueue)
        self.session.addOutput(self.audioDataOutput!)
        
        self.videoDataOutput = AVCaptureVideoDataOutput()
        self.videoDataOutput?.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        self.videoDataOutput?.setSampleBufferDelegate(self, queue: self.sessionQueue)
        self.session.addOutput(self.videoDataOutput!)
        let connection = self.videoDataOutput?.connection(with: AVMediaType.video)
        if(connection?.isVideoStabilizationSupported)! {
            connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
        }
        connection?.isVideoMirrored = (self.cameraDevice == UIImagePickerController.CameraDevice.front)
    }
    
    func setupAssetWriter() {
        DispatchQueue.main.sync {
            let outputFileName = ProcessInfo.processInfo.globallyUniqueString
            let outputFilePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(outputFileName).mp4")
            do {
                self.movieAssetWriter = try AVAssetWriter(outputURL: outputFilePath, fileType: AVFileType.mp4)
                movieAssetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [
                    AVVideoCodecKey: AVVideoCodecH264,
                    AVVideoWidthKey: self.videoWidth,
                    AVVideoHeightKey: self.videoHeight,
                    ])
                movieAssetWriterVideoInput?.expectsMediaDataInRealTime = true
                if (movieAssetWriter!.canAdd(movieAssetWriterVideoInput!)) {
                    movieAssetWriter?.add(movieAssetWriterVideoInput!)
                }
                
                movieAssetWriterAudioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVNumberOfChannelsKey: 2,
                    AVSampleRateKey: 44100,
                    AVEncoderBitRateKey: 128000,
                    ])
                movieAssetWriterAudioInput?.expectsMediaDataInRealTime = true
                
                if (movieAssetWriterVideoInput != nil) {
                    let sourcePixelBufferAttributesDictionary = ["\(kCVPixelFormatType_32ARGB)": kCVPixelBufferPixelFormatTypeKey]
                    self.movieAssetWriterVideoInputAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.movieAssetWriterVideoInput!, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
                }
                
                if (movieAssetWriter!.canAdd(movieAssetWriterAudioInput!)) {
                    movieAssetWriter?.add(movieAssetWriterAudioInput!)
                }
            } catch let error {
            }
        }
    }
    
    func addObservers() {
        self.session.addObserver(self, forKeyPath: "running", options: NSKeyValueObservingOptions.new, context: &sessionRunningContext)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: NSNotification.Name.AVCaptureSessionRuntimeError, object: self.session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: self.session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: NSNotification.Name.AVCaptureSessionInterruptionEnded, object: self.session)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        self.session.removeObserver(self, forKeyPath: "running", context: &sessionRunningContext)
    }
    
    

    func updateUIRecordingStartingStopping() {
        DispatchQueue.main.async {
            self.cameraButton.isEnabled = false
            self.recordButton.isEnabled = false
        }
    }
    
    func updateUIRecordingStarted() {
        DispatchQueue.main.async {
            self.recordButton.isEnabled = true
            self.recordButton.isSelected = true
            self.durationUpdateTimer?.invalidate()
            self.durationUpdateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateDuration), userInfo: nil, repeats: true)
        }
    }
    
    func updateUIRecordingComplete() {
        DispatchQueue.main.async {
            self.cameraButton.isEnabled = AVCaptureDevice.devices(for: AVMediaType.video).count > 1
            self.recordButton.isEnabled = true
            self.recordButton.isSelected = false
        }
    }
    
    
    
    @objc func updateDuration() {
        DispatchQueue.main.async {
            let currentDuration = self.duration
            let minutes = Int(currentDuration + 0.4) / 60
            let seconds = Int(currentDuration + 0.4) % 60
            
            var currentDurationStr = String(format: "%02d:%02d", arguments: [minutes, seconds])
            if(self.maxRecordedDurationSeconds > 0)
            {
                var remainingDuration = self.maxRecordedDurationSeconds - currentDuration
                if(remainingDuration < 0) {
                    remainingDuration = 0
                }
                let minutesMax = Int(remainingDuration) / 60
                let secondsMax = Int(remainingDuration + 0.4) % 60
                let maxDurationStr = String(format: "%02d:%02d", arguments: [minutesMax, secondsMax])
                currentDurationStr = "\(maxDurationStr)"
            }
            self.recordingDurationLabel.text = currentDurationStr
        }
    }
    
    open func processRecordedVideo(outputFileURL: URL!, error: Error!) {
        // Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
        // This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
        // is back to NO — which happens sometime after this method returns.
        // Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
        self.durationUpdateTimer?.invalidate()
        self.updateDuration() //send last duration update
        
        let currentBackgroundRecordingID = self.backgroundRecordingID
        self.backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
        
        cleanup = {
            do {
                try FileManager.default.removeItem(at: outputFileURL)
            } catch {
            }
            if (currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid) {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
            }
        }
        var success = true
        if ( error != nil ) {
            //success = (error!.userInfo[AVErrorRecordingSuccessfullyFinishedKey]?.boolValue)!
            success = false
            let data = try?Data.init(contentsOf: outputFileURL)
            success = (data != nil && data!.count > 1024)
        }
        
        let moviePath = outputFileURL.path
        if ( success ) {
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
                let avAsset = AVURLAsset(url: URL(fileURLWithPath: moviePath))
                let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: avAsset)
                if compatiblePresets.contains(AVAssetExportPresetLowQuality) {
                    let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
                    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let videoPath = "\(paths.first!)/\(Int(CFAbsoluteTimeGetCurrent())).mp4"
                    exportSession?.outputURL = URL(fileURLWithPath: videoPath)
                    exportSession?.outputFileType = AVFileType.mp4
                    
                    exportSession?.exportAsynchronously(completionHandler: {
                        switch (exportSession!.status) {
                        case AVAssetExportSession.Status.failed:
                            self.cleanup()
                            break
                        case AVAssetExportSession.Status.cancelled:
                            self.cleanup()
                            break
                        case AVAssetExportSession.Status.completed:
                            if (self.videoPreview != nil && self.recordedVideoPreviewEnabled) {
                                DispatchQueue.main.async(execute: {
                                    self.videoPreview.videoURL = exportSession?.outputURL
                                    self.videoPreview.videoRecorder = self
                                    self.present(self.videoPreview, animated: true, completion: nil)
                                })
                            } else {
                                self.uploadVideo(exportSession!.outputURL!)
                            }
                            break
                        default:
                            self.cleanup?()
                            break
                        }
                    })
                }
            }
        } else {
            cleanup?()
        }
        
        self.updateUIRecordingComplete()
    }
    
    @objc func sessionRuntimeError(_ notification: Notification) {
        let error = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError
        if(error?.code == AVError.Code.mediaServicesWereReset.rawValue) {
            self.sessionQueue.async(execute: {
                if (self.sessionRunning) {
                    self.session.startRunning()
                    self.sessionRunning = self.session.isRunning
                }
            })
        }
    }
    
    @objc func sessionWasInterrupted(_ notification: Notification) {
        DispatchQueue.main.async {
            self.previewView.layer.opacity = 0.0
        }
    }
    
    @objc func sessionInterruptionEnded(_ notification: Notification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.previewView.layer.opacity = 1.0
            })
        }
    }
    
    func createDevice(_ mediaType: String, preferringPosition: AVCaptureDevice.Position)->AVCaptureDevice? {
        var defaultVideoDevice: AVCaptureDevice?
        // Choose the back dual camera, if available, otherwise default to a wide angle camera.
        if #available(iOS 10.2, *) {
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: preferringPosition) {
                defaultVideoDevice = dualCameraDevice
            }
        }
        if defaultVideoDevice == nil {
            if #available(iOS 13.0, *) {
                if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: preferringPosition) {
                    // If a rear dual camera is not available, default to the rear dual wide camera.
                    defaultVideoDevice = dualWideCameraDevice
                }
            }
        }
                
        if defaultVideoDevice == nil {
            if #available(iOS 10.0, *) {
                if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: preferringPosition) {
                    // If a rear dual wide camera is not available, default to the rear wide angle camera.
                    defaultVideoDevice = cameraDevice
                }
            }
        }
        
        if defaultVideoDevice == nil {
            let devices = AVCaptureDevice.devices(for: AVMediaType(rawValue: mediaType))
            defaultVideoDevice = devices.first
            for device in devices {
                if(device.position == preferringPosition) {
                    defaultVideoDevice = device
                    break
                }
            }
        }

        return defaultVideoDevice
    }
}


// MARK: - VideoPreviewDelegate
extension CustomVideoRecorder: VideoPreviewDelegate {
    
    open func retake(_ fileToBeRemoved:URL!) {
        if (fileToBeRemoved != nil){
            do {
                try FileManager.default.removeItem(at: fileToBeRemoved!)
            } catch { }
        }
        cleanup?()
        resetVideoOrientation()
    }

    open func uploadVideo(_ filePath: URL) {
        let tmpDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        var newFileToUpload = tmpDirectory.appendingPathComponent(filePath.lastPathComponent)

        do {
            try FileManager.default.copyItem(at: filePath, to: newFileToUpload)
        } catch {
            newFileToUpload = filePath // try to use original file, maybe it will not be removed before it will be uploaded
        }

        DispatchQueue.main.async {
            let realFilePath = filePath.absoluteString.replacingOccurrences(of: "file://", with: "")
            Common.ziggeo?.uploadFromPath(realFilePath, data: [:], callback: { jsonObject, response, error in
            }, progress: { totalBytesSent, totalBytesExpectedToSend in
            }, confirmCallback: { jsonObject, response, error in
            })
        }
    }
}

// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
extension CustomVideoRecorder: AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        sessionQueue.async {
            if (output == self.videoDataOutput) {
                if (!self.durationExceeded) {
                    self.currentCMTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    let currentTimestamp = CMTimeGetSeconds(self.currentCMTime!)
                    if let movieAssetWriter = self.movieAssetWriter {
                        if (movieAssetWriter.status == .unknown) {
                            movieAssetWriter.startWriting()
                            movieAssetWriter.startSession(atSourceTime: self.currentCMTime!)
                            self.firstSampleTimestamp = currentTimestamp
                        }

                        if (movieAssetWriter.status == .failed) {
                        } else if let movieAssetWriterVideoInput = self.movieAssetWriterVideoInput {
                            if (movieAssetWriterVideoInput.isReadyForMoreMediaData) {
                                if (!movieAssetWriterVideoInput.append(sampleBuffer)) {
                                } else {
                                    self.firstSampleRendered = true
                                }
                                
                                if (self.maxRecordedDurationSeconds > 0 && fabs(currentTimestamp - self.firstSampleTimestamp) >= self.maxRecordedDurationSeconds) {
                                    self.durationExceeded = true
                                    self.toggleMovieRecording(self)
                                }
                            }
                        }
                    }
                    self.duration = (currentTimestamp - self.firstSampleTimestamp)
                }
            } else if (output == self.audioDataOutput) {
            }
        }
    }

}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension CustomVideoRecorder: AVCaptureMetadataOutputObjectsDelegate {
    
    open func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let previewLayer = self.previewView.layer as? AVCaptureVideoPreviewLayer
    }
}
