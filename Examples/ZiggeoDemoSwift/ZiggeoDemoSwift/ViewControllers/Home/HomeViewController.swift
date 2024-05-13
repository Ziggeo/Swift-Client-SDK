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

final class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var popupMenuButton: UIView!
    @IBOutlet private weak var popupMenuImageView: UIImageView!
    @IBOutlet private weak var popupMenuView: UIStackView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var playAllButtonView: UIView!
    
    // MARK: - Private variables
    private var isShowPopupMenu = false
    private var sideMenuVc: SideMenuNavigationController?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let vc = Common.getStoryboardViewController(type: SideMenuViewController.self) {
            vc.delegate = self
            
            sideMenuVc = SideMenuNavigationController(rootViewController: vc)
            SideMenuManager.default.leftMenuNavigationController = sideMenuVc
            sideMenuVc?.settings = makeSettings()
            SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
            // SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
            sideMenuVc?.statusBarEndAlpha = 0
        }
        refreshPopupMenu()
        
        Common.mainNavigationController = navigationController
        Common.homeViewController = self
        
        Common.ziggeo?.hardwarePermissionDelegate = self
        Common.ziggeo?.uploadingDelegate = self
        Common.ziggeo?.fileSelectorDelegate = self
        Common.ziggeo?.recorderDelegate = self
        Common.ziggeo?.sensorDelegate = self
        Common.ziggeo?.playerDelegate = self
        Common.ziggeo?.screenRecorderDelegate = self
    }
}

// MARK: - @IBActions
private extension HomeViewController {
    @IBAction func onShowMenu(_ sender: Any) {
        sideMenuVc.flatMap { present($0, animated: true) }
    }
    
    @IBAction func onPopupMenu(_ sender: Any) {
        isShowPopupMenu.toggle()
        refreshPopupMenu()
    }
    
    @IBAction func onPicker(_ sender: Any) {
        let fileSelectorConfig = FileSelectorConfig()
        fileSelectorConfig.maxDuration = 0
        fileSelectorConfig.minDuration = 0
        fileSelectorConfig.shouldAllowMultipleSelection = true
        fileSelectorConfig.mediaType = VIDEO | AUDIO | IMAGE
        fileSelectorConfig.extraArgs = ["tags" : "iOS,Choose,Media"]
        Common.ziggeo?.setFileSelectorConfig(fileSelectorConfig)
        
        Common.ziggeo?.startFileSelector()
        
        hideMenu()
    }
    
    @IBAction func onCameraImage(_ sender: Any) {
        let uploadingConfig = UploadingConfig()
        uploadingConfig.extraArgs = ["tags": "iOS,Take,Photo"]
        Common.ziggeo?.setUploadingConfig(uploadingConfig)
        
        Common.ziggeo?.startImageRecorder()
        
        hideMenu()
    }
    
    @IBAction func onVocieRecord(_ sender: Any) {
        let recorderConfig = RecorderConfig()
        recorderConfig.isPausedMode = true
        recorderConfig.extraArgs = ["tags": "iOS,Audio,Record"]
        Common.ziggeo?.setRecorderConfig(recorderConfig)
        
        Common.ziggeo?.startAudioRecorder()
        
        hideMenu()
    }
    
    @IBAction func onScreenRecord(_ sender: Any) {
        Common.ziggeo?.startScreenRecorder(appGroup: "group.com.ziggeo.demo",
                                           preferredExtension: "com.ziggeo.demo.BroadcastExtension")
        hideMenu()
    }
    
    @IBAction func onVideoRecord(_ sender: Any) {
        defer { hideMenu() }
        
        if UserDefaults.isUsingCustomCamera {
            return present(CustomVideoRecorder(), animated: true)
        }
        
        let recorderConfig = RecorderConfig()
        recorderConfig.shouldAutoStartRecording = true
        
        if let startDelayString = UserDefaults.startDelay,
           !startDelayString.isEmpty {
            recorderConfig.startDelay = Int(startDelayString) ?? 0
        }
        recorderConfig.shouldDisableCameraSwitch = false
        recorderConfig.videoQuality = QUALITY_HIGH
        recorderConfig.facing = FACING_BACK
        recorderConfig.maxDuration = 0
        recorderConfig.extraArgs = ["tags": "iOS,Video,Record",
                                    "client_auth" : "CLIENT_AUTH_TOKEN",
                                    "server_auth" : "SERVER_AUTH_TOKEN",
                                    "data" : ["foo": "bar"],
                                    "effect_profile" : "1234,5678"]
        Common.ziggeo?.setRecorderConfig(recorderConfig)
        
        Common.ziggeo?.record()
    }
    
