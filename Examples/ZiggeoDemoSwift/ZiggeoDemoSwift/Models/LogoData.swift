import UIKit

class LogoData : NSObject {
        
    var title: String = ""
    var image: String = ""
    var url: String = ""

    init(title: String, image: String, url: String) {
        super.init()
        
        self.title = title
        self.image = image
        self.url = url
    }
}
