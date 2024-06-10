//
//  RecordingDetailViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import AVKit
import ZiggeoMediaSwiftSDK
import SVProgressHUD

@objc public protocol RecordingDelegate: AnyObject {
    func recordingDeleted(_ token: String)
}

final class RecordingDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var tokenTextField: UITextField!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var editButtonView: UIView!
    @IBOutlet private weak var deleteButtonView: UIView!
    @IBOutlet private weak var backButtonView: UIView!
    @IBOutlet private weak var closeButtonView: UIView!
    @IBOutlet private weak var saveButtonView: UIView!
    @IBOutlet private weak var saveButton: UIView!
    
    // MARK: - Public variables
    var mediaType: MediaTypes = .video
    var recording: ContentModel?
    var recordingDelegate: RecordingDelegate?
    
    // MARK: - Private variables
    private var isEditMode = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let recording = recording {
            switch mediaType {
            case .video:
                imageView.contentMode = .scaleAspectFill
                let imageUrlString = Common.ziggeo?.videos.getImageUrl(recording.token) ?? ""
                imageView.setURL(imageUrlString, placeholder: nil)
            case .audio:
                imageView.contentMode = .scaleAspectFit
                imageView.image = .bgAudio
            default:
                imageView.contentMode = .scaleAspectFill
                let imageUrlString = Common.ziggeo?.images.getImageUrl(recording.token) ?? ""
                imageView.setURL(imageUrlString, placeholder: nil)
            }
            
            tokenTextField.isEnabled = false
            tokenTextField.text = recording.token
            titleTextField.text = recording.title
            descriptionTextField.text = recording.getDescription()
        }
        
        refreshButtons()
    }
}

// MARK: - @IBActions
private extension RecordingDetailViewController {
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        isEditMode = false
        refreshButtons()
    }
    
    @IBAction func onEdit(_ sender: Any) {
        isEditMode = true
        refreshButtons()
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete this recording?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            guard let recording = self.recording else { return }
            SVProgressHUD.show()
            
            let completion: () -> Void = {
                SVProgressHUD.dismiss()
                self.isEditMode = false
                self.recordingDelegate?.recordingDeleted(recording.token)
                self.navigationController?.popViewController(animated: true)
            }
            
            switch self.mediaType {
            case .video:
                Common.ziggeo?.videos.destroy(recording.token, streamToken: recording.streamToken) { _, _, _ in
                    completion()
                }
                
            case .audio:
                Common.ziggeo?.audios.destroy(recording.token) { _, _, _ in
                    completion()
                }
                
            default:
                Common.ziggeo?.images.destroy(recording.token) { _, _, _ in
                    completion()
                }
            }
        }))
        present(alert, animated: true)
    }
    
    @IBAction func onSave(_ sender: Any) {
        guard let recording = recording else { return }
        
        SVProgressHUD.show()
        let data: [AnyHashable: Any] = ["title": titleTextField.text ?? "",
                                        "description": descriptionTextField.text ?? ""]
        
        let completion = {
            SVProgressHUD.dismiss()
            self.isEditMode = false
            self.refreshButtons()
        }
        
        switch mediaType {
        case .video:
            Common.ziggeo?.videos.update(recording.token, data: data) { _, _, _ in
                completion()
            }
            
        case .audio:
            Common.ziggeo?.audios.update(recording.token, data: data) { _, _, _ in
                completion()
            }
            
        default:
            Common.ziggeo?.images.update(recording.token, data: data) { _, _, _ in
                completion()
            }
        }
    }
    
    @IBAction func onPlay(_ sender: Any) {
        guard let recording = recording else { return }
        
        switch mediaType {
        case .video:
            guard UserDefaults.isUsingCustomPlayer else {
                Common.ziggeo?.playVideo(recording.token)
                return
            }
            guard let urlString = Common.ziggeo?.videos.getVideoUrl(recording.token) else {
                return
            }
            let vc = CustomVideoPlayer()
            vc.videoURL = URL(string: urlString)
            present(vc, animated: true)
            
        case .audio:
            Common.ziggeo?.startAudioPlayer(recording.token)
        default:
            Common.ziggeo?.showImage(recording.token)
        }
    }
}

// MARK: - Privates
private extension RecordingDetailViewController {
    func refreshButtons() {
        backButtonView.isHidden = isEditMode
        closeButtonView.isHidden = !isEditMode
        editButtonView.isHidden = isEditMode
        deleteButtonView.isHidden = isEditMode
        saveButtonView.isHidden = !isEditMode
        saveButton.isHidden = !isEditMode
        
        titleTextField.isEnabled = isEditMode
        descriptionTextField.isEnabled = isEditMode
    }
}
