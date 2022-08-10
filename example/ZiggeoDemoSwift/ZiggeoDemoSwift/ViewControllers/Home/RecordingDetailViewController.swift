//
//  RecordingDetailViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import AVKit
import ZiggeoSwiftFramework
import SVProgressHUD

@objc public protocol RecordingDelegate: AnyObject {
    func recordingDeleted(_ token: String)
}

class RecordingDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var editButtonView: UIView!
    @IBOutlet weak var deleteButtonView: UIView!
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var closeButtonView: UIView!
    @IBOutlet weak var saveButtonView: UIView!
    @IBOutlet weak var saveButton: UIView!
    
    // MARK: - Public variables
    var mediaType = Media_Type.Video
    var recording: ContentModel?
    var recordingDelegate: RecordingDelegate?
    
    // MARK: - Private variables
    private var isEditMode = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if (recording != nil) {
            if (mediaType == Media_Type.Video) {
                imageView.contentMode = UIView.ContentMode.scaleAspectFill
                let imageUrlString = Common.ziggeo?.videos.getImageUrl(recording!.token)
                imageView.setURL(imageUrlString, placeholder: nil)
            } else if (mediaType == Media_Type.Audio) {
                imageView.contentMode = UIView.ContentMode.scaleAspectFit
                imageView.image = UIImage(named: "bg_audio")
            } else {
                imageView.contentMode = UIView.ContentMode.scaleAspectFill
                let imageUrlString = Common.ziggeo?.images.getImageUrl(recording!.token)
                imageView.setURL(imageUrlString, placeholder: nil)
            }
            
            tokenTextField.isEnabled = false
            tokenTextField.text = recording!.token
            titleTextField.text = recording!.title
            descriptionTextField.text = recording!.desc
        }
        
        refreshButtons()
    }
    
    // MARK: - Actions
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
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete this recording?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: { (action) in
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [self] (action) in
            if (self.recording != nil) {
                SVProgressHUD.show()
                if (self.mediaType == Media_Type.Video) {
                    Common.ziggeo?.videos.destroy(self.recording!.token, callback: { jsonObject, response, error in
                        SVProgressHUD.dismiss()
                        self.isEditMode = false
                        self.recordingDelegate?.recordingDeleted(self.recording!.token)
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                } else if (self.mediaType == Media_Type.Audio) {
                    Common.ziggeo?.audios.destroy(self.recording!.token, callback: { jsonObject, response, error in
                        SVProgressHUD.dismiss()
                        self.isEditMode = false
                        self.recordingDelegate?.recordingDeleted(self.recording!.token)
                        self.navigationController?.popViewController(animated: true)
                    })

                } else {
                    Common.ziggeo?.images.destroy(self.recording!.token, callback: { jsonObject, response, error in
                        SVProgressHUD.dismiss()
                        self.isEditMode = false
                        self.recordingDelegate?.recordingDeleted(self.recording!.token)
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: Any) {
        if (recording != nil) {
            SVProgressHUD.show()
            let data = ["title": titleTextField.text,
                        "description": descriptionTextField.text]
            
            if (self.mediaType == Media_Type.Video) {
                Common.ziggeo?.videos.update(recording!.token, data: data as [AnyHashable : Any], callback: { content, response, error in
                    SVProgressHUD.dismiss()
                    
                    self.isEditMode = false
                    self.refreshButtons()
                })
                
            } else if (self.mediaType == Media_Type.Audio) {
                Common.ziggeo?.audios.update(recording!.token, data: data as [AnyHashable : Any], callback: { content, response, error in
                    SVProgressHUD.dismiss()
                    
                    self.isEditMode = false
                    self.refreshButtons()
                })
                
            } else {
                Common.ziggeo?.images.update(recording!.token, data: data as [AnyHashable : Any], callback: { content, response, error in
                    SVProgressHUD.dismiss()
                    
                    self.isEditMode = false
                    self.refreshButtons()
                })
            }
        }
    }
    
    @IBAction func onPlay(_ sender: Any) {
        if (recording != nil) {
            if (mediaType == Media_Type.Video) {
                if (UserDefaults.standard.bool(forKey: Common.Custom_Player_Key) == true) {
                    guard let urlString = Common.ziggeo?.videos.getVideoUrl(recording!.token) else {
                        return
                    }
                    let vc = CustomVideoPlayer()
                    vc.videoURL = URL(string: urlString)
                    vc.isRecordingPreview = false
                    present(vc, animated: true, completion: nil)
                    
                } else {
                    Common.ziggeo?.playVideo(recording!.token)
                }
                
            } else if (mediaType == Media_Type.Audio) {
                Common.ziggeo?.playAudio(recording!.token)
                
            } else {
                Common.ziggeo?.showImage(recording!.token)
            }
        }
    }

    // MARK: - Functions
    private func refreshButtons() {
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
