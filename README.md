Ziggeo Swift SDK 1.1.7
=============

Ziggeo API (http://ziggeo.com) allows you to integrate video recording and playback with only two lines of code in your site, service or app. This is the iOS SDK repository. 

## Upgrading from v 1.1.7 to v.1.1.8
Swift 5.1 support added

## Upgrading from v 1.1.6 to v.1.1.7
Sequence of video items playback support added. See ZiggeoPlayer.createPlayerForMultipleVideos for details

## Upgrading from v 1.1.5 to v.1.1.6
Custom data support fixed. Use `["data":"{\"foo\":\"bar\"}"]` as an extra data args to pass custom data to the recorded video

## Upgrading from v 1.1.4 to v.1.1.5
Subtitles support added

## Upgrading from v 1.1.3 to v.1.1.4
Swift 5 support added

## Upgrading from v 1.1.0 to v.1.1.3
The update brings new optional features such as light meter, audio level meter and face outlining. These features are also available in the updated ZiggeoRecorder delegate

## Upgrading from v 1.0.9 to v.1.1.0
Caching issue resolved for videos with default effect applied

## Upgrading from v.1.0.8 to v.1.0.9
Swift 4.2(3.4) framework builds added

## Upgrading from v.1.0.7 to v.1.0.8
The update bring dashboard `/debugger` error reporting.

## Upgrading from v.1.0.6 to v.1.0.7
The update bring new `serverAuthToken` and `clientAuthToken` parameters in `ziggeo.connect` object (useful for global auth tokens).

## Upgrading from v.1.0.5 to v.1.0.6

New changes bring new features without changing the entry or exit points of any methods or functions. You can safely upgrade without any changes to your existing codes.

Added feature:
1. Video recorder can be utilized with `server_auth` and `client_auth` auth tokens.
	* To specify them for recorder you should use `extraArgsForCreateVideo`
2. Video player can be utilized with `server_auth` and `client_auth` auth tokens.
	* To specify them for player you should use [method described bellow](#initialization-with-optional-authorization-token)

## Setup
- Create iOS App
- Add ZiggeoSwiftFramework.framework
- Add bridging header in case of mixed objective-C/Swift project

  ```
  #import <ZiggeoSwiftFramework/ZiggeoSwiftFramework.h>
  ```
- Make sure ZiggeoSwiftFramework.framework is added to Embedded Binaries and Linked Framework sections in your app target settings
- Configure audio session in the AppDelegate
  ```
    func application(_ application: UIApplication, didFinishLaunchingWithOptions ...) {
        // Override point for customization after application launch.
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: [AVAudioSessionCategoryOptions.duckOthers, AVAudioSessionCategoryOptions.defaultToSpeaker]);
        }
        catch {}
        return true
    }
  ```
- Add NSCameraUsageDescription and NSMicrophoneUsageDescription sections into the info.plist file

## Building/Packaging App
- Grab framework from Swift-Client-SDK/Output/ directory. Use Swift 3.2 version for Xcode 9.0+, Swift 3.1 version for Xcode 8.3+ and Swift 3 for older Xcode versions
- Add framework into "linked frameworks" and "embedded binaries" at the project build settings
- Clean and rebuild the application

## CocoaPods Support (optional)
- Install CocoaPods
  ```
  $ sudo gem install cocoapods
  ```
- Create new iOS project
- Init pods in the xcode project directory
  ```
  $ pod init
  ```
- Add framework to Podfile
  ```
  pod 'ZiggeoSwiftSDK', :git => 'https://github.com/Ziggeo/Swift-Client-SDK.git', :branch => '1.0.0'
  ```
- Install framework
  ```
  $ pod install
  ```
- Reopen the project using the .xcworkspace

## Preparing App for the Submission to App Store
- Create "new run script phase" at the application target build settings to strip the unused architectures. Use the script provided with the Swift-Client-SDK/TestApplication example (TestApplication target settings -> Build phases -> Run script section)

# Basic Usage
## Initialize Application

```
import ZiggeoSwiftFramework

var m_ziggeo: Ziggeo! = nil;
m_ziggeo = Ziggeo(token: "YOUR_APP_TOKEN_HERE");
```

## Video Player

### Initialization
```
func createPlayer()->AVPlayer {
   let player = ZiggeoPlayer(application: m_ziggeo, videoToken: "ZIGGEO_VIDEO_TOKEN");
   return player;
}
```

### Initialization with optional authorization token
```
ZiggeoPlayer.createPlayerWithAdditionalParams(application: m_ziggeo, videoToken: "VIDEO_TOKEN", params: ["client_auth":"CLIENT_AUTH_TOKEN"]) { (player:ZiggeoPlayer?) in
    DispatchQueue.main.async {
        let playerController: AVPlayerViewController = AVPlayerViewController();
        playerController.player = player;
        self.present(playerController, animated: true, completion: nil);
        playerController.player?.play();
    }
}
```

### Fullscreen Playback
```
@IBAction func playFullScreen(sender: AnyObject) {
    let playerController: AVPlayerViewController = AVPlayerViewController();
    playerController.player = createPlayer();
    self.presentViewController(playerController, animated: true, completion: nil);
    playerController.player?.play();
}
```

### Embedded Playback
```
@IBAction func playEmbedded(sender: AnyObject) {
    //cleanup
    if m_embeddedPlayer != nil {
        m_embeddedPlayer.pause();
        m_embeddedPlayerLayer.removeFromSuperlayer();
        m_embeddedPlayer = nil;
        m_embeddedPlayerLayer = nil;
    }
    m_embeddedPlayer = createPlayer();
    m_embeddedPlayerLayer = AVPlayerLayer(player: m_embeddedPlayer);
    m_embeddedPlayerLayer.frame = videoViewPlaceholder.frame;
    videoViewPlaceholder.layer.addSublayer(m_embeddedPlayerLayer);
    m_embeddedPlayer.play();
}
```

### Sequence of Videos Playback
```
@IBAction func playSequenceOfVideos(_ sender: Any) {
    ZiggeoPlayer.createPlayerForMultipleVideos(application: m_ziggeo, videoTokens: ["VIDEO_TOKEN_1", "VIDEO_TOKEN_2", "VIDEO_TOKEN_N"], params: nil) { (player) in
        DispatchQueue.main.async {
            self.queuePlayer = player;
            self.playerLayer = AVPlayerLayer(player: player)
            self.playerLayer.frame = self.videoViewPlaceholder.layer.bounds
            self.videoViewPlaceholder.layer.addSublayer(self.playerLayer)
            player?.play();
        }
    }
}
```

## Video Recorder

```
@IBAction func record(sender: AnyObject) {
    let recorder = ZiggeoRecorder(application: m_ziggeo);
    self.presentViewController(recorder, animated: true, completion: nil);
}
```

### Enable Cover Selector Dialog
```
recorder.coverSelectorEnabled = true;
```

### Enable Recorded Video Preview Dialog
```
recorder.recordedVideoPreviewEnabled = true;
```

### Disable Camera Flip Button

```
recorder.cameraFlipButtonVisible = false;
```

### Set Active Camera Device

```
recorder.cameraDevice = UIImagePickerControllerCameraDevice.Rear;
```

### Enable Face Outlining
```
recorder.showFaceOutline = true;
```

### Enable Light Meter Indicator
```
recorder.showLightIndicator = true;
```

### Enable Audio Level Indicator
```
recorder.showSoundIndicator = true;
```

### Additional Video Parameters (effects, profiles, etc)
```
recorder.extraArgsForCreateVideo = ["effect_profile": "12345"];
```

### Authorization tokens

Recorder-level auth tokens:
```
    recorder.extraArgsForCreateVideo = ["client_auth" : "CLIENT_AUTH_TOKEN"];
```

Global (application-level) auth tokens:
```
    m_ziggeo.connect.clientAuthToken = "CLIENT_AUTH_TOKEN";
```

# Advanced SDK Usage

# Ziggeo API Access
You can use the SDK to access Ziggeo Server API methods in the async manner. The SDK provides the following functionality:
- Create/remove/index videos
- Custom Ziggeo Embedded Server API requests 

All API methods work asynchronously and never block the calling thread. As an option, you may use custom callbacks (completion blocks) to receive results.

## Videos API

### Get Video Accessor Object
```
let videos = m_ziggeo.videos;
```

### Get All Videos
```
videos.Index(nil) { (jsonArray, error) in
    NSLog("index error: \(error), response: \(jsonArray)");
};
```

## Videos Delegate

```
class ViewController: UIViewController, ... ZiggeoVideosDelegate {
...
  //somewhere after initializing Ziggeo object
  m_ziggeo.videos.delegate = self;
...
}
```

### Get Video Preparing to Upload Event After the Token Received
```
    public func videoPreparingToUpload(_ sourcePath: String, token: String) {
        NSLog("preparing to upload \(sourcePath) video with token \(token)");
    }
```

### Get Video Preparing to Upload Event Before the Actual Token Received
```
    public func videoPreparingToUpload(_ sourcePath: String) {
        NSLog("preparing to upload \(sourcePath) video");
    }
```
        
### Get Video Failed (or Cancelled) to Upload Event
```
    public func videoFailedToUpload(_ sourcePath: String) {
        NSLog("failed to upload \(sourcePath) video");
    }
```
    
### Get Video Upload Started Event
```
    public func videoUploadStarted(_ sourcePath: String, token: String, backgroundTask: URLSessionTask) {
        NSLog("upload started with \(sourcePath) video and token \(token)");
        
        //capture the uploading task to be able to cancel it later using m_uploadingTask.cancel()
        m_uploadingTask = backgroundTask;
    }
```

### Get Video Upload Complete Event
```
    public func videoUploadComplete(_ sourcePath: String, token: String, response: URLResponse?, error: NSError?, json:  NSDictionary?) {
        NSLog("upload complete with \(sourcePath) video and token \(token)");
    }
```
    
### Get Video Upload Progress Report
```
    public func videoUploadProgress(_ sourcePath: String, token: String, totalBytesSent: Int64, totalBytesExpectedToSend:  Int64) {
        NSLog("upload progress is \(totalBytesSent) from total \(totalBytesExpectedToSend)");
    }
```


### Create New Video
#### Basic
```
videos.CreateVideo(nil, file: fileToUpload.path!, cover: nil, callback: nil, progress: nil);
```

#### Advanced
Add custom completion/progress callbacks here to make the SDK inform your app about uploading progress and response. Cover image is optional -- Ziggeo can generate default video cover shot.
```
videos.CreateVideo(nil, file: fileToUpload.path!, cover: UIImage?, callback: { (jsonObject, response, error) in
    //update ui
}, progress: { (totalBytesSent, totalBytesExpectedToSend) in
    //update progress ui
})
```

### Delete video
```
videos.DeleteVideo("YOUR_VIDEO_TOKEN", callback: { (responseData, response, error) in
    //update ui
})
```

### Retrieve Video URL to Use in Custom Player
```
let url = videos.GetURLForVideo("YOUR_VIDEO_TOKEN_HERE"))
```

### Get Remote Video Thumb asynchronously
Remote video thumbs are cached on client side, so you can call the method as frequently as you wish without the performance or network load impact
```
videos.GetImageForVideo("YOUR_VIDEO_TOKEN_HERE", callback: { (image, response, error) in
    //update UI with the received image
})
```

### Generate Local Video Thumb asynchronously
Local video thumbs are cached on client side, so you can call the method as frequently as you wish without the performance impact
```
self.application.videos.GetImageForLocalVideo("LOCAL_VIDEO_PATH", callback: { (image, error) in
    //update UI with the received image
})
```

## Custom Ziggeo API Requests
The SDK provides an opportunity to make custom requests to Ziggeo Embedded Server API. You can make POST/GET/custom_method requests and receive RAW data, json-dictionary or string as the result.

### Get API Accessor Object
```
let connection = self.application.connect;
```

### Make POST Request and Parse JSON Response
```
connection.PostJsonWithPath(path, data: NSDictionary?, callback: { (jsonObject, response, error) in
//jsonObject contains parsed json response received from Ziggeo API Server
})
```

### Make POST Request and Get RAW Data Response
```
connection.PostWithPath(path: String, data: NSDictionary?, callback: { (data, response, error) in
//data contains RAW data received from Ziggeo API Server
})
```

### Make GET Request and Get String Response
```
connection.GetStringWithPath(path: String, data: NSDictionary?, callback: { (string, response, error) in
    //the string contains stringified response received from Ziggeo API Server
})
```
