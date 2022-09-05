import UIKit

class LogTableViewCell: UITableViewCell {

    @IBOutlet weak var logLabel: UILabel!
    
    func setData(log: String) {
        logLabel.text = log
    }
}
