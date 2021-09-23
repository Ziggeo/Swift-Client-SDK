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
        
        m_ziggeo.config.delegate = self
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
                var url: URL?
                if filePath.contains("http://") || filePath.contains("https://") {
                    url = URL(string: filePath)
                } else {
                    url = URL(fileURLWithPath: filePath)
                }
                if url == nil {
                    return
                }
                do {
                    let data = try Data(contentsOf: url!)
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
    func ziggeoRecorderLuxMeter(_ luminousity: Double) {
        //print ("luminousity: \(luminousity)")
    }

    func ziggeoRecorderAudioMeter(_ audioLevel: Double) {
        //print ("audio level: \(audioLevel)")
    }

    func ziggeoRecorderFaceDetected(_ faceID: Int, rect: CGRect) {
        //print ("face \(faceID) detected with bounds: \(rect.origin.x):\(rect.origin.y) \(rect.size.width) x \(rect.size.height)")
    }
    
    func ziggeoRecorderReady() {
        print ("Ziggeo Recorder Ready")
    }
    
    func ziggeoRecorderCanceled() {
        print ("Ziggeo Recorder Canceled")
    }
    
    func ziggeoRecorderStarted() {
        print ("Ziggeo Recorder Started")
        toggleRecordingButton?.title = "stop"
        switchCameraButton?.isEnabled = false
    }
    
    func ziggeoRecorderStopped(_ path: String) {
        print ("Ziggeo Recorder Stopped")
        toggleRecordingButton?.title = "record"
        switchCameraButton?.isEnabled = true
    }
    
    func ziggeoRecorderCurrentRecordedDurationSeconds(_ seconds: Double) {
        print ("Ziggeo Recorder Recording Duration: \(seconds)")
    }
    
    func ziggeoRecorderPlaying() {
        print ("Ziggeo Recorder Playing")
    }
    
    func ziggeoRecorderPaused() {
        print ("Ziggeo Recorder Paused")
    }
    
    func ziggeoRecorderRerecord() {
        print ("Ziggeo Recorder Rerecord")
    }
    
    func ziggeoRecorderManuallySubmitted() {
        print ("Ziggeo Recorder Manually Submitted")
    }
    
    
    func ziggeoStreamingStarted() {
        print ("Ziggeo Streaming Started")
    }
    
    func ziggeoStreamingStopped() {
        print ("Ziggeo Streaming Stopped")
    }
}


//MARK: - ZiggeoUploadDelegate

extension ViewController: ZiggeoUploadDelegate {
    func preparingToUpload(_ path: String) {
        print ("Preparing To Upload : \(path)")
        if (currentType == CurrentType.Video) {
            self.updateStateLabel("Video Upload Started")
        } else if (currentType == CurrentType.Audio) {
            self.updateStateLabel("Audio Upload Started")
        } else if (currentType == CurrentType.Image) {
            self.updateStateLabel("Image Upload Started")
        }
    }

    func failedToUpload(_ path: String) {
        print ("Failed To Upload : \(path)")
    }

    func uploadStarted(_ path: String, token: String, streamToken: String, backgroundTask: URLSessionTask) {
        print ("Upload Started : \(token) - \(streamToken)")
    }

    func uploadProgress(_ path: String, token: String, streamToken: String, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print ("Upload Progress : \(totalBytesSent) - \(totalBytesExpectedToSend)")
        if (currentType == CurrentType.Video) {
            self.updateStateLabel("Video Uploading : \(totalBytesSent) / \(totalBytesExpectedToSend)")
        } else if (currentType == CurrentType.Audio) {
            self.updateStateLabel("Audio Uploading : \(totalBytesSent) / \(totalBytesExpectedToSend)")
        } else if (currentType == CurrentType.Image) {
            self.updateStateLabel("Image Uploading : \(totalBytesSent) / \(totalBytesExpectedToSend)")
        }
    }
    
    func uploadFinished(_ path:String, token: String, streamToken: String) {
        
    }
    
    func uploadVerified(_ path:String, token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
        print ("Upload Verified : \(token) - \(streamToken)")
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
    
    func uploadProcessing(_ path: String, token: String, streamToken: String) {
        print ("Upload Processing : \(token) - \(streamToken)")
    }
    
    func uploadProcessed(_ path: String, token: String, streamToken: String) {
        print ("Upload Processed : \(token) - \(streamToken)")
    }

    func delete(_ token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
        print ("delete : \(token) - \(streamToken)")
    }
}


//MARK: - ZiggeoHardwarePermissionCheckDelegate

extension ViewController: ZiggeoHardwarePermissionCheckDelegate {
    func checkCameraPermission(_ granted: Bool) {
        print ("CheckCameraPermission : \(granted)")
    }
    
    func checkMicrophonePermission(_ granted: Bool) {
        print ("CheckMicrophonePermission : \(granted)")
    }
    
    func checkPhotoLibraryPermission(_ granted: Bool) {
        print ("CheckPhotoLibraryPermission : \(granted)")
    }
    
    func checkHasCamera(_ hasCamera: Bool) {
        print ("CheckHasCamera : \(hasCamera)")
    }
    
    func checkHasMicrophone(_ hasMicrophone: Bool) {
        print ("CheckHasMicrophone : \(hasMicrophone)")
    }
}


//MARK: - ZiggeoPlayerDelegate

extension ViewController: ZiggeoPlayerDelegate {
    func ziggeoPlayerPlaying() {
        print ("ziggeo Player Playing")
    }
    
    func ziggeoPlayerPaused() {
        print ("ziggeo Player Paused")
    }
    
    func ziggeoPlayerEnded() {
        print ("ziggeo Player Ended")
    }
    
    func ziggeoPlayerSeek(_ positionMillis: Double) {
        print ("ziggeo Player Seek : \(positionMillis)")
    }
    
    func ziggeoPlayerReadyToPlay() {
        print ("Ziggeo Player Ready To Play")
    }
}
