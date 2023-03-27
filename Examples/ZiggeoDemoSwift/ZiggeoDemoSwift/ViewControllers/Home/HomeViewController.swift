//
//  HomeViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import ActiveLabel
import SideMenu
import ZiggeoMediaSwiftSDK
import AVKit
import AVFoundation
import MobileCoreServices

class HomeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var popupMenuButton: UIView!
    @IBOutlet weak var popupMenuImageView: UIImageView!
    @IBOutlet weak var popupMenuView: UIStackView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var playAllButtonView: UIView!
    
    // MARK: - Private variables
    private var isShowPopupMenu = false
    private var sideMenuVc: SideMenuNavigationController?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let vc = Common.getStoryboardViewController("SideMenuViewController") as? SideMenuViewController {
            vc.delegate = self
            
            sideMenuVc = SideMenuNavigationController(rootViewController: vc)
            SideMenuManager.default.leftMenuNavigationController = sideMenuVc
            sideMenuVc?.settings = makeSettings()
            SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
//            SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
            sideMenuVc?.statusBarEndAlpha = 0
        }
        refreshPopupMenu()
        
        Common.mainNavigationController = self.navigationController
        Common.homeViewController = self
        
        Common.ziggeo?.hardwarePermissionDelegate = self
        Common.ziggeo?.uploadingDelegate = self
        Common.ziggeo?.fileSelectorDelegate = self
        Common.ziggeo?.recorderDelegate = self
        Common.ziggeo?.sensorDelegate = self
        Common.ziggeo?.playerDelegate = self
        Common.ziggeo?.screenRecorderDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Actions
    @IBAction func onShowMenu(_ sender: Any) {
        if (sideMenuVc != nil) {
            present(sideMenuVc!, animated: true, completion: nil)
        }
    }
    
    @IBAction func onPopupMenu(_ sender: Any) {
        isShowPopupMenu = !isShowPopupMenu
        refreshPopupMenu()
    }
    
    @IBAction func onPicker(_ sender: Any) {
        var config: [String: Any] = [:]
        config["tags"] = "iOS_Choose_Media"
        Common.ziggeo?.setUploadingConfig(config)
        
        var data: [String: Any] = [:]
        // data[ARG_MEDIA_TYPE] = ["video", "image"]
        // data[ARG_DURATION] = "20"
        Common.ziggeo?.uploadFromFileSelector(data)
        
        self.hideMenu()
    }
    
    @IBAction func onCameraImage(_ sender: Any) {
        var config: [String: Any] = [:]
        config["tags"] = "iOS_Take_Photo"
        Common.ziggeo?.setUploadingConfig(config)
        
        Common.ziggeo?.startImageRecorder()
        
        self.hideMenu()
    }
    
    @IBAction func onVocieRecord(_ sender: Any) {
        var config: [String: Any] = [:]
        config["tags"] = "iOS_Audio_Record"
        Common.ziggeo?.setExtraArgsForRecorder(config)
        
        Common.ziggeo?.startAudioRecorder()
        
        self.hideMenu()
    }
    
    
    @available(iOS 12.0, *)
    @IBAction func onScreenRecord(_ sender: Any) {
        Common.ziggeo?.startScreenRecorder(appGroup: "group.com.ziggeo.demo",
                                           preferredExtension: "com.ziggeo.demo.BroadcastExtension")
        
        self.hideMenu()
    }
    
    @IBAction func onVideoRecord(_ sender: Any) {
        if (UserDefaults.standard.bool(forKey: Common.Custom_Camera_Key) == true) {
            let vc = CustomVideoRecorder()
            self.present(vc, animated: true, completion: nil)
            
        } else {
            let startDelayString = UserDefaults.standard.string(forKey: Common.Start_Delay_Key)
            if (startDelayString != nil && startDelayString != "") {
                let startDelay = Int(startDelayString!) ?? 0
                Common.ziggeo?.setStartDelay(startDelay)
            }

            var config: [String: Any] = [:]
            config["effect_profile"] = "12345"
            config["data"] = ["source":"app"]
            config["tags"] = "iOS_Video_Record"
            config["expiration_days"] = 1
            Common.ziggeo?.setExtraArgsForRecorder(config)
            
            Common.ziggeo?.setCamera(REAR_CAMERA)
//            Common.ziggeo?.setMaxRecordingDuration(30)
            
            Common.ziggeo?.record()
        }
        
        self.hideMenu()
    }
    
    @IBAction func onPlayAll(_ sender: Any) {
        if (Common.currentTab == Media_Type.Video) {
            var tokens: [String] = []
            if (Common.recordingVideosController != nil) {
                for recording in Common.recordingVideosController!.recordings {
                    tokens.append(recording.token)
                }
            }
                       
            if (tokens.count > 0) {
                Common.ziggeo?.playVideo(tokens)
            } else {
                Common.showAlertView("Video recordings are empty.")
            }
            
        } else if (Common.currentTab == Media_Type.Audio) {
            var tokens: [String] = []
            if (Common.recordingAudiosController != nil) {
                for recording in Common.recordingAudiosController!.recordings {
                    tokens.append(recording.token)
                }
            }
            
            if (tokens.count > 0) {
                Common.ziggeo?.startAudioPlayer(tokens)
            } else {
                Common.showAlertView("Audio recordings are empty.")
            }
            
        } else {
            var tokens: [String] = []
            if (Common.recordingImagesController != nil) {
                for recording in Common.recordingImagesController!.recordings {
                    tokens.append(recording.token)
                }
            }
            
            if (tokens.count > 0) {
                Common.ziggeo?.showImage(tokens)
            } else {
                Common.showAlertView("Image recordings are empty.")
            }
        }
    }
    
    // MARK: - Private functions
    private func refreshPopupMenu() {
        if (isShowPopupMenu) {
            popupMenuView.isHidden = false
            popupMenuImageView.image = UIImage(named: "ic_close")
        } else {
            popupMenuView.isHidden = true
            popupMenuImageView.image = UIImage(named: "ic_plus")
        }
    }
    
    private func hideMenu() {
        isShowPopupMenu = false
        self.refreshPopupMenu()
    }
    
    private func makeSettings() -> SideMenuSettings {
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn
        presentationStyle.backgroundColor = UIColor.black
        presentationStyle.menuStartAlpha = 0.2
        presentationStyle.menuScaleFactor = 1
        presentationStyle.onTopShadowOpacity = 1
        presentationStyle.presentingEndAlpha = 1
        presentationStyle.presentingScaleFactor = 1

        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.menuWidth = min(view.frame.width, view.frame.height) * 0.8
        settings.blurEffectStyle = UIBlurEffect.Style.dark
        settings.statusBarEndAlpha = 1

        return settings
    }
}

