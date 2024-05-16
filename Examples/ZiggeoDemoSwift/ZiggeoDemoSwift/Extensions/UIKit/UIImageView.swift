import UIKit
import PINRemoteImage

extension UIImageView {
    
    func setURL(_ url: URL?, placeholder: UIImage?) {
        if let u = url {
            self.pin_setImage(from: u)
        } else {
            self.image = placeholder
        }
    }
    
    func setURL(_ strUrl: String, placeholder: UIImage?) {
        let newString = strUrl.replacingOccurrences(of: "\\", with: "/", options: .literal)
        let url = URL(string: newString)
        self.setURL(url, placeholder: placeholder)
    }
    
    func setURL(_ thumbUrl: String, _ imageUrl: String, placeholder: UIImage?) {
        if !thumbUrl.isEmpty {
            self.setURL(thumbUrl, placeholder: placeholder)
        } else if !imageUrl.isEmpty {
            self.setURL(imageUrl, placeholder: placeholder)
        } else {
            self.image = placeholder
        }
    }
}
