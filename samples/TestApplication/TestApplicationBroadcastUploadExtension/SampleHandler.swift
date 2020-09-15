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

    let APPLICATION_GROUP_IDENTIFIER = "Ziggeo.TestApplication76876876876535431"


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

        // this doesn't work for app extensions: let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

//        guard let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: APPLICATION_GROUP_IDENTIFIER) else {
//            print("Can not get container url. Check value in the property APPLICATION_GROUP_IDENTIFIER")
//            return
//        }

        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

        videoOutputFullFileName = directory.appendingPathComponent("\(filename).mov")

        print("Video file name: \(videoOutputFullFileName?.absoluteString ?? "NULL")")

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

        isRecordingVideo = true
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
        print("videoWriter.status: \(videoWriter!.status.rawValue)")
        
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
            print("videoWriter?.finishWriting() DONE!")

            var size: Int64 = -1
            if let url = self.videoOutputFullFileName {
                size = self.fileSize(url)
            }
            print("Output file size: \(size)")

            // todo notify the app that recording finished
            self.isRecordingVideo = false
        }
        print("videoWriter.status: \(videoWriter!.status.rawValue)")
        print("OK. finishWriting() is now continue running asynchronously...")


        while videoWriter!.status == .writing && isRecordingVideo {
            Thread.sleep(forTimeInterval: 1)
        }
    }


    func log(_ s: String) {
    }

    func fileSize(_ url: URL) -> Int64 {
        guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path) else {
            return -1
        }

        guard let bytes = fileAttributes[.size] as? Int64 else {
            return -1
        }

        return bytes
    }

}
