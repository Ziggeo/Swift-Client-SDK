import UIKit
import ZiggeoMediaSwiftSDK

final class RecordingTableViewCell: UITableViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var tokenLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    func setData(icon: UIImage?, content: ContentModel) {
        containerView.setShadow(radius: 10, offset: .zero, cornerRadius: 5)
        iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = .black
        
        tokenLabel.text = content.token
        stateLabel.text = content.stateString
        dateLabel.text = content.date.toDate
    }
}
