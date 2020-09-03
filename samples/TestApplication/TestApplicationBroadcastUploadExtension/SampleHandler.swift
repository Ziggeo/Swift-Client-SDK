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

    var videoOutputFullFileName: String?

    var videoWriterInput: AVAssetWriterInput?

    private var audioWriterInput: AVAssetWriterInput?

    private var videoWriter: AVAssetWriter?

    private var lastSampleTime: CMTime = CMTime()

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        let fileManager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let random = Int.random(in: 0 ..< Int.max)
        let videoFileName = "\(random).mp4"
        self.videoOutputFullFileName = URL(fileURLWithPath: documentsPath).appendingPathComponent(videoFileName).absoluteString

        guard self.videoOutputFullFileName != nil else {
            print("ERROR: The video output file name is nil")
            return
        }

        isRecordingVideo = true

        if fileManager.fileExists(atPath: self.videoOutputFullFileName!) {
            print("WARN:::The file: \(self.videoOutputFullFileName!) exists, will delete the existing file")

            do {
                try fileManager.removeItem(atPath: self.videoOutputFullFileName!)
            } catch let error as NSError {
                print("WARN:::Cannot delete existing file: \(self.videoOutputFullFileName!), error: \(error.debugDescription)")
            }

        } else {
            print("DEBUG:::The file \(self.videoOutputFullFileName!) doesn't exist")
        }

        let screen = UIScreen.main
        let screenBounds = screen.bounds
        let videoCompressionProperties = [
            AVVideoAverageBitRateKey: screenBounds.width * screenBounds.height * 10.1
        ]

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: screenBounds.width,
            AVVideoHeightKey: screenBounds.height,
            AVVideoCompressionPropertiesKey: videoCompressionProperties
        ]

        self.videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)

        guard let videoWriterInput = self.videoWriterInput else {
            print("ERROR:::No video writer input")
            return
        }

        videoWriterInput.expectsMediaDataInRealTime = true

        // Add the audio input
        var acl = AudioChannelLayout()
        memset(&acl, 0, MemoryLayout<AudioChannelLayout>.size)
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        let audioOutputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 64000,
            AVChannelLayoutKey: Data(bytes: &acl, count: MemoryLayout<AudioChannelLayout>.size)
        ]

        audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioOutputSettings)

        guard let audioWriterInput = self.audioWriterInput else {
            print("ERROR:::No audio writer input")
            return
        }

        audioWriterInput.expectsMediaDataInRealTime = true

        do {
            self.videoWriter = try AVAssetWriter(outputURL: URL(fileURLWithPath: self.videoOutputFullFileName!), fileType: AVFileType.mp4)
        } catch let error as NSError {
            print("ERROR:::::>>>>>>>>>>>>>Cannot init videoWriter, error:\(error.localizedDescription)")
        }

        guard let videoWriter = self.videoWriter else {
            print("ERROR:::No video writer")
            return
        }

        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        } else {
            print("ERROR:::Cannot add videoWriterInput into videoWriter")
        }

        //Add audio input
        if videoWriter.canAdd(audioWriterInput) {
            videoWriter.add(audioWriterInput)
        } else {
            print("ERROR:::Cannot add audioWriterInput into videoWriter")
        }

        if videoWriter.status != .writing {
            print("DEBUG::::::::::::::::The videoWriter status is not writing, and will start writing the video.")

            let hasStartedWriting = videoWriter.startWriting()
            if hasStartedWriting {
                videoWriter.startSession(atSourceTime: self.lastSampleTime)
                print("DEBUG:::Have started writing on videoWriter, session at source time: \(self.lastSampleTime)")
                log("VideoWriter status: \(videoWriter.status.rawValue)")
            } else {
                print("WARN:::Fail to start writing on videoWriter")
            }
        } else {
            print("WARN:::The videoWriter.status is writing now, so cannot start writing action on videoWriter")
        }
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
        self.lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);

        // Append the sampleBuffer into videoWriterInput
        if self.isRecordingVideo {
            if self.videoWriterInput!.isReadyForMoreMediaData {
                if self.videoWriter!.status == .writing {
                    let whetherAppendSampleBuffer = self.videoWriterInput!.append(sampleBuffer)
                    print(">>>>>>>>>>>>>The time::: \(self.lastSampleTime.value)/\(self.lastSampleTime.timescale)")
                    if whetherAppendSampleBuffer {
                        print("DEBUG::: Append sample buffer successfully")
                    } else {
                        print("WARN::: Append sample buffer failed")
                    }
                } else {
                    print("WARN:::The videoWriter status is not writing")
                }
            } else {
                print("WARN:::Cannot append sample buffer into videoWriterInput")
            }
        }
    }
    
    override func broadcastFinished() {
        print("DEBUG::: Starting to process recorder final...")
        print("DEBUG::: videoWriter status: \(self.videoWriter!.status.rawValue)")
        self.isRecordingVideo = false

        guard let videoWriterInput = self.videoWriterInput else {
            print("ERROR:::No video writer input")
            return
        }
        guard let videoWriter = self.videoWriter else {
            print("ERROR:::No video writer")
            return
        }

        guard let audioWriterInput = self.audioWriterInput else {
            print("ERROR:::No audio writer input")
            return
        }

        videoWriterInput.markAsFinished()
        audioWriterInput.markAsFinished()
        videoWriter.finishWriting {
            if videoWriter.status == .completed {
                print("DEBUG:::The videoWriter status is completed")

                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: self.videoOutputFullFileName!) {
                    print("DEBUG:::The file: \(self.videoOutputFullFileName ?? "") has been saved in documents folder, and is ready to be moved to camera roll")

                    let sharedFileURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "com.ziggeo.TestApplication")
                    guard let documentsPath = sharedFileURL?.path else {
                        self.log("ERROR:::No shared file URL path")
                        return
                    }

                    let finalFilename = URL(fileURLWithPath: documentsPath).appendingPathComponent("test_capture_video.mp4").absoluteString

                    //Check whether file exists
                    if fileManager.fileExists(atPath: finalFilename) {
                        print("WARN:::The file: \(finalFilename) exists, will delete the existing file")
                        do {
                            try fileManager.removeItem(atPath: finalFilename)
                        } catch let error as NSError {
                            print("WARN:::Cannot delete existing file: \(finalFilename), error: \(error.debugDescription)")
                        }
                    } else {
                        print("DEBUG:::The file \(self.videoOutputFullFileName!) doesn't exist")
                    }

                    do {
                        try fileManager.copyItem(at: URL(fileURLWithPath: self.videoOutputFullFileName!), to: URL(fileURLWithPath: finalFilename))
                    }
                    catch let error as NSError {
                        self.log("ERROR:::\(error.debugDescription)")
                    }

                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: finalFilename))
                    }) {
                        completed, error in
                        if completed {
                            print("Video \(self.videoOutputFullFileName ?? "") has been moved to camera roll")
                        }

                        if error != nil {
                            print ("ERROR:::Cannot move the video \(self.videoOutputFullFileName ?? "") to camera roll, error: \(error!.localizedDescription)")
                        }
                    }

                } else {
                    print("ERROR:::The file: \(self.videoOutputFullFileName ?? "") doesn't exist, so can't move this file camera roll")
                }
            } else {
                print("WARN:::The videoWriter status is not completed, status: \(videoWriter.status)")
            }
        }
    }

    func log(_ s: String) {
    }

}
