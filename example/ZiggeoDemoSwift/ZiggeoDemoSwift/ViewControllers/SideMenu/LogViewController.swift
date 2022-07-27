//
//  LogViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit

class LogViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var logTableView: UITableView!
    @IBOutlet weak var sendReportButton: UIButton!
    @IBOutlet weak var noResultLabel: UILabel!
    
    // MARK: - Private variables
    private let reuseIdentifier = "LogTableViewCell"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        logTableView.delegate = self
        logTableView.dataSource = self
        logTableView.estimatedRowHeight = 40
        logTableView.rowHeight = UITableView.automaticDimension
        logTableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (Common.logs.isEmpty == true) {
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

    // MARK: - Actions
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LogTableViewCell
        cell.setData(log: Common.logs[indexPath.row])
        return cell
    }
}
