import UIKit

@IBDesignable extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func setShadow(radius: CGFloat, offset: CGSize, cornerRadius: CGFloat = 0) {
        if (cornerRadius > 0) {
            self.layer.cornerRadius = CGFloat(cornerRadius)
        }
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.clipsToBounds = false
    }
}
