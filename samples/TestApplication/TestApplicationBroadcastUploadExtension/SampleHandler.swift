//
//  SampleHandler.swift
//  TestApplicationBroadcastUploadExtension
//
//  Created by Admin on 03.09.2020.
//  Copyright © 2020 Ziggeo Inc. All rights reserved.
//

import ReplayKit
import Photos
import ZiggeoSwiftFramework

class SampleHandler: ZiggeoScreenRecorderSampleHandler, ZiggeoVideosDelegate {

    var uploaderTask: URLSessionTask?
    
    override func videoIsReady(fileUrl: URL) {
        print("videoIsReady() is called")
        super.videoIsReady(fileUrl: fileUrl)

        isRecordingVideo = true // this will prevent sample handler from termination while video is uploading

        let ziggeo = Ziggeo(token: "")
        ziggeo.enableDebugLogs = true
        ziggeo.videos.delegate = self
        print("done")

        print("Calling ziggeo.videos.createVideo()...")
        uploaderTask = ziggeo.videos.createVideo(
            [
                "data": "{}"
            ],
            file: fileUrl.path,
            cover: nil,
            callback: {
                _, _, _ in
                print("ziggeo.videos.createVideo: callback fired")
                self.isRecordingVideo = false
            },
            progress: {
                a, b in print("Uploading recorded video: a: \(a), b: \(b)")
            }
        )
        print("Call to ziggeo.videos.createVideo() is finished")
    }


    func videoUploadComplete(_ sourcePath:String, token:String, response:URLResponse?, error:NSError?, json:NSDictionary?) {
        self.isRecordingVideo = true
        print("videoUploadComplete")
    }

}
