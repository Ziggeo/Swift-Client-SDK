//
//  ViewController.swift
//  TestApplication
//
//  Created by alex on 18/08/16.
//  Copyright © 2016 Ziggeo Inc. All rights reserved.
//

import UIKit
import ZiggeoMediaSwiftSDK


class CustomUIRecroderViewController: UIViewController {

    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var stopAndUploadButton: UIBarButtonItem!
    
    var m_recorder: ZiggeoRecorder?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.stopAndUploadButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: Button Click Action
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        if (self.m_recorder != nil) {
            self.m_recorder!.dismiss(animated:true, completion: nil)
        }
        self.m_recorder = nil
    }

    @IBAction func recordButtonPressed(_ sender: AnyObject) {
        if (self.m_recorder != nil) {
            self.m_recorder!.startRecording()
        }
        self.stopAndUploadButton.isEnabled = true
        self.recordButton.isEnabled = false
    }

    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        if (self.m_recorder != nil) {
            self.m_recorder!.stopRecording()
        }
        self.stopAndUploadButton.isEnabled = false
        self.recordButton.isEnabled = true
    }
}
