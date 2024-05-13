//
//  RecordingVideosViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import ZiggeoMediaSwiftSDK
import SVProgressHUD
import AVFoundation

final class RecordingVideosViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var recordingsTableView: UITableView!
    
    // MARK: - Private variables
    var recordings: [ContentModel] = []
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Common.recordingVideosController = self
        
        recordingsTableView.delegate = self
        recordingsTableView.dataSource = self
        recordingsTableView.estimatedRowHeight = 120
        recordingsTableView.rowHeight = UITableView.automaticDimension
        recordingsTableView.register(cell: RecordingTableViewCell.self)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        recordingsTableView.addSubview(refreshControl)
        
        getRecordings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Common.currentTab = VIDEO
    }
    
    func getRecordings() {
        SVProgressHUD.show()
        Common.ziggeo?.videos.index([:]) { array, _ in
            SVProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
            
            self.recordings.removeAll()
            for item in array {
                if item.stateString != STATUS_EMPTY && item.stateString != STATUS_DELETED {
                    self.recordings.append(item)
                }
            }
            self.recordingsTableView.reloadData()
        }
    }
}

// MARK: - Privates
private extension RecordingVideosViewController {
    @objc func refresh(_ sender: AnyObject) {
       getRecordings()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension RecordingVideosViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recording = recordings[indexPath.row]
        let cell: RecordingTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setData(icon: .videoTabIcon, content: recording)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        SVProgressHUD.show()
        Common.ziggeo?.videos.get(recordings[indexPath.row].token, data: [:], callback: { content, _, _ in
            SVProgressHUD.dismiss()
            if let vc = Common.getStoryboardViewController(type: RecordingDetailViewController.self) {
                vc.mediaType = VIDEO
                vc.recording = content
                vc.recordingDelegate = self
                Common.mainNavigationController?.pushViewController(vc, animated: true)
            }
        })
    }
}

// MARK: - RecordingDelegate
extension RecordingVideosViewController: RecordingDelegate {
    func recordingDeleted(_ token: String) {
        recordings = recordings.filter { $0.token != token }
        recordingsTableView.reloadData()
    }
}
