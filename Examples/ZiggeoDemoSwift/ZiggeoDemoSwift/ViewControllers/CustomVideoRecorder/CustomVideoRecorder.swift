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
    case unknown
    case success
    case cameraNotAuthorized
    case micNotAuthorized
    case sessionConfigurationFailed
}

final class CustomVideoRecorder: UIViewController {
    
    // MARK: - Public Properties
    var recordedVideoPreviewEnabled = true
    var cameraDevice: UIImagePickerController.CameraDevice = .rear
    var maxRecordedDurationSeconds: Double = 0
    var duration: Double = 0
    
    // MARK: - UI Properties
    @IBOutlet private weak var previewView: CapturePreviewView!
    @IBOutlet private weak var recordingDurationLabel: UILabel!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var cameraButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    
    // MARK: - Local Properties
    private var currentCMTime: CMTime?
    
    // session
    private let sessionQueue: DispatchQueue
    private let session: AVCaptureSession
    private var videoDeviceInput: AVCaptureDeviceInput! // swiftlint:disable:this implicitly_unwrapped_optional
    private var movieAssetWriter: AVAssetWriter?
    private var movieAssetWriterAudioInput: AVAssetWriterInput?
    private var movieAssetWriterVideoInput: AVAssetWriterInput?
    private var movieAssetWriterVideoInputAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var firstSampleRendered = false
    private var firstSampleTimestamp: Double = 0
    private var durationExceeded = false
    private var audioDataOutput: AVCaptureAudioDataOutput?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    
    private var setupResult: AVCamSetupResult = .unknown
    private var backgroundRecordingID = UIBackgroundTaskIdentifier(rawValue: 0)
    private var sessionRunning = false
    private var sessionObserver: NSKeyValueObservation?
    private var cleanup: (() -> Void)?
    private var durationUpdateTimer: Timer?
    
    private var videoSize: CGSize {
        // swiftlint:disable:next force_unwrapping
        switch previewView.videoPreviewLayer.connection!.videoOrientation {
        case .landscapeLeft, .landscapeRight:
            return CGSize(width: 1920, height: 1080)
        case .portrait, .portraitUpsideDown:
            return CGSize(width: 1080, height: 1920)
        @unknown default:
            fatalError("Unknown videoOrientation")
        }
    }
    
    // MARK: - System Functions
    init() {
        self.sessionQueue = DispatchQueue(label: "session queue")
        self.session = AVCaptureSession()
        self.session.sessionPreset = .medium
        super.init(nibName: Self.identifier, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var shouldAutorotate: Bool {
        return movieAssetWriter == nil || movieAssetWriter?.status != .writing
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.isEnabled = false
        recordButton.isEnabled = false
        
        // Setup the preview view.
        previewView.session = session
        setupResult = .success
        
        recordButton.setImage(.playIcon, for: .normal)
        recordButton.setImage(.stopIcon, for: .selected)
        
        
        // Check video authorization status. Video access is required and audio access is optional.
        // If audio access is denied, audio is not recorded during movie recording.
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break // The user has previously granted access to the camera.
            
        case .notDetermined:
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    self.setupResult = .cameraNotAuthorized
                }
                self.sessionQueue.resume()
            }
            
        default:
            // The user has previously denied access.
            setupResult = .cameraNotAuthorized
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            break // The user has previously granted access to the camera.
            
        case .notDetermined:
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if !granted {
                    self.setupResult = .micNotAuthorized
                }
                self.sessionQueue.resume()
            }
            