    @IBAction func onPlayAll(_ sender: Any) {
        if Common.currentTab == VIDEO {
            let tokens = (Common.recordingVideosController?.recordings ?? []).compactMap { $0.token }
            
            tokens.isEmpty ?
            Common.showAlertView("Video recordings are empty.") :
            Common.ziggeo?.playVideos(tokens)
            
        } else if Common.currentTab == AUDIO {
            let tokens = (Common.recordingAudiosController?.recordings ?? []).compactMap { $0.token }
            
            tokens.isEmpty ?
            Common.showAlertView("Audio recordings are empty.") :
            Common.ziggeo?.playAudios(tokens)
            
        } else {
            let tokens = (Common.recordingImagesController?.recordings ?? []).compactMap { $0.token }
            
            tokens.isEmpty ?
            Common.showAlertView("Image recordings are empty.") :
            Common.ziggeo?.showImages(tokens)
        }
    }
}

// MARK: - Privates
private extension HomeViewController {
    func refreshPopupMenu() {
        popupMenuView.isHidden = isShowPopupMenu
        popupMenuImageView.image = isShowPopupMenu ? .plusIcon : .closeIcon
    }
    
    func hideMenu() {
        isShowPopupMenu = false
        refreshPopupMenu()
    }
    
    func makeSettings() -> SideMenuSettings {
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn
        presentationStyle.backgroundColor = .black
        presentationStyle.menuStartAlpha = 0.2
        presentationStyle.menuScaleFactor = 1
        presentationStyle.onTopShadowOpacity = 1
        presentationStyle.presentingEndAlpha = 1
        presentationStyle.presentingScaleFactor = 1

        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.menuWidth = min(view.frame.width, view.frame.height) * 0.8
        settings.blurEffectStyle = .dark
        settings.statusBarEndAlpha = 1

        return settings
    }
}

// MARK: - MenuActionDelegate
extension HomeViewController: MenuActionDelegate {
    func didSelectLogoutMenu() {
        if let vc = Common.getStoryboardViewController(type: AuthViewController.self) {
            navigationController?.setViewControllers([vc], animated: true)
        }
    }
    
    func didSelectRecordingMenu() {
        titleLabel.text = "Recordings"
        popupMenuButton.isHidden = false
        isShowPopupMenu = false
        refreshPopupMenu()
        
        if let vc = Common.getStoryboardViewController(type: RecordingsViewController.self) {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectVideoEditorMenu() {
        titleLabel.text = "Video Editor"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController(type: VideoEditorViewController.self) {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectSettingsMenu() {
        titleLabel.text = "Settings"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController(type: SettingsViewController.self) {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectAvailableSdksMenu() {
        titleLabel.text = "Available SDKs"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController(type: AvailableSdksViewController.self) {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectTopClientsMenu() {
        titleLabel.text = "Top Clients"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController(type: TopClientsViewController.self) {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectContactUsMenu() {
        titleLabel.text = "Contact Us"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController(type: ContactUsViewController.self) {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectAboutMenu() {
        titleLabel.text = "About"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController(type: AboutViewController.self) {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectLogMenu() {
        titleLabel.text = "Logs"
        popupMenuButton.isHidden = true
        popupMenuView.isHidden = true
        
        if let vc = Common.getStoryboardViewController(type: LogViewController.self) {
            Common.subNavigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    func didSelectPlayVideoFromUrlMenu() {
        Common.ziggeo?.playFromUris(["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                                     "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
                                     "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"])
    }
    
    func didSelectPlayLocalVideoMenu() {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.mediaTypes = [UTType.movie.identifier]
        present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: false) {
            let videoUrl = (info[.mediaURL] as! URL).path
            Common.ziggeo?.playFromUri(videoUrl)
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

    func error(_ info: RecordingInfo?, _ error: Error, _ lostConnectionAction: Int) {
        Common.addLog("Failed To Upload : \(info?.getToken() ?? "")")
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
    
    func recorderCancelledByUser() {
        Common.addLog("Recorder Cancelled By User")
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
