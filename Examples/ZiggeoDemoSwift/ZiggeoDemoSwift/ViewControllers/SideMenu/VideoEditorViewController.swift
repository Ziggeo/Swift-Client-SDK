//
//  VideoEditorViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import AVFoundation
import MobileCoreServices

final class VideoEditorViewController: UIViewController {
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - @IBActions
private extension VideoEditorViewController {
    @IBAction func onSelectVideo(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.mediaTypes = [UTType.movie.identifier]
        present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension VideoEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: false) {
            let videoUrl = (info[.mediaURL] as! URL).path
            Common.ziggeo?.trimVideo(videoUrl)
        }
    }
}