        default:
            // The user has previously denied access.
            setupResult = .micNotAuthorized
        }
        
        // Setup the capture session.
        // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
        // Why not do all of this on the main queue?
        // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
        // so that the main queue isn't blocked, which keeps the UI responsive.
        sessionQueue.async {
            guard self.setupResult == .success else {
                return
            }
            
            self.backgroundRecordingID = .invalid
            
            guard let videoDevice = self.getCameraDevice(preferringPosition: self.cameraDevice == .rear ? .back : .front),
                  let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                self.setupResult = .sessionConfigurationFailed
                return
            }
            
            self.session.beginConfiguration()
            guard self.session.canAddInput(videoDeviceInput) else {
                self.setupResult = .sessionConfigurationFailed
                return
            }
            self.session.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
            self.resetVideoOrientation()
            
            guard let audioDevice = AVCaptureDevice.default(for: .audio),
                  let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) else {
                self.setupResult = .sessionConfigurationFailed
                return
            }
            
            guard self.session.canAddInput(audioDeviceInput) else {
                self.setupResult = .sessionConfigurationFailed
                return
            }
            
            self.session.addInput(audioDeviceInput)
            
            let movieFileOutput = AVCaptureMovieFileOutput()
            guard self.session.canAddOutput(movieFileOutput) else {
                self.setupResult = .sessionConfigurationFailed
                return
            }
            self.setupDataOutputs()
            self.session.commitConfiguration()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let deviceOrientation = UIDevice.current.orientation
        guard deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
            return // Prevent face up/down cases handling
        }
        session.beginConfiguration()
        let previewLayer = previewView.videoPreviewLayer
        // swiftlint:disable force_unwrapping
        previewLayer.connection!.videoOrientation = AVCaptureVideoOrientation(orientation: deviceOrientation)!
        let connection = videoDataOutput?.connection(with: .video)
        connection?.videoOrientation = previewLayer.connection!.videoOrientation
        // swiftlint:enable force_unwrapping
        session.commitConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        previewView.layer.opacity = 0
        recordingDurationLabel.text = "00:00"
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.addObservers()
                self.session.startRunning()
                self.sessionRunning = self.session.isRunning
                
            case .cameraNotAuthorized:
                DispatchQueue.main.async { self.presentSettingsAlert(for: "camera") }
                
            case .micNotAuthorized:
                DispatchQueue.main.async { self.presentSettingsAlert(for: "microphone") }
                
            case .sessionConfigurationFailed:
                DispatchQueue.main.async {
                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "recorder", message: message, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                     style: .cancel,
                                                     handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true)
                }
                
            default: break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetVideoOrientation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard setupResult == .success else { return }
        session.stopRunning()
        removeObservers()
    }
}

// MARK: - @IBActions
private extension CustomVideoRecorder {
    @IBAction func onCloseButtonTap(_ sender: AnyObject) {
        dismiss(animated: true)
    }
    
    @IBAction func changeCamera(_ sender: AnyObject) {
        guard cameraButton.isEnabled else {
            return
        }
        
        cameraButton.isEnabled = false
        recordButton.isEnabled = false
        
        sessionQueue.async {
            defer {
                // we currently in self.sessionQueue.async so need to switch to DispatchQueue.main
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    self.recordButton.isEnabled = true
                }
            }
            
            let currentVideoDevice = self.videoDeviceInput.device
            let preferredPosition: AVCaptureDevice.Position
            
            switch currentVideoDevice.position {
            case .unspecified, .front: preferredPosition = .back
            case .back: preferredPosition = .front
            @unknown default:
                fatalError("Unknown AVCaptureDevice position")
            }
            
            guard let videoDevice = self.getCameraDevice(preferringPosition: preferredPosition),
                  let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                return
            }
            
            self.session.beginConfiguration()
            
            // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
            self.session.removeInput(self.videoDeviceInput)
            
            if self.session.canAddInput(videoDeviceInput) {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                // NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: videoDevice)
                
                self.session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                self.session.addInput(videoDeviceInput)
            }
            
            guard let connection = self.videoDataOutput?.connection(with: .video) else {
                return
            }
            
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
            }
            
            connection.isVideoMirrored = preferredPosition == .front
            
            DispatchQueue.main.async {
                // work with layers should be done in the main thread
                if let previewLayer = self.previewView?.videoPreviewLayer {
                    connection.videoOrientation = previewLayer.connection!.videoOrientation // swiftlint:disable:this force_unwrapping
                }
            }
            
            self.session.commitConfiguration()
        }
    }
    
    @IBAction func toggleMovieRecording(_ sender: AnyObject) {
        guard recordButton.isEnabled else {
            return
        }
        updateUIRecordingStartingStopping()
        
        sessionQueue.async {
            if let movieAssetWriter = self.movieAssetWriter {
                let outputURL = movieAssetWriter.outputURL
                
                movieAssetWriter.finishWriting {
                    self.processRecordedVideo(outputFileURL: outputURL, error: nil)
                }
                self.movieAssetWriter = nil
                self.movieAssetWriterVideoInput = nil
                self.movieAssetWriterAudioInput = nil
                self.movieAssetWriterVideoInputAdaptor = nil
            } else {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                // let connection = self.videoDataOutput?.connection(withMediaType: AVMediaTypeVideo)
                // let previewLayer = self.previewView.videoPreviewLayer
                // connection?.videoOrientation = previewLayer.connection.videoOrientation
                // do not do it here to avoid blinking on start
                self.duration = 0
                self.durationExceeded = false
                self.setupAssetWriter()
                
                self.updateUIRecordingStarted()
            }
        }
    }
}

