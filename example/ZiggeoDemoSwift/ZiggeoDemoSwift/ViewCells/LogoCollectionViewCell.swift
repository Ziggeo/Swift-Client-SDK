import UIKit

class LogoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    func setData(icon: String) {
        containerView.setShadow(radius: 10, offset: CGSize(width: 0, height: 0), cornerRadius: 5)
        logoImageView.image = UIImage(named: icon)
    }
}

