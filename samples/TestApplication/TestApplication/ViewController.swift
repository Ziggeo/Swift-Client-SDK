//
//  ViewController.swift
//  TestApplication
//
//  Created by alex on 18/08/16.
//  Copyright © 2016 Ziggeo Inc. All rights reserved.
//

import UIKit
import ZiggeoSwiftFramework
import AVKit
import AVFoundation
import ReplayKit
import MobileCoreServices


class ViewController: UIViewController {
    
    enum CurrentType {
        case Video
        case Audio
        case Image
    }

    let appGroup = "group.Ziggeo.TestApplication.Group"

    let adsUrl = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator="

    var m_ziggeo: Ziggeo {
        return AppDelegate.ziggeo
    }

    var m_recorder: ZiggeoRecorder! = nil
    
    let CLIENT_AUTH_TOKEN = "15901364881299187057"
    var LAST_VIDEO_TOKEN = "4eaea7e4d3792a6d1b8dc4f2caeea319"
    var LAST_AUDIO_TOKEN = "zawimvpc7pbivcfgjjspvxfk34p6icnf"
    var LAST_IMAGE_TOKEN = "xzg4saj6u3ojm47los1kzaztju2cl3on"
    
    var uploaderTask: URLSessionTask! = nil
    var queuePlayer: AVQueuePlayer! = nil
    var playerLayer: AVPlayerLayer! = nil
    var currentType = CurrentType.Video
    

    //custom UI
    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var toggleRecordingButton: UIBarButtonItem!
    @IBOutlet weak var switchCameraButton: UIBarButtonItem!
    @IBOutlet weak var currentStateLabel: UILabel!
    @IBOutlet weak var previewVideoView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.updateStateLabel("")
        self.previewVideoView.isHidden = true
        self.previewImageView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateStateLabel(_ text: String) {
        DispatchQueue.main.async {
            self.currentStateLabel.text = text
        }
    }

    //MARK: Button Click Action
    @IBAction func onVideoRecord(_ sender: AnyObject) {
        currentType = CurrentType.Video
        self.updateStateLabel("")
        
        let recorder = ZiggeoRecorder(application: m_ziggeo)
        recorder.coverSelectorEnabled = true
        recorder.recordedVideoPreviewEnabled = true
        recorder.cameraFlipButtonVisible = true
        recorder.cameraDevice = UIImagePickerController.CameraDevice.front
        recorder.showSoundIndicator = true
        recorder.showLightIndicator = true
        recorder.showFaceOutline = true
        recorder.recorderDelegate = self
        recorder.uploadDelegate = self

        recorder.maxRecordedDurationSeconds = 0 //infinite
        //recorder.extraArgsForCreateVideo = ["data":"{\"foo\":\"bar\"}"] //pass custom data
        //recorder.extraArgsForCreateVideo = ["effect_profile": "EFFECT_ID"]
        //recorder.extraArgsForCreateVideo = ["client_auth":"CLIENT_AUTH_TOKEN"] //recorder-level auth token
        //m_ziggeo.connect.clientAuthToken = "CLIENT_AUTH_TOKEN" //global auth token

        let customizeButtons = false
        if customizeButtons {
            let recorderUIConfig = ZiggeoRecorderInterfaceConfig()
            recorderUIConfig.recordButton.scale = 0.75
            recorderUIConfig.closeButton.scale = 0.5
            recorderUIConfig.cameraFlipButton.scale = 0.5
            if let flipCameraPath = Bundle.main.url(forResource: "FlipCamera", withExtension: "png")?.path {
                recorderUIConfig.cameraFlipButton.imagePath = flipCameraPath
            }
            recorder.recorderUIConfig = recorderUIConfig
        }

        self.present(recorder, animated: true, completion: nil)
    }
    
