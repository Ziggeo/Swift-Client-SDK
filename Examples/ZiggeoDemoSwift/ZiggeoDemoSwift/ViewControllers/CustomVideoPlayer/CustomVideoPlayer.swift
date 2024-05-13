//
//  CustomVideoPlayer.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import Foundation
import AVFoundation

public protocol VideoPreviewDelegate {
    func retake(_ fileToBeRemoved: URL!)
    func uploadVideo(_ filePath: URL)
}

public protocol VideoPreviewProtocol {
    var videoURL: URL! { get set }
    var previewDelegate: VideoPreviewDelegate? { get set }
}

final class CustomVideoPlayer: UIViewController, VideoPreviewProtocol {
    
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var uploadButton: UIButton!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var videoPlaceholder: UIView!
    
    var videoURL: URL!
    var previewDelegate: VideoPreviewDelegate?
    var isRecordingPreview = false
    var videoRecorder: CustomVideoRecorder?
    var m_embeddedPlayer: AVPlayer!
    var m_embeddedPlayerLayer: AVPlayerLayer!
    var m_playing = false
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoURL.flatMap { initPlayer($0) }
        
        deleteButton.isHidden = !isRecordingPreview
        uploadButton.isHidden = !isRecordingPreview
    }

    func killPlayer() {
        guard let player = m_embeddedPlayer else {
            return
        }
        player.pause()
        NotificationCenter.default.removeObserver(self)
        m_embeddedPlayerLayer.removeFromSuperlayer()
        m_embeddedPlayerLayer = nil
        m_embeddedPlayer = nil
        m_playing = false
        playPauseButton.setImage(.playIcon, for: .normal)
    }
    
    func initPlayer(_ url: URL) {
        guard self.videoURL != nil, isViewLoaded else {
            return
        }
        killPlayer()
        let playerItem = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(itemDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        m_embeddedPlayer = AVPlayer(playerItem: playerItem)
        m_embeddedPlayerLayer = AVPlayerLayer(player: m_embeddedPlayer)
        m_embeddedPlayerLayer.frame = videoPlaceholder.frame
        videoPlaceholder.layer.addSublayer(m_embeddedPlayerLayer)
        m_playing = false
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        DispatchQueue.main.async {
            self.playPauseButton.setImage(.playIcon, for: .normal)
            self.m_embeddedPlayer.pause()
            self.m_embeddedPlayer.seek(to: CMTimeMake(value: 0, timescale: 1))
        }
    }
    
    func uploadVideo(_ filePath: URL) {
        let tmpDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        var newFileToUpload = tmpDirectory.appendingPathComponent(filePath.lastPathComponent)

        do {
            try FileManager.default.copyItem(at: filePath, to: newFileToUpload)
        } catch {
            newFileToUpload = filePath
        }
        
        Common.ziggeo?.uploadFromPath(filePath.absoluteString, data: [:], callback: { _, _, _ in
        }, progress: { _, _ in
        }, confirmCallback: { _, _, _ in
        })
        dismiss(animated: false) {
            self.videoRecorder?.dismiss(animated: false)
        }
    }
    
    @IBAction func retake(_ sender: AnyObject) {
        killPlayer()
        super.dismiss(animated: false) // TODO: @skatolyk - Check if we need super here
        previewDelegate?.retake(videoURL)
    }

    @IBAction func play(_ sender: AnyObject) {
        guard let player = m_embeddedPlayer else {
            return
        }
        m_playing ? player.pause() : player.play()
        m_playing.toggle()
        
        playPauseButton.setImage(m_playing ? .pauseIcon : .playIcon, for: .normal)
    }
    
    @IBAction func upload(_ sender: AnyObject) {
        killPlayer()
        uploadVideo(videoURL)
    }
    
    @IBAction func close(_ sender: AnyObject) {
        killPlayer()
        dismiss(animated: false) {
            self.videoRecorder?.dismiss(animated: false)
        }
    }
}
