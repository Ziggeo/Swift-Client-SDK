//
//  CustomVideoPlayer.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import Foundation
import AVFoundation

public protocol VideoPreviewDelegate: AnyObject {
    func retake(_ fileToBeRemoved: URL)
    func uploadVideo(_ filePath: URL)
    func close()
}

public protocol VideoPreviewProtocol {
    var videoURL: URL! { get set } // swiftlint:disable:this implicitly_unwrapped_optional
    var previewDelegate: VideoPreviewDelegate? { get set }
}

final class CustomVideoPlayer: UIViewController, VideoPreviewProtocol {
    
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var uploadButton: UIButton!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var videoPlaceholder: UIView!
    
    var videoURL: URL! // swiftlint:disable:this implicitly_unwrapped_optional
    weak var previewDelegate: VideoPreviewDelegate?
    var isRecordingPreview = false
    
    private var embeddedPlayer: AVPlayer?
    private var embeddedPlayerLayer: AVPlayerLayer?
    private var isPlaying = false
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton.isHidden = !isRecordingPreview
        uploadButton.isHidden = !isRecordingPreview
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initPlayer(videoURL)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Privates
private extension CustomVideoPlayer {
    func initPlayer(_ url: URL) {
        killPlayer()
        let playerItem = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(itemDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        embeddedPlayer = AVPlayer(playerItem: playerItem)
        embeddedPlayerLayer = AVPlayerLayer(player: embeddedPlayer)
        embeddedPlayerLayer?.frame = videoPlaceholder.frame
        videoPlaceholder.layer.addSublayer(embeddedPlayerLayer!) // swiftlint:disable:this force_unwrapping
        isPlaying = false
    }
    
    func killPlayer() {
        guard let player = embeddedPlayer else {
            return
        }
        player.pause()
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: player.currentItem)
        embeddedPlayerLayer?.removeFromSuperlayer()
        embeddedPlayerLayer = nil
        embeddedPlayer = nil
        isPlaying = false
        playPauseButton.setImage(.playIcon, for: .normal)
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        playPauseButton.setImage(.playIcon, for: .normal)
        embeddedPlayer?.pause()
        embeddedPlayer?.seek(to: CMTimeMake(value: 0, timescale: 1))
    }
    
    func uploadVideo(_ filePath: URL) {
        let tmpDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        var newFileToUpload = tmpDirectory.appendingPathComponent(filePath.lastPathComponent)
        
        do {
            try FileManager.default.copyItem(at: filePath, to: newFileToUpload)
        } catch {
            newFileToUpload = filePath // try to use original file, maybe it will not be removed before it will be uploaded
        }
        
        Common.ziggeo?.uploadFromPath(filePath.absoluteString, data: [:], callback: { _, _, _ in
        }, progress: { _, _ in
        }, confirmCallback: { _, _, _ in
        })
        dismiss(animated: true) { self.previewDelegate?.close() }
    }
}

// MARK: - @IBActions
private extension CustomVideoPlayer {
    @IBAction func retake(_ sender: AnyObject) {
        killPlayer()
        dismiss(animated: true)
        previewDelegate?.retake(videoURL)
    }

    @IBAction func play(_ sender: AnyObject) {
        guard let player = embeddedPlayer else {
            return
        }
        isPlaying ? player.pause() : player.play()
        isPlaying.toggle()
        
        playPauseButton.setImage(isPlaying ? .pauseIcon : .playIcon, for: .normal)
    }
    
    @IBAction func upload(_ sender: AnyObject) {
        killPlayer()
        uploadVideo(videoURL)
    }
    
    @IBAction func close(_ sender: AnyObject) {
        killPlayer()
        dismiss(animated: true) { self.previewDelegate?.close() }
    }
}
