import UIKit

final class LogTableViewCell: UITableViewCell {

    @IBOutlet private weak var logLabel: UILabel!
    
    func setData(log: String) {
        logLabel.text = log
    }
}