// MARK: - Privates
private extension CustomVideoRecorder {
    var availableVideoDevices: [AVCaptureDevice] {
        availableCaptureDevices(for: [.builtInDualCamera,
                                      .builtInDualWideCamera,
                                      .builtInWideAngleCamera])
    }
    
    func availableCaptureDevices(for deviceTypes: [AVCaptureDevice.DeviceType], mediaType: AVMediaType = .video) -> [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                         mediaType: mediaType,
                                         position: .unspecified).devices
    }
    
    func resetVideoOrientation() {
        // self.sessionQueue.async {
        DispatchQueue.main.async {
            
            // Why are we dispatching this to the main queue?
            // Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
            // can only be manipulated on the main thread.
            // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
            // on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
            
            // Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
            // -[viewWillTransitionToSize:withTransitionCoordinator:].
            let interfaceOrientation = UIWindowScene.foreground?.interfaceOrientation ?? .unknown
            var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
            
            switch interfaceOrientation {
            case .landscapeLeft: initialVideoOrientation = .landscapeLeft
            case .landscapeRight: initialVideoOrientation = .landscapeRight
            case .portraitUpsideDown: initialVideoOrientation = .portraitUpsideDown
            default: initialVideoOrientation = .portrait
            }
            if let previewLayer = self.previewView?.videoPreviewLayer {
                previewLayer.connection?.videoOrientation = initialVideoOrientation
                self.sessionQueue.async {
                    if let connection = self.videoDataOutput?.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                        connection.videoOrientation = initialVideoOrientation
                    }
                }
            }
        }
    }
    
    func setupDataOutputs() {
        audioDataOutput = AVCaptureAudioDataOutput()
        audioDataOutput?.setSampleBufferDelegate(self, queue: sessionQueue)
        session.addOutput(audioDataOutput!) // swiftlint:disable:this force_unwrapping
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput?.alwaysDiscardsLateVideoFrames = true
        videoDataOutput?.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA]
        videoDataOutput?.setSampleBufferDelegate(self, queue: self.sessionQueue)
        session.addOutput(videoDataOutput!) // swiftlint:disable:this force_unwrapping
        let connection = self.videoDataOutput?.connection(with: .video)
        if connection?.isVideoStabilizationSupported == true {
            connection?.preferredVideoStabilizationMode = .auto
        }
        connection?.isVideoMirrored = cameraDevice == .front
    }
    
    func setupAssetWriter() {
        DispatchQueue.main.sync {
            let outputFileName = ProcessInfo.processInfo.globallyUniqueString
            let outputFilePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(outputFileName).mp4")
            do {
                self.movieAssetWriter = try AVAssetWriter(outputURL: outputFilePath, fileType: .mp4)
                
                let videoSize = self.videoSize
                movieAssetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: videoSize.width,
                    AVVideoHeightKey: videoSize.height
                ])
                movieAssetWriterVideoInput?.expectsMediaDataInRealTime = true
                // swiftlint:disable force_unwrapping
                if movieAssetWriter!.canAdd(movieAssetWriterVideoInput!) {
                    movieAssetWriter?.add(movieAssetWriterVideoInput!)
                }
                
                movieAssetWriterAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVNumberOfChannelsKey: 2,
                    AVSampleRateKey: 44100,
                    AVEncoderBitRateKey: 128000
                ])
                movieAssetWriterAudioInput?.expectsMediaDataInRealTime = true
                
                let sourcePixelBufferAttributesDictionary = ["\(kCVPixelFormatType_32ARGB)": kCVPixelBufferPixelFormatTypeKey]
                self.movieAssetWriterVideoInputAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.movieAssetWriterVideoInput!,
                                                                                              sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
                
                if movieAssetWriter!.canAdd(movieAssetWriterAudioInput!) {
                    movieAssetWriter?.add(movieAssetWriterAudioInput!)
                }
                // swiftlint:enable force_unwrapping
            } catch {
            }
        }
    }
    
    func addObservers() {
        sessionObserver = session.observe(\.isRunning, options: [.new]) { _, change in
            self.handleSessionStatus(isRunning: change.newValue ?? false)
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: NSNotification.Name.AVCaptureSessionRuntimeError,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: NSNotification.Name.AVCaptureSessionWasInterrupted,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: NSNotification.Name.AVCaptureSessionInterruptionEnded,
                                               object: session)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self) // swiftlint:disable:this notification_center_detachment
        sessionObserver.kill()
    }
    
    func updateUIRecordingStartingStopping() {
        cameraButton.isEnabled = false
        recordButton.isEnabled = false
    }
    
    func updateUIRecordingStarted() {
        DispatchQueue.main.async {
            self.recordButton.isEnabled = true
            self.recordButton.isSelected = true
            self.durationUpdateTimer.kill()
            self.durationUpdateTimer = Timer.scheduledTimer(timeInterval: 1,
                                                            target: self,
                                                            selector: #selector(self.updateDuration),
                                                            userInfo: nil,
                                                            repeats: true)
        }
    }
    
    func updateUIRecordingComplete() {
        DispatchQueue.main.async {
            self.cameraButton.isEnabled = self.availableVideoDevices.count > 1
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
            if self.maxRecordedDurationSeconds > 0 {
                let remainingDuration = max(self.maxRecordedDurationSeconds - currentDuration, 0)
                
                let minutesMax = Int(remainingDuration) / 60
                let secondsMax = Int(remainingDuration + 0.4) % 60
                currentDurationStr = String(format: "%02d:%02d", arguments: [minutesMax, secondsMax])
            }
            self.recordingDurationLabel.text = currentDurationStr
        }
    }
    
    func processRecordedVideo(outputFileURL: URL, error: Error?) {
        // Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
        // This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
        // is back to NO — which happens sometime after this method returns.
        // Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
        self.durationUpdateTimer.kill()
        self.updateDuration() // send last duration update
        
        let currentBackgroundRecordingID = self.backgroundRecordingID
        self.backgroundRecordingID = .invalid
        
        cleanup = {
            do {
                try FileManager.default.removeItem(at: outputFileURL)
            } catch {
            }
            if currentBackgroundRecordingID != .invalid {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
            }
        }
        var success = true
        if error != nil {
            // success = error?.userInfo[AVErrorRecordingSuccessfullyFinishedKey]?.boolValue ?? false
            let data = try? Data(contentsOf: outputFileURL)
            success = (data?.count ?? 0) > 1024
        }
        
        let moviePath = outputFileURL.path
        if success {
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath) {
                let avAsset = AVURLAsset(url: URL(fileURLWithPath: moviePath))
                let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: avAsset)
                if compatiblePresets.contains(AVAssetExportPresetLowQuality) {
                    let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
                    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let videoPath = "\(paths[0])/\(Int(CFAbsoluteTimeGetCurrent())).mp4"
                    exportSession?.outputURL = URL(fileURLWithPath: videoPath)
                    exportSession?.outputFileType = .mp4
                    
                    exportSession?.exportAsynchronously {
                        switch exportSession?.status {
                        case .completed:
                            guard self.recordedVideoPreviewEnabled else {
                                return self.uploadVideo(exportSession!.outputURL!) // swiftlint:disable:this force_unwrapping
                            }
                            DispatchQueue.main.async {
                                self.openVideoPreviewPlayer(url: exportSession!.outputURL!) // swiftlint:disable:this force_unwrapping
                            }
                            
                        default:
                            self.cleanup?()
                        }
                    }
                }
            }
        } else {
            cleanup?()
        }
        
        updateUIRecordingComplete()
    }
    
    func openVideoPreviewPlayer(url: URL) {
        let videoPreview = CustomVideoPlayer()
        videoPreview.isRecordingPreview = true
        videoPreview.previewDelegate = self
        videoPreview.videoURL = url
        present(videoPreview, animated: true)
    }
    
    func handleSessionStatus(isRunning: Bool) {
        DispatchQueue.main.async {
            self.cameraButton.isEnabled = isRunning && self.availableVideoDevices.count > 1
            self.recordButton.isEnabled = isRunning
            self.previewView.layer.opacity = 0
            
            if isRunning {
                UIView.animate(withDuration: 0.25, animations: {
                    self.previewView.layer.opacity = 1
                })
            }
        }
    }
    
    @objc func sessionRuntimeError(_ notification: Notification) {
        let error = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError
        if error?.code == AVError.Code.mediaServicesWereReset.rawValue {
            sessionQueue.async {
                if self.sessionRunning {
                    self.session.startRunning()
                    self.sessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    @objc func sessionWasInterrupted(_ notification: Notification) {
        DispatchQueue.main.async {
            self.previewView.layer.opacity = 0
        }
    }
    
    @objc func sessionInterruptionEnded(_ notification: Notification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.previewView.layer.opacity = 1
            })
        }
    }
    
    func getCameraDevice(preferringPosition: AVCaptureDevice.Position) -> AVCaptureDevice? {
        // Choose the back dual camera, if available, otherwise default to a wide angle camera.
        if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: preferringPosition) {
            return dualCameraDevice
        } else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: preferringPosition) {
            // If a rear dual camera is not available, default to the rear dual wide camera.
            return dualWideCameraDevice
        } else if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: preferringPosition) {
            // If a rear dual wide camera is not available, default to the rear wide angle camera.
            return cameraDevice
        } else {
            let devices = availableVideoDevices
            return devices.first { $0.position == preferringPosition } ?? devices.first
        }
    }
    
    func presentSettingsAlert(for deviceName: String) {
        let message = NSLocalizedString("recorder doesn't have permission to use the \(deviceName), please change privacy settings",
                                        comment: "Alert message when the user has denied access to the \(deviceName)")
        let alertController = UIAlertController(title: "recorder", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                         style: .cancel,
                                         handler: nil)
        alertController.addAction(cancelAction)
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings",
                                                                    comment: "Alert button to open Settings"),
                                           style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) // swiftlint:disable:this force_unwrapping
        }
        alertController.addAction(settingsAction)
        present(alertController, animated: true)
    }
}

