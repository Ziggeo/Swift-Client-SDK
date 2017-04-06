Ziggeo Swift SDK 1.0
=============

Ziggeo API (http://ziggeo.com) allows you to integrate video recording and playback with only two lines of code in your site, service or app. This is the iOS SDK repository. 

## Setup
- Create iOS App
- Add ZiggeoSwiftFramework.framework
- Add bridging header in case of mixed objective-C/Swift project

  ```
  #import <ZiggeoSwiftFramework/ZiggeoSwiftFramework.h>
  ```
- Make sure ZiggeoSwiftFramework.framework is added to Embedded Binaries and Linked Framework sections in your app target settings

## Building/packaging app
- Grab framework from Swift-Client-SDK/Output/ directory. Use Swift 3.1 version for Xcode 8.3+ and Swift 3 for older Xcode versions
- Add framework into "linked frameworks" and "embedded binaries" at the project build settings
- Clean and rebuild the application

## CocoaPods support (optional)
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
  pod 'ZiggeoSwiftSDK', '1.0.0'
  ```
- Install framework
  ```
  $ pod install
  ```
- Reopen the project using the .xcworkspace

## Preparing app for the submission to App Store
- Create "new run script phase" at the application target build settings to strip the unused architectures. Use the script provided with the Swift-Client-SDK/TestApplication example (TestApplication target settings -> Build phases -> Run script section)

# Basic usage
## Initialize Application

```
import ZiggeoSwiftFramework

var m_ziggeo: Ziggeo! = nil;
m_ziggeo = Ziggeo(token: "YOUR_APP_TOKEN_HERE");
```

## Player

### Initialization
```
func createPlayer()->AVPlayer {
   let player = AVPlayer(URL: NSURL(string: m_ziggeo.videos.GetURLForVideo("YOUR_VIDEO_TOKEN_HERE"))!);
   return player;
}
```

### Fullscreen playback
```
@IBAction func playFullScreen(sender: AnyObject) {
    let playerController: AVPlayerViewController = AVPlayerViewController();
    playerController.player = createPlayer();
    self.presentViewController(playerController, animated: true, completion: nil);
    playerController.player?.play();
}
```

### Embedded playback
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

## Recorder

```
@IBAction func record(sender: AnyObject) {
    let recorder = ZiggeoRecorder(application: m_ziggeo);
    self.presentViewController(recorder, animated: true, completion: nil);
}
```

### Enable cover selector dialog
```
recorder.coverSelectorEnabled = true;
```

### Disable camera flip button

```
recorder.cameraFlipButtonVisible = false;
```

### Set active camera device

```
recorder.cameraDevice = UIImagePickerControllerCameraDevice.Rear;
```

# Advanced SDK usage
# Ziggeo API access
You can use the SDK to access Ziggeo Server API methods in the async manner. The SDK provides next functionality:
- Create/remove/index videos
- Custom Ziggeo Embedded Server API requests 

All the API methods are working asynchronously and never blocking the calling thread. You may optionally use custom callbacks (completion blocks) to receive the results.

## Videos API

### Get video accessor object
```
let videos = m_ziggeo.videos;
```

### Get all videos
```
videos.Index(nil) { (jsonArray, error) in
    NSLog("index error: \(error), response: \(jsonArray)");
};
```

## Videos delegate

```
class ViewController: UIViewController, ... ZiggeoVideosDelegate {
...
  //somewhere after initializing Ziggeo object
  m_ziggeo.videos.delegate = self;
...
}
```

### Get video preparing to upload event after the token received
```
    public func videoPreparingToUpload(_ sourcePath: String, token: String) {
        NSLog("preparing to upload \(sourcePath) video with token \(token)");
    }
```

### Get video preparing to upload event before the actual token received
```
    public func videoPreparingToUpload(_ sourcePath: String) {
        NSLog("preparing to upload \(sourcePath) video");
    }
```
        
### Get video failed (or cancelled) to upload event
```
    public func videoFailedToUpload(_ sourcePath: String) {
        NSLog("failed to upload \(sourcePath) video");
    }
```
    
### Get video upload started event
```
    public func videoUploadStarted(_ sourcePath: String, token: String, backgroundTask: URLSessionTask) {
        NSLog("upload started with \(sourcePath) video and token \(token)");
        
        //capture the uploading task to be able to cancel it later using m_uploadingTask.cancel()
        m_uploadingTask = backgroundTask;
    }
```

### Get video upload complete event
```
    public func videoUploadComplete(_ sourcePath: String, token: String, response: URLResponse?, error: NSError?, json:  NSDictionary?) {
        NSLog("upload complete with \(sourcePath) video and token \(token)");
    }
```
    
### Get video upload progress report
```
    public func videoUploadProgress(_ sourcePath: String, token: String, totalBytesSent: Int64, totalBytesExpectedToSend:  Int64) {
        NSLog("upload progress is \(totalBytesSent) from total \(totalBytesExpectedToSend)");
    }
```


### Create new video
#### Basic
```
videos.CreateVideo(nil, file: fileToUpload.path!, cover: nil, callback: nil, progress: nil);
```

#### Advanced
You can add your custom completion/progress callbacks here to make the SDK inform your app about uploading progress and response. Cover image is optional and could be nil, making Ziggeo platform to generate default video cover
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

### Get video URL to be used in your own custom player
```
let url = videos.GetURLForVideo("YOUR_VIDEO_TOKEN_HERE"))
```

### Get remote video thumb asynchronously
Remote video thumbs are cached on client side, so you can call the method as frequently as you wish without the performance or network load impact
```
videos.GetImageForVideo("YOUR_VIDEO_TOKEN_HERE", callback: { (image, response, error) in
    //update UI with the received image
})
```

### Generate local video thumb asynchronously
Local video thumbs are cached on client side, so you can call the method as frequently as you wish without the performance impact
```
self.application.videos.GetImageForLocalVideo("LOCAL_VIDEO_PATH", callback: { (image, error) in
    //update UI with the received image
})
```

## Custom Ziggeo API requests
The SDK provides an opportunity to make custom requests to Ziggeo Embedded Server API. You can make POST/GET/custom_method requests and receive RAW data, json-dictionary or string as the result.

### Get API accessor object
```
let connection = self.application.connect;
```

### Make POST request and parse JSON response
```
connection.PostJsonWithPath(path, data: NSDictionary?, callback: { (jsonObject, response, error) in
//jsonObject contains parsed json response received from Ziggeo API Server
})
```

### Make POST request and get RAW data response
```
connection.PostWithPath(path: String, data: NSDictionary?, callback: { (data, response, error) in
//data contains RAW data received from Ziggeo API Server
})
```

### Make GET request and get string response
```
connection.GetStringWithPath(path: String, data: NSDictionary?, callback: { (string, response, error) in
    //the string contains stringified response received from Ziggeo API Server
})
```
There are bunch of other methods for different http methods and response types.
