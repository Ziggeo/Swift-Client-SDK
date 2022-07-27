//
//  RecordingImagesViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import ZiggeoSwiftFramework
import SVProgressHUD

class RecordingImagesViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var recordingsTableView: UITableView!
    
    // MARK: - Private variables
    private let refreshControl = UIRefreshControl()
    private var recordings: [ContentModel] = []
    private let reuseIdentifier = "RecordingTableViewCell"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Common.recordingImagesController = self
        
        recordingsTableView.delegate = self
        recordingsTableView.dataSource = self
        recordingsTableView.estimatedRowHeight = 120
        recordingsTableView.rowHeight = UITableView.automaticDimension
        recordingsTableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        recordingsTableView.addSubview(refreshControl)
        
        getRecordings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (Common.isNeedReloadImages) {
            Common.isNeedReloadImages = false
            getRecordings()
        }
        
        Common.currentTab = Media_Type.Image
    }
    
    // MARK: - Functions
    @objc func refresh(_ sender: AnyObject) {
       getRecordings()
    }
    
    func getRecordings() {
        SVProgressHUD.show()
        Common.ziggeo?.images.index([:], callback: { array, error in
            self.recordings.removeAll()
            for item in array {
                if item.stateString != Ziggeo_Status_Type.STATUS_EMPTY.rawValue && item.stateString != Ziggeo_Status_Type.STATUS_DELETED.rawValue {
                    self.recordings.append(item)
                }
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.refreshControl.endRefreshing()
                self.recordingsTableView.reloadData()
                
                var tokens: [String] = []
                for recording in self.recordings {
                    tokens.append(recording.token)
                }
                Common.imageTokens.removeAll()
                Common.imageTokens.append(contentsOf: tokens)
            }
        })
    }
    
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension RecordingImagesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recording = recordings[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RecordingTableViewCell
        cell.setData(icon: "ic_tab_image", content: recording)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let vc = Common.getStoryboardViewController("RecordingDetailViewController") as? RecordingDetailViewController {
            vc.mediaType = Media_Type.Image
            vc.recording = recordings[indexPath.row]
            Common.mainNavigationController?.pushViewController(vc, animated: true)
        }
    }
}
