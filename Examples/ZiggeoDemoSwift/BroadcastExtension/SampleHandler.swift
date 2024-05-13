//
//  SampleHandler.swift
//  BroadcastExtension
//
//  Created by Dragon on 2/22/23.
//

import ZiggeoMediaSwiftSDK

final class SampleHandler: ZiggeoScreenRecorderSampleHandler {
    override func getApplicationGroup() -> String {
        return "group.com.ziggeo.demo"
    }
}
