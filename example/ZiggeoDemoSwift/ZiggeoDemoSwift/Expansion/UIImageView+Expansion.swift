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
    
    func setURL(_ strUrl: String?, placeholder: UIImage?) {
        let newString = strUrl?.replacingOccurrences(of: "\\", with: "/", options: .literal, range: nil)
        let url = URL(string: newString!)
        self.setURL(url, placeholder: placeholder)
    }
    
    func setURL(_ thumbUrl: String, _ imageUrl: String, placeholder: UIImage?) {
        if thumbUrl != "" {
            let newString = thumbUrl.replacingOccurrences(of: "\\", with: "/", options: .literal, range: nil)
            let url = URL(string: newString)
            self.setURL(url, placeholder: placeholder)
        } else if imageUrl != "" {
            let newString = imageUrl.replacingOccurrences(of: "\\", with: "/", options: .literal, range: nil)
            let url = URL(string: newString)
            self.setURL(url, placeholder: placeholder)
            
        } else {
            self.image = placeholder
        }
    }
}