// MARK: - VideoPreviewDelegate
extension CustomVideoRecorder: VideoPreviewDelegate {
    func retake(_ fileToBeRemoved: URL) {
        do {
            try FileManager.default.removeItem(at: fileToBeRemoved)
        } catch { }
        cleanup?()
        resetVideoOrientation()
    }
    
    func uploadVideo(_ filePath: URL) {
        let tmpDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        var newFileToUpload = tmpDirectory.appendingPathComponent(filePath.lastPathComponent)
        
        do {
            try FileManager.default.copyItem(at: filePath, to: newFileToUpload)
        } catch {
            newFileToUpload = filePath // try to use original file, maybe it will not be removed before it will be uploaded
        }
        
        Common.ziggeo?.uploadFromPath(filePath.absoluteString, data: [:], callback: { _, _, _ in
        }, progress: { _, _ in
        }, confirmCallback: { _, _, _ in
        })
        dismiss(animated: false)
    }
    
    func close() {
        dismiss(animated: false)
    }
}

// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
extension CustomVideoRecorder: AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        sessionQueue.async {
            if output == self.videoDataOutput {
                if self.durationExceeded { return }
                self.currentCMTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                let currentTimestamp = CMTimeGetSeconds(self.currentCMTime!) // swiftlint:disable:this force_unwrapping
                if let movieAssetWriter = self.movieAssetWriter {
                    if movieAssetWriter.status == .unknown {
                        movieAssetWriter.startWriting()
                        movieAssetWriter.startSession(atSourceTime: self.currentCMTime!) // swiftlint:disable:this force_unwrapping
                        self.firstSampleTimestamp = currentTimestamp
                    }
                    
                    if movieAssetWriter.status != .failed,
                       let movieAssetWriterVideoInput = self.movieAssetWriterVideoInput,
                       movieAssetWriterVideoInput.isReadyForMoreMediaData {
                        if movieAssetWriterVideoInput.append(sampleBuffer) {
                            self.firstSampleRendered = true
                        }
                        
                        if self.maxRecordedDurationSeconds > 0 && fabs(currentTimestamp - self.firstSampleTimestamp) >= self.maxRecordedDurationSeconds {
                            self.durationExceeded = true
                            self.toggleMovieRecording(self)
                        }
                    }
                }
                self.duration = currentTimestamp - self.firstSampleTimestamp
            } else if output == self.audioDataOutput {
            }
        }
    }
}
