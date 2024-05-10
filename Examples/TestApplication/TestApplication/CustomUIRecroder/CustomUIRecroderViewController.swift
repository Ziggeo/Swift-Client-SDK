//
//  ViewController.swift
//  TestApplication
//
//  Created by alex on 18/08/16.
//  Copyright © 2016 Ziggeo Inc. All rights reserved.
//

import UIKit
import ZiggeoMediaSwiftSDK


final class CustomUIRecroderViewController: UIViewController {
    
    @IBOutlet private weak var recordButton: UIBarButtonItem!
    @IBOutlet private weak var stopAndUploadButton: UIBarButtonItem!
    
    let recorder: ZiggeoRecorder
    
    init(recorder: ZiggeoRecorder) {
        self.recorder = recorder
        super.init(nibName: Self.identifier, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopAndUploadButton.isEnabled = false
    }
}

// MARK: - @IBActions
private extension CustomUIRecroderViewController {
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        recorder.dismiss(animated: true)
    }

    @IBAction func recordButtonPressed(_ sender: AnyObject) {
        recorder.startRecording()
        stopAndUploadButton.isEnabled = true
        recordButton.isEnabled = false
    }

    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        recorder.stopRecording()
        stopAndUploadButton.isEnabled = false
        recordButton.isEnabled = true
    }
}
