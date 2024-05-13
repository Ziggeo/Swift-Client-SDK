//
//  LogViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit

final class LogViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var logTableView: UITableView!
    @IBOutlet private weak var sendReportButton: UIButton!
    @IBOutlet private weak var noResultLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        logTableView.delegate = self
        logTableView.dataSource = self
        logTableView.estimatedRowHeight = 40
        logTableView.rowHeight = UITableView.automaticDimension
        logTableView.register(cell: LogTableViewCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Common.logs.isEmpty {
            logTableView.isHidden = true
            sendReportButton.isHidden = true
            noResultLabel.isHidden = false
        } else {
            logTableView.isHidden = false
            sendReportButton.isHidden = false
            noResultLabel.isHidden = true
        }
        logTableView.reloadData()
    }
}

// MARK: - @IBActions
private extension LogViewController {
    @IBAction func onSendReport(_ sender: Any) {
        Common.ziggeo?.sendReport(Common.logs)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension LogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Common.logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LogTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setData(log: Common.logs[indexPath.row])
        return cell
    }
}