    @IBAction func onChooseVideo(_ sender: Any) {
        currentType = CurrentType.Video
        self.updateStateLabel("")
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onVideoPlayFullScreen(_ sender: AnyObject) {
        self.updateStateLabel("")
        
        ZiggeoPlayer.createPlayerWithAdditionalParams(application: m_ziggeo, videoToken: LAST_VIDEO_TOKEN, params: ["client_auth": CLIENT_AUTH_TOKEN]) { (player:ZiggeoPlayer?) in
            DispatchQueue.main.async {
                let playerController: AVPlayerViewController = AVPlayerViewController()
                playerController.player = player
                self.present(playerController, animated: true, completion: nil)

                DispatchQueue.main.async {
                    if let player = player {
                        player.play()
                    }
                }
            }
        }
    }

    @IBAction func onVideoPlayEmbedded(_ sender: AnyObject) {
        self.updateStateLabel("")
        self.previewVideoView.isHidden = false
        self.previewImageView.isHidden = true
        
        let playerController: AVPlayerViewController = AVPlayerViewController()
        let player = ZiggeoPlayer(application: m_ziggeo, videoToken: LAST_VIDEO_TOKEN)
        playerController.player = player
        addChild(playerController)
        self.previewVideoView.addSubview(playerController.view)
        playerController.view.frame = CGRect(x:0,y:0,width:self.previewVideoView.frame.width, height:self.previewVideoView.frame.height)
        player.play()
    }
    
    @IBAction func onAudioRecord(_ sender: Any) {
        currentType = CurrentType.Audio
        self.updateStateLabel("")
        
        let audioRecorder = ZiggeoAudioRecorder(ziggeo: m_ziggeo)
        audioRecorder.recorderDelegate = self
        audioRecorder.uploadDelegate = self
        self.present(audioRecorder, animated: true, completion: nil)
    }
    
    @IBAction func onAudioPlay(_ sender: Any) {
        self.updateStateLabel("")
        
        let audioPlayerVC = MusicPlayingController(nibName: "MusicPlayingController", bundle: nil, ziggeo: m_ziggeo, audioToken: LAST_AUDIO_TOKEN)
        self.present(audioPlayerVC, animated: true, completion: nil)
    }
    
    @IBAction func onTakePhoto(_ sender: Any) {
        currentType = CurrentType.Image
        self.updateStateLabel("")
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onChooseImage(_ sender: Any) {
        currentType = CurrentType.Image
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onShowImage(_ sender: Any) {
        self.updateStateLabel("")
        self.previewVideoView.isHidden = true
        self.previewImageView.isHidden = false
        
        self.m_ziggeo.images.downloadImage(LAST_IMAGE_TOKEN) { (filePath) in
            DispatchQueue.main.async {
                guard let url = URL(string: filePath) else {
                    return
                }
                do {
                    let data = try Data(contentsOf: url)
                    self.previewImageView.image = UIImage(data: data)
                } catch {
                }
            }
        }
    }
    
    
    
    @IBAction func index(_ sender: AnyObject) {
        m_ziggeo.videos.getVideos { (array, error) in
        }
    }

    @IBAction func playWithAds(_ sender: AnyObject) {
        let playerController: AVPlayerViewController = AVPlayerViewController()
        let player = ZiggeoPlayer(application: m_ziggeo, videoToken: LAST_VIDEO_TOKEN)
        playerController.player = player
        addChild(playerController)
     self.previewVideoView.addSubview(playerController.view)
        playerController.view.frame = CGRect(x:0,y:0,width:self.previewVideoView.frame.width, height:self.previewVideoView.frame.height)

        player.playWithAds(adTagURL: adsUrl, playerContainer: self.previewVideoView, playerViewController: playerController)
    }

    @IBAction func uploadExisting(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func playSequenceOfVideos(_ sender: Any) {
        ZiggeoPlayer.createPlayerForMultipleVideos(application: m_ziggeo, videoTokens: ["VIDEO_TOKEN_1", "VIDEO_TOKEN_2", "VIDEO_TOKEN_N"], params: nil) { (player) in
            DispatchQueue.main.async {
                self.queuePlayer = player
                self.playerLayer = AVPlayerLayer(player: player)

                self.playerLayer.frame = self.self.previewVideoView.layer.bounds
                self.self.previewVideoView.layer.addSublayer(self.playerLayer)
                player?.play()
            }
        }

    }
    
    @IBAction func recordCustomUI(_ sender: Any) {
        m_recorder = ZiggeoRecorder(application: m_ziggeo)
        m_recorder.coverSelectorEnabled = true
        m_recorder.recordedVideoPreviewEnabled = true
        m_recorder.cameraFlipButtonVisible = true
        m_recorder.cameraDevice = UIImagePickerController.CameraDevice.front
        m_recorder.recorderDelegate = self
        m_recorder.showControls = false
        m_recorder.extraArgsForCreateVideo = ["effect_profile": "EFFECT_ID"]
        Bundle.main.loadNibNamed("CustomRecorderControls", owner: self, options: nil)
        m_recorder.overlayView = self.overlayView
        self.present(m_recorder, animated: true, completion: nil)
    }

    @IBAction func closeButtonCustomUI(_ sender: Any) {
        m_recorder?.dismiss(animated: true, completion: nil)
    }

    @IBAction func toggleRecordingCustomUI(_ sender: Any) {
        m_recorder?.toggleMovieRecording(self)
    }

    @IBAction func switchCameraCustomUI(_ sender: Any) {
        m_recorder?.changeCamera(self)
    }

    @IBAction func didTapRecordScreenButton(_ sender: Any) {
        let rect = CGRect(x: 20, y: 100, width: 50, height: 50)
        m_ziggeo.videos.startScreenRecording(addRecordingButtonToView: view, frame: rect, appGroup: appGroup)
    }
}


//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        if mediaType == kUTTypeImage {
            let imageFile = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            self.m_ziggeo.images.uploadDelegate = self
            self.m_ziggeo.images.uploadImage(imageFile)
            self.dismiss(animated:true, completion: nil)
        } else if mediaType == kUTTypeMovie {
            let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
            let newFilePath = URL(fileURLWithPath: paths[0]).appendingPathComponent("video.mp4").path
            
            do {
                if FileManager.default.fileExists(atPath: newFilePath) {
                    try FileManager.default.removeItem(atPath: newFilePath)
                }
                
                try FileManager.default.copyItem(atPath: videoURL!.path!, toPath: newFilePath)
            
                self.m_ziggeo.videos.uploadDelegate = self
                self.m_ziggeo.videos.uploadVideo(newFilePath)
                self.dismiss(animated:true, completion: nil)
            } catch {
                self.dismiss(animated:true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated:true, completion: nil)
    }
}

//MARK: - ZiggeoRecorderDelegate
extension ViewController: ZiggeoRecorderDelegate {
    public func ziggeoRecorderDidCancel() {
        NSLog("cancellation")
    }

    public func ziggeoRecorderRetake(_ oldFile: URL!) {
        NSLog("file \(oldFile) removed, recording restarted")
    }
    
    public func ziggeoRecorderDidStartRecording() {
        toggleRecordingButton?.title = "stop"
        switchCameraButton?.isEnabled = false
    }

    public func ziggeoRecorderDidFinishRecording() {
        toggleRecordingButton?.title = "record"
        switchCameraButton?.isEnabled = true
    }

    //enable camera control buttons after capture session initialization
    public func ziggeoRecorderCaptureSessionStateChanged(_ runningNow: Bool) {
        toggleRecordingButton?.isEnabled = true
        switchCameraButton?.isEnabled = true
    }

    public func ziggeoRecorderCurrentRecordedDuration(_ seconds: Double) {
        NSLog("recording duration: \(seconds)")
    }

    public func ziggeoRecorderLuxMeter(_ luminousity: Double) {
        //NSLog("luminousity: \(luminousity)")
    }

    public func ziggeoRecorderAudioMeter(_ audioLevel: Double) {
        //NSLog("audio level: \(audioLevel)")
    }

    public func ziggeoRecorderFaceDetected(_ faceID: Int, rect: CGRect) {
        //NSLog("face \(faceID) detected with bounds: \(rect.origin.x):\(rect.origin.y) \(rect.size.width) x \(rect.size.height)")
    }
}

//MARK: - ZiggeoAudioRecorderDelegate
extension ViewController: ZiggeoAudioRecorderDelegate {
    func ziggeoAudioRecorderReady() {
        print ("ziggeoAudioRecorderReady")
    }
    
    func ziggeoAudioRecorderCanceled() {
        print ("ziggeoAudioRecorderCanceled")
    }
    
    func ziggeoAudioRecorderRecoding() {
        print ("ziggeoAudioRecorderRecoding")
    }
    
    func ziggeoAudioRecorderCurrentRecordedDurationSeconds(_ seconds: Double) {
        print ("ziggeoAudioRecorderCurrentRecordedDurationSeconds : \(seconds)")
    }
    
    func ziggeoAudioRecorderFinished(_ seconds: Double) {
        print ("ziggeoAudioRecorderFinished : \(seconds)")
    }
    
    func ziggeoAudioRecorderPlaying() {
        print ("ziggeoAudioRecorderPlaying")
    }
    
    func ziggeoAudioRecorderPaused() {
        print ("ziggeoAudioRecorderPaused")
    }
}

//MARK: - ZiggeoUploadDelegate
extension ViewController: ZiggeoUploadDelegate {
    func preparingToUpload(_ sourcePath: String) {
//        print ("preparingToUpload : \(sourcePath)")
        if (currentType == CurrentType.Video) {
            self.updateStateLabel("Video Upload Started")
        } else if (currentType == CurrentType.Audio) {
            self.updateStateLabel("Audio Upload Started")
        } else if (currentType == CurrentType.Image) {
            self.updateStateLabel("Image Upload Started")
        }
    }

    func preparingToUpload(_ sourcePath: String, token: String, streamToken: String) {
//        print ("preparingToUpload : \(sourcePath) - \(token)")
    }

    func failedToUpload(_ sourcePath: String) {
//        print ("failedToUpload : \(sourcePath)")
    }

    func uploadStarted(_ sourcePath: String, token: String, streamToken: String, backgroundTask: URLSessionTask) {
//        print ("uploadStarted : \(sourcePath) - \(token)")
    }

    func uploadProgress(_ sourcePath: String, token: String, streamToken: String, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
//        print ("uploadProgress : \(totalBytesSent) - \(totalBytesExpectedToSend)")
        if (currentType == CurrentType.Video) {
            self.updateStateLabel("Video Uploading : \(totalBytesSent) / \(totalBytesExpectedToSend)")
        } else if (currentType == CurrentType.Audio) {
            self.updateStateLabel("Audio Uploading : \(totalBytesSent) / \(totalBytesExpectedToSend)")
        } else if (currentType == CurrentType.Image) {
            self.updateStateLabel("Image Uploading : \(totalBytesSent) / \(totalBytesExpectedToSend)")
        }
    }

    func uploadCompleted(_ sourcePath: String, token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
//        print ("uploadCompleted : \(sourcePath) - \(token)")
        if (currentType == CurrentType.Video) {
            LAST_VIDEO_TOKEN = token
            self.updateStateLabel("Video Upload Completed")
        } else if (currentType == CurrentType.Audio) {
            LAST_AUDIO_TOKEN = token
            self.updateStateLabel("Audio Upload Completed")
        } else if (currentType == CurrentType.Image) {
            LAST_IMAGE_TOKEN = token
            self.updateStateLabel("Image Upload Completed")
        }
    }

    func delete(_ token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
//        print ("delete : \(token)")
    }
}
