import Foundation

extension Double {
    var toDate: String {
        let date = Date(timeIntervalSince1970: self)
        return DateFormatter.dateTime.string(from: date)
    }
}
