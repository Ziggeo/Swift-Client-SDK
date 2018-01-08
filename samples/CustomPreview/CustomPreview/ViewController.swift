//
//  ViewController.swift
//  CustomPreview
//
//  Copyright © 2018 ziggeo. All rights reserved.
//

import UIKit
import ZiggeoSwiftFramework

class ViewController: UIViewController {

    var m_ziggeo: Ziggeo! = nil;

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        m_ziggeo = Ziggeo(token: "ZIGGEO_APPLICATION_TOKEN");
        m_ziggeo.enableDebugLogs = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordStandard(_ sender: Any) {
        let recorder = ZiggeoRecorder(application: m_ziggeo);
        recorder.coverSelectorEnabled = true;
        recorder.cameraFlipButtonVisible = true;
        recorder.cameraDevice = UIImagePickerControllerCameraDevice.rear;
        recorder.maxRecordedDurationSeconds = 0; //infinite
        self.present(recorder, animated: true, completion: nil);
    }
    
    @IBAction func recordWithCustomPreview(_ sender: Any) {
        let recorder = ZiggeoRecorder(application: m_ziggeo);
        recorder.coverSelectorEnabled = true;
        recorder.cameraFlipButtonVisible = true;
        recorder.cameraDevice = UIImagePickerControllerCameraDevice.rear;
        recorder.maxRecordedDurationSeconds = 0; //infinite
        let customPreview = CustomPreviewController();
        recorder.videoPreview = customPreview;
        customPreview.previewDelegate = recorder;
        self.present(recorder, animated: true, completion: nil);
    }
    
}

