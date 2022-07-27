//
//  Common.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//


import UIKit
import AVFoundation
import ZiggeoSwiftFramework

// MARK AlertDelegate
public protocol AlertButtonClickDelegate : NSObjectProtocol {
    func onAlertButtonClicked()
}

// MARK: Common
class Common: NSObject {
    static let Application_Token_Key = "Application_Token_Key"
    static let Start_Delay_Key = "Start_Delay_Key"
    static let Custom_Camera_Key = "Custom_Camera_Key"
    static let Custom_Player_Key = "Custom_Player_Key"
    static let Blur_Mode_Key = "Blur_Mode_Key"
    
    static let SdkList = [
        [
            LogoData(title: "Objective-C", image: "logo-objectivec", url: "https://github.com/Ziggeo/iOS-Client-SDK"),
            LogoData(title: "Swift", image: "logo-swift", url: "https://github.com/Ziggeo/Swift-Client-SDK"),
            LogoData(title: "Android", image: "logo-android", url: "https://github.com/Ziggeo/Android-Client-SDK"),
            LogoData(title: "Xamarin", image: "logo-xamarin", url: "https://github.com/Ziggeo/Xamarin-SDK-Demo"),
            LogoData(title: "React Native", image: "logo-reactnative", url: "https://github.com/Ziggeo/ReactNativeDemo"),
            LogoData(title: "Flutter", image: "logo-flutter", url: "https://github.com/Ziggeo/Flutter-SDK")
        ],
        [
            LogoData(title: "Php", image: "logo-php", url: "https://github.com/Ziggeo/ZiggeoPhpSdk"),
            LogoData(title: "Python", image: "logo-python", url: "https://github.com/Ziggeo/ZiggeoPythonSdk"),
            LogoData(title: "Node", image: "logo-node", url: "https://github.com/Ziggeo/ZiggeoNodeSdk"),
            LogoData(title: "Ruby", image: "logo-ruby", url: "https://github.com/Ziggeo/ZiggeoRubySdk"),
            LogoData(title: "Java", image: "logo-java", url: "https://github.com/Ziggeo/ZiggeoJavaSdk"),
            LogoData(title: "C#", image: "logo-csharp", url: "https://github.com/Ziggeo/ZiggeoCSharpSDK")
        ]
    ]
    static let ClientList = [
        LogoData(title: "SAP", image: "logo_sap", url: "https://sap.com"),
        LogoData(title: "GoFundMe", image: "logo_gofundme", url: "https://www.gofundme.com"),
        LogoData(title: "SwissPost", image: "logo_swisspost", url: "https://www.post.ch/en"),
        LogoData(title: "Virgin", image: "logo_virgin", url: "https://www.virginatlantic.com"),
        LogoData(title: "ItsLearning", image: "logo_itslearning", url: "https://itslearning.com"),
        LogoData(title: "Callidus Cloud", image: "logo_callidus", url: "https://www.calliduscloud.com"),
        LogoData(title: "Hire IQ", image: "logo_hireiq", url: "http://www.hireiqinc.com"),
        LogoData(title: "Fiverr", image: "logo_fiverr", url: "https://www.fiverr.com"),
        LogoData(title: "CircleUp", image: "logo_circleup", url: "https://circleup.com"),
        LogoData(title: "Youcruit", image: "logo_youcruit", url: "https://us.youcruit.com"),
        LogoData(title: "Netflix", image: "logo_netflix", url: "https://www.netflix.com"),
        LogoData(title: "Spotify", image: "logo_spotify", url: "https://spotify.com"),
        LogoData(title: "NYU Stern", image: "logo_nyustern", url: "http://www.stern.nyu.edu"),
        LogoData(title: "Dubizzle", image: "logo_dubizzle", url: "https://dubizzle.com"),
        LogoData(title: "Union Square Ventures", image: "logo_usv", url: "https://usv.com"),
        LogoData(title: "Maven Clinic", image: "logo_mavenclinic", url: "https://www.mavenclinic.com"),
    ]
    
    static var mainNavigationController: UINavigationController?
    static var subNavigationController: UINavigationController?
    static var ziggeo: Ziggeo?
    static var logs: [String] = []
    static var homeViewController: HomeViewController?
    static var recordingVideosController: RecordingVideosViewController?
    static var recordingAudiosController: RecordingAudiosViewController?
    static var recordingImagesController: RecordingImagesViewController?
    static var isNeedReloadVideos = false
    static var isNeedReloadAudios = false
    static var isNeedReloadImages = false
    static var currentTab = Media_Type.Video
    static var videoTokens: [String] = []
    static var audioTokens: [String] = []
    static var imageTokens: [String] = []
}

extension Common {
    class func openWebBrowser(_ urlString: String) {
        let url = URL(string: urlString)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:])
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
    
    class func showAlertView(_ message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
        }))
        UIApplication.shared.windows[0].rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    static func getStoryboardViewController(_ identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        return vc
    }
    
    static func addLog(_ log: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: Date())
        Common.logs.append("[\(dateString)] \(log)")
    }
}
