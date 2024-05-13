import UIKit

final class LogoCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var logoImageView: UIImageView!
    
    func setData(icon: String) {
        containerView.setShadow(radius: 10, offset: .zero, cornerRadius: 5)
        logoImageView.image = UIImage(named: icon)
    }
}
