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

class CustomVideoPlayer : UIViewController, VideoPreviewProtocol {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var videoPlaceholder: UIView!
    
    open var videoURL: URL!
    open var previewDelegate: VideoPreviewDelegate?
    open var isRecordingPreview: Bool = false
    open var videoRecorder: CustomVideoRecorder?
    var m_embeddedPlayer:AVPlayer!
    var m_embeddedPlayerLayer: AVPlayerLayer!
    var m_playing: Bool = false
    
    init() {
        super.init(nibName: "CustomVideoPlayer", bundle: Bundle(for: CustomVideoPlayer.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override var shouldAutorotate : Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.videoURL != nil) {
            self.initPlayer(self.videoURL)
        }
        
        deleteButton.isHidden = !isRecordingPreview
        uploadButton.isHidden = !isRecordingPreview
    }

    func killPlayer() {
        if m_embeddedPlayer != nil {
            m_embeddedPlayer.pause()
            NotificationCenter.default.removeObserver(self)
            m_embeddedPlayerLayer.removeFromSuperlayer()
            m_embeddedPlayerLayer = nil
            m_embeddedPlayer = nil
            m_playing = false
            self.playPauseButton.imageView?.image = UIImage(named: "ic_play")
        }
    }
    
    func initPlayer(_ url: URL) {
        if self.videoURL != nil && self.isViewLoaded
        {
            self.killPlayer()
            let playerItem: AVPlayerItem  = AVPlayerItem(url: url)
            NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            m_embeddedPlayer = AVPlayer(playerItem: playerItem)
            m_embeddedPlayerLayer = AVPlayerLayer(player: m_embeddedPlayer)
            m_embeddedPlayerLayer.frame = self.videoPlaceholder.frame
            videoPlaceholder.layer.addSublayer(m_embeddedPlayerLayer)
            m_playing = false
        }
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        DispatchQueue.main.async(execute: {
            self.playPauseButton.setImage(UIImage(named: "ic_play"), for: UIControl.State.normal)
            self.m_embeddedPlayer.pause()
            self.m_embeddedPlayer.seek(to: CMTimeMake(value: 0, timescale: 1))
        })
    }
    
    open func uploadVideo(_ filePath: URL) {
        let tmpDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        var newFileToUpload = tmpDirectory.appendingPathComponent(filePath.lastPathComponent)

        do {
            try FileManager.default.copyItem(at: filePath, to: newFileToUpload)
        } catch {
            newFileToUpload = filePath // try to use original file, maybe it will not be removed before it will be uploaded
        }
        
        let realFilePath = filePath.absoluteString.replacingOccurrences(of: "file://", with: "")
        Common.ziggeo?.uploadFromPath(realFilePath, data: [:], callback: { jsonObject, response, error in
        }, progress: { totalBytesSent, totalBytesExpectedToSend in
        }, confirmCallback: { jsonObject, response, error in
            DispatchQueue.main.async {
                self.dismiss(animated: false) {
                    Common.isNeedReloadVideos = true
                    self.videoRecorder?.dismiss(animated: false, completion: nil)
                }
            }
        })
    }
    
    @IBAction func retake(_ sender: AnyObject) {
        self.killPlayer()
        super.dismiss(animated: false, completion: nil)
        self.previewDelegate?.retake(videoURL)
    }

    @IBAction func play(_ sender: AnyObject) {
        if (m_embeddedPlayer != nil) {
            if (m_playing) {
                m_embeddedPlayer.pause()
                m_playing = false
            } else {
                m_embeddedPlayer.play()
                m_playing = true
            }
            DispatchQueue.main.async(execute: {
                self.playPauseButton.setImage(UIImage(named: self.m_playing ? "ic_pause" : "ic_play"), for: UIControl.State.normal)
            })
        }
    }
    
    @IBAction func upload(_ sender: AnyObject) {
        self.killPlayer()
        self.uploadVideo(videoURL)
    }
    
    @IBAction func close(_ sender: AnyObject) {
        self.killPlayer()
        self.dismiss(animated: false) {
            self.videoRecorder?.dismiss(animated: false, completion: nil)
        }
    }
}
