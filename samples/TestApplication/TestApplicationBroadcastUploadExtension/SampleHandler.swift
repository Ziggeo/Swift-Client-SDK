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

    private var adapter: AVAssetWriterInputPixelBufferAdaptor?

    private var audioWriterInput: AVAssetWriterInput?

    private var videoWriter: AVAssetWriter!

    private var lastSampleTime: CMTime = CMTime()

    private var _time: Double = 0

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        let filename = UUID().uuidString
        videoOutputFullFileName = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(filename).mov")

        isRecordingVideo = true
        
        print("Starting screen capture...")

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

        let inputSize = screenBounds
        let outputSize = screenBounds
        
        var error: NSError?

        do {
            try FileManager.default.removeItem(at: videoOutputFullFileName)
        } catch {}

        do {
            try videoWriter = AVAssetWriter(outputURL: videoOutputFullFileName, fileType: AVFileType.mov)
        } catch let writerError as NSError {
            error = writerError
            videoWriter = nil
        }

        guard let videoWriter = videoWriter else {
            print("Failed to initialize videoWriter")
            return
        }
    

        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)

        guard let videoWriterInput = videoWriterInput else {
            print("Failed to instantiate AVAssetWriterInput")
            return
        }

        let sourceBufferAttributes = [
            (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
            (kCVPixelBufferWidthKey as String): Float(inputSize.width),
            (kCVPixelBufferHeightKey as String): Float(inputSize.height)] as [String : Any]

        adapter = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoWriterInput,
            sourcePixelBufferAttributes: sourceBufferAttributes
        )

        assert(videoWriter.canAdd(videoWriterInput))
        videoWriter.add(videoWriterInput)

        print("videoWriter.startWriting()...")
        
        if !videoWriter.startWriting() {
            print("Failed to start writing")
            return
        }
        
        print("videoWriter.startWriting() SUCCESS")
        videoWriter.startSession(atSourceTime: .zero)
        print("videoWriter.startSession() success")

        _captureState = .capturing

        // _time = timestamp
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
        print("Capturing sample buffer")
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds

        if videoWriterInput?.isReadyForMoreMediaData == true {
            let time = CMTime(seconds: timestamp - _time, preferredTimescale: CMTimeScale(600))
            adapter?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
            print("Capture success")
        }
    }
    
    override func broadcastFinished() {
        print("Finishing capture")
        guard videoWriterInput?.isReadyForMoreMediaData == true else {
            print("Error: videoWriterInput?.isReadyForMoreMediaData == false")
            return
        }
        guard  videoWriter!.status != .failed else {
            print("Error: videoWriter!.status == .failed")
            return
        }

        print("videoWriterInput?.markAsFinished()...")
        videoWriterInput?.markAsFinished()
        print("OK")
        
        print("videoWriter?.finishWriting()...")
        videoWriter?.finishWriting {
            [weak self] in
            self?._captureState = .idle
            self?.videoWriter = nil
            self?.videoWriterInput = nil
            
            print("videoWriter?.finishWriting() DONE!")
            
            // todo notify the app that recording finished
        }
        print("OK")
    }


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
