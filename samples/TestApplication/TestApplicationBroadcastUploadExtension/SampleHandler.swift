//
//  SampleHandler.swift
//  TestApplicationBroadcastUploadExtension
//
//  Created by Admin on 03.09.2020.
//  Copyright © 2020 Ziggeo Inc. All rights reserved.
//

import ReplayKit
import Photos

class SampleHandler: RPBroadcastSampleHandler {

    var isRecordingVideo = false

    var videoOutputFullFileName: URL?

    var videoWriterInput: AVAssetWriterInput?

    private var audioWriterInput: AVAssetWriterInput?

    private var videoWriter: AVAssetWriter!

    private var lastSampleTime: CMTime = CMTime()

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        let filename = UUID().uuidString
        videoOutputFullFileName = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")

        isRecordingVideo = true

        let session = AVCaptureSession()
        session.sessionPreset = .hd1920x1080

//        guard
//            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified),
//            let input = try? AVCaptureDeviceInput(device: device),
//            session.canAddInput(input) else { return }

//        session.beginConfiguration()
//        session.addInput(input)
//        session.commitConfiguration()

        //let output = AVCaptureVideoDataOutput()
        //guard session.canAddOutput(output) else { return }
        //output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.yusuke024.video"))
        //session.beginConfiguration()
        //session.addOutput(output)
        //session.commitConfiguration()


        session.startRunning()
//        _videoOutput = output
        _captureSession = session

        let screen = UIScreen.main
        let screenBounds = screen.bounds
        let videoCompressionProperties = [
            AVVideoAverageBitRateKey: screenBounds.width * screenBounds.height * 10.1
        ]

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: screenBounds.width,
            AVVideoHeightKey: screenBounds.height,
            //AVVideoCompressionPropertiesKey: videoCompressionProperties
        ]

        guard let videoOutputFullFileName = videoOutputFullFileName else {
            print("Failed to generate videoOutputFullFileName")
            return
        }

        videoWriter = try! AVAssetWriter(outputURL: videoOutputFullFileName, fileType: .mov)

        let settings =
             videoSettings
//            _videoOutput!.recommendedVideoSettingsForAssetWriter(writingTo: .mov)


        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings) // [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
        //input.mediaTimeScale = CMTimeScale(bitPattern: 600)
        input.expectsMediaDataInRealTime = true
        //input.transform = CGAffineTransform(rotationAngle: .pi/2)
        
        let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
        if videoWriter.canAdd(input) {
            videoWriter.add(input)
        }
        
        let started = videoWriter.startWriting()

        if !started {
            print("Failed to start writing")
        }

        videoWriter.startSession(atSourceTime: .zero)
        _assetWriter = videoWriter
        _assetWriterInput = input
//        _adpater = adapter
        _captureState = .capturing

        //_time = timestamp

    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // streamer.appendSampleBuffer(sampleBuffer, withType: .video)
            captureOutput(sampleBuffer: sampleBuffer)

            break
        case RPSampleBufferType.audioApp:
            // streamer.appendSampleBuffer(sampleBuffer, withType: .audio)
//            captureAudioOutput(sampleBuffer)

            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }

    func captureOutput(sampleBuffer: CMSampleBuffer) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds

        if _assetWriterInput?.isReadyForMoreMediaData == true {
            let time = CMTime(seconds: timestamp - _time, preferredTimescale: CMTimeScale(600))
            _adpater?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
        }
    }
    
    override func broadcastFinished() {
        guard _assetWriterInput?.isReadyForMoreMediaData == true else {
            // todo log error
            return
        }
        guard  _assetWriter!.status != .failed else {
            // todo log error
            return
        }

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")
        _assetWriterInput?.markAsFinished()
        _assetWriter?.finishWriting {
            [weak self] in
            self?._captureState = .idle
            self?._assetWriter = nil
            self?._assetWriterInput = nil
            // todo notify the app that recording finished
        }
    }


    private var _captureSession: AVCaptureSession?
    private var _videoOutput: AVCaptureVideoDataOutput?
    private var _assetWriter: AVAssetWriter?
    private var _assetWriterInput: AVAssetWriterInput?
    private var _adpater: AVAssetWriterInputPixelBufferAdaptor?
    private var _filename = ""
    private var _time: Double = 0

    private enum _CaptureState {
        case idle, start, capturing, end
    }
    private var _captureState = _CaptureState.idle
    @IBAction func capture(_ sender: Any) {
        switch _captureState {
        case .idle:
            _captureState = .start
        case .capturing:
            _captureState = .end
        default:
            break
        }
    }

    func log(_ s: String) {
    }

}