// MARK: -
extension HomeViewController: MenuActionDelegate {
    func didSelectLogoutMenu() {
        if let vc = Common.getStoryboardViewController("AuthViewController") as? AuthViewController {
            self.navigationController?.setViewControllers([vc], animated: true)
        }
    }
    
    func didSelectRecordingMenu() {
        self.titleLabel.text = "Recordings"
        popupMenuButton.isHidden = false
        isShowPopupMenu = false
        refreshPopupMenu()
        
        if let vc = Common.getStoryboardViewController("RecordingsViewController") as? RecordingsViewController {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectVideoEditorMenu() {
        self.titleLabel.text = "Video Editor"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController("VideoEditorViewController") as? VideoEditorViewController {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectSettingsMenu() {
        self.titleLabel.text = "Settings"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController("SettingsViewController") as? SettingsViewController {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectAvailableSdksMenu() {
        self.titleLabel.text = "Available SDKs"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController("AvailableSdksViewController") as? AvailableSdksViewController {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectTopClientsMenu() {
        self.titleLabel.text = "Top Clients"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController("TopClientsViewController") as? TopClientsViewController {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectContactUsMenu() {
        self.titleLabel.text = "Contact Us"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController("ContactUsViewController") as? ContactUsViewController {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectAboutMenu() {
        self.titleLabel.text = "About"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController("AboutViewController") as? AboutViewController {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectLogMenu() {
        self.titleLabel.text = "Logs"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController("LogViewController") as? LogViewController {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectPlayVideoFromUrlMenu() {
        Common.ziggeo?.playFromUri(["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"])
    }
    
    func didSelectPlayLocalVideoMenu() {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.mediaTypes = [kUTTypeMovie as String]
        present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: false) {
            let videoUrl = (info[.mediaURL] as! URL).path
            Common.ziggeo?.playFromUri([videoUrl])
        }
    }
}

// MARK: - ZiggeoHardwarePermissionDelegate
extension HomeViewController: ZiggeoHardwarePermissionDelegate {
    func checkCameraPermission(_ granted: Bool) {
    }
    
    func checkMicrophonePermission(_ granted: Bool) {
    }
    
    func checkPhotoLibraryPermission(_ granted: Bool) {
    }
    
    func checkHasCamera(_ hasCamera: Bool) {
    }
    
    func checkHasMicrophone(_ hasMicrophone: Bool) {
    }
}

// MARK: - ZiggeoUploadingDelegate
extension HomeViewController: ZiggeoUploadingDelegate {
    func preparingToUpload(_ path: String) {
        Common.addLog("Preparing To Upload: \(path)")
    }

    func failedToUpload(_ path: String) {
        Common.addLog("Failed To Upload: \(path)")
    }

    func uploadStarted(_ path: String, token: String, streamToken: String, backgroundTask: URLSessionTask) {
        Common.addLog("Upload Started: \(token) - \(streamToken)")
    }

    func uploadProgress(_ path: String, token: String, streamToken: String, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        Common.addLog("Upload Progress: \(totalBytesSent) - \(totalBytesExpectedToSend)")
    }
    
    func uploadFinished(_ path:String, token: String, streamToken: String) {
        Common.addLog("Upload Finished: \(token) - \(streamToken)")
        
        Common.recordingVideosController?.getRecordings()
        Common.recordingAudiosController?.getRecordings()
        Common.recordingImagesController?.getRecordings()
    }
    
    func uploadVerified(_ path:String, token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
        Common.addLog("Upload Verified: \(token) - \(streamToken)")
    }
    
    func uploadProcessing(_ path: String, token: String, streamToken: String) {
        Common.addLog("Upload Processing: \(token) - \(streamToken)")
    }
    
    func uploadProcessed(_ path: String, token: String, streamToken: String) {
        Common.addLog("Upload Processed: \(token) - \(streamToken)")
    }

    func delete(_ token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
        Common.addLog("delete: \(token) - \(streamToken)")
    }
    
    func cancelUpload(_ path: String, deleteFile: Bool) {
    }
    
    func cancelCurrentUpload(_ deleteFile: Bool) {
    }
}

// MARK: - ZiggeoFileSelectorDelegate
extension HomeViewController: ZiggeoFileSelectorDelegate {
    func uploadSelected(_ paths: [String]) {
        Common.addLog("Upload Selected: \(paths)")
    }
    
    func uploadCancelledByUser() {
        Common.addLog("Upload cancelled by User")
    }
}

// MARK: - ZiggeoRecorderDelegate
extension HomeViewController: ZiggeoRecorderDelegate {
    func recorderReady() {
        Common.addLog("Recorder Ready")
    }
    
    func recorderCancelledByUser() {
        Common.addLog("Recorder Canceled")
    }
    
    func recorderCountdown(_ secondsLeft: Int) {
        Common.addLog("Recorder Countdown left: \(secondsLeft)")
    }
    
    func recorderStarted() {
        Common.addLog("Recorder Started")
    }
    
    func recorderStopped(_ path: String) {
        Common.addLog("Recorder Stopped")
    }
    
    func recorderCurrentRecordedDurationSeconds(_ seconds: Double) {
        Common.addLog("Recorder Recording Duration: \(seconds)")
    }
    
    func recorderPlaying() {
        Common.addLog("Recorder Playing")
    }
    
    func recorderPaused() {
        Common.addLog("Recorder Paused")
    }
    
    func recorderRerecord() {
        Common.addLog("Recorder Rerecord")
    }
    
    func recorderManuallySubmitted() {
        Common.addLog("Recorder Manually Submitted")
    }
    
    func streamingStarted() {
        Common.addLog("Streaming Started")
    }
    
    func streamingStopped() {
        Common.addLog("Streaming Stopped")
    }
}

// MARK: - ZiggeoSensorDelegate
extension HomeViewController: ZiggeoSensorDelegate {
    func luxMeter(_ luminousity: Double) {
    }

    func audioMeter(_ audioLevel: Double) {
    }

    func faceDetected(_ faceID: Int, rect: CGRect) {
    }
}

// MARK: - ZiggeoPlayerDelegate
extension HomeViewController: ZiggeoPlayerDelegate {
    func playerPlaying() {
        Common.addLog("Player Playing")
    }
    
    func playerPaused() {
        Common.addLog("Player Paused")
    }
    
    func playerEnded() {
        Common.addLog("Player Ended")
    }
    
    func playerSeek(_ positionMillis: Double) {
        Common.addLog("Player Seek: \(positionMillis)")
    }
    
    func playerReadyToPlay() {
        Common.addLog("Player Ready To Play")
    }
    
    func playerCancelledByUser() {
        Common.addLog("Player Cancelled By User")
    }
}

// MARK: - ZiggeoScreenRecorderDelegate
extension HomeViewController: ZiggeoScreenRecorderDelegate {
}
