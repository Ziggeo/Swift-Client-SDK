Ziggeo Swift SDK
================

Ziggeo API (http://ziggeo.com) allows you to integrate video recording and playback with only two lines of code in your site, service or app. This is the iOS SDK repository. 

Note: Starting with 1.1.22 this SDK requires Swift 5.3.1 compiler due to Swift compiler limitation. If you want to use Swift 5.3 or below you should use ZiggeoSwiftSDK 1.1.21 or older.

## Upgrading from v 1.1.32 to v.1.1.33
Merged several apis for videos, audios and images.

## Upgrading from v 1.1.31 to v.1.1.32
Fixed several issues when playing and uploading files.

## Upgrading from v 1.1.30 to v.1.1.31
Added the missing events.

## Upgrading from v 1.1.29 to v.1.1.30
Added the updated uploading apis for videos, audios and images.

## Upgrading from v 1.1.28 to v.1.1.29
Added the audio recording and play functions.

## Upgrading from v 1.1.27 to v.1.1.28
Fixed Podfile in the demo app

## Upgrading from v 1.1.26 to v.1.1.27
Implemented support for pre-roll ads using the VAST specification. See the new method `playWithAds` in the `ZiggeoPlayer` class

## Upgrading from v 1.1.25 to v.1.1.26
Fixed the issue when authentication with server or client tokens did not work  

## Upgrading from v 1.1.24 to v.1.1.25
Added notifications telling the user to switch back to the app when the app is uploading videos in background 

## Upgrading from v 1.1.23 to v.1.1.24
Fixed issue when video uploads failed when they started right away after each other

## Upgrading from v 1.1.22 to v.1.1.23
Implemented possibility to continue video uploads after the app was moved to background. Fixed compatibility with the iOS simulator.
IMPORTANT! This and following releases require CocoaPods 1.10.0 or higher!

## Upgrading from v 1.1.21 to v.1.1.22
Improved compatibility with some older Swift compilers

## Upgrading from v 1.1.20 to v.1.1.21
Support for Swift 5.3.1

## Upgrading from v 1.1.19 to v.1.1.20
Fixed support of Swift 5.2

## Upgrading from v 1.1.18 to v.1.1.19
Added support for Swift 5.3

## Upgrading from v 1.1.17 to v.1.1.18
Added support for Swift 5.3

## Upgrading from v 1.1.16 to v.1.1.17
Fixed crashes and freezes when starting recording and flipping camera

## Upgrading from v 1.1.15 to v.1.1.16
Fixed crash on latest iOS versions when opening recorder

## Upgrading from v 1.1.14 to v.1.1.15
Fixed recorder layout on iPhone X and iPhone 11

## Upgrading from v 1.1.13 to v.1.1.14
Implemented customization of recorder buttons

## Upgrading from v 1.1.12 to v.1.1.13
Fixed an issue when uploading existing videos

## Upgrading from v 1.1.11 to v.1.1.12
Swift 5.2 support added

## Upgrading from v 1.1.10 to v.1.1.11
Crash fix on camera or microphone access disabled

## Upgrading from v 1.1.8 to v.1.1.10
Swift 5.1.2 support added

## Upgrading from v 1.1.8 to v.1.1.9
Cover generator updated

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
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: [AVAudioSessionCategoryOptions.duckOthers, AVAudioSessionCategoryOptions.defaultToSpeaker])
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
  pod 'ZiggeoSwiftSDK', :git => 'https://github.com/Ziggeo/Swift-Client-SDK.git'
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

var m_ziggeo = Ziggeo(token: "ZIGGEO_APP_TOKEN", delegate: self)
```

## Usage
### Record Video
```
    m_ziggeo.record()
```

### Play Video With Token
```
m_ziggeo.playVideo(VIDEO_TOKEN)
```

### Play Video With Url
```
m_ziggeo.playFromUri(Video_Url)
```

### Record Audio
```
m_ziggeo.startAudioRecorder()
```

### Play Audio
```
m_ziggeo.startAudioPlayer("AUDIO_TOKEN")
```

### Record Image
```
m_ziggeo.startImageRecorder()
```

### Show Image
```
m_ziggeo.showImage("IMAGE_TOKEN")
```

### Start Screen Recorder
```
m_ziggeo.startScreenRecorder()
```

### Upload From Path
```
m_ziggeo.uploadFromPath("FILE_PATH", data: [:])
```

### Upload From File Selector
```
var data: [String: Any] = [:]
// data["media_types"] = ["video", "audio", "image"]
self.m_ziggeo.uploadFromFileSelector(data)
```

### Cancel Upload
```
m_ziggeo.cancelUpload(path, delete_file)
```

### Start QR Scanner
```
m_ziggeo.startQrScanner([:])
```

## Config
### Uploading Config
```
var config: [String: Any] = [:]
config["tags"] = "iOS_Choose_Media"
self.m_ziggeo.setUploadingConfig(config)
```

### Streaming Recording
```
m_ziggeo.setLiveStreamingEnabled(true)
```
Streaming recording mode will upload the video stream during the recording without caching to local file first. Video preview and video re-record are not available in this mode.

### Autostart Recording After
```
m_ziggeo.setAutostartRecordingAfter(0)
```

### Start Delay
```
m_ziggeo.setStartDelay(0)
```

### Extra Argment For Recorder
```
var map: [String: Any] = [:]
map["effect_profile"] = "12345"
map["data"] = [:]
map["client_auth"] = "CLIENT_AUTH_TOKEN"
map["server_auth"] = "SERVER_AUTH_TOKEN"
self.m_ziggeo.setExtraArgsForRecorder(map)
```

### Extra Argment For Recorder
```
var themeMap: [String: Any] = [:]
themeMap["blur_effect"] = "false"
themeMap["hideRecorderControls"] = "false"
self.m_ziggeo.setThemeArgsForRecorder(themeMap)
```

### Enable Cover Selector Dialog
```
m_ziggeo.setCoverSelectorEnabled(true)
```

### Capture Duration Limit
```
m_ziggeo.setMaxRecordingDuration(600)
```

### Set Video Width
```
m_ziggeo.setVideoWidth(1920)
```

### Set Video Height
```
m_ziggeo.setVideoHeight(1080)
```

### Set Video Bitrate
```
m_ziggeo.setVideoBitrate(1024 * 1024 * 2)
```

### Set Audio Sample Rate
```
m_ziggeo.setAudioSampleRate(44100)
```

### Set Audio Bitrate
```
m_ziggeo.setAudioBitrate(128 * 1024)
```

### Set CAmera Switch Enabled
```
m_ziggeo.setCameraSwitchEnabled(true)
```

### Set Send Immediately
```
m_ziggeo.setSendImmediately(true)
```

### Set Recording Quality
```
//m_ziggeo.setQuality(RecordingQuality.LowQuality)
m_ziggeo.setQuality(RecordingQuality.MediumQuality)
//m_ziggeo.setQuality(RecordingQuality.HighestQuality)
```

### Set Camera
```
m_ziggeo.setCamera(0)
```

### Set Extra Argument For Player
```
m_ziggeo.setExtraArgsForPlayer([:])
```

### Set Theme Argument For Player 
```
var map: [String: Any] = [:]
map["hidePlayerControls"] = "false"
m_ziggeo.setThemeArgsForPlayer(map)
```

### Set Player Cache Config
```
m_ziggeo.setPlayerCacheConfig([:])
```

### Set Ads Url
```
m_ziggeo.setAdsURL("ADS_URL")
```

### Delegate
#### ZiggeoDelegate
```
extension ViewController: ZiggeoDelegate {
    ...
}
```

You can use ZiggeoDelegate in your app to be notified about video recording events.
```
func ziggeoRecorderLuxMeter(_ luminousity: Double) {
    //
}

func ziggeoRecorderAudioMeter(_ audioLevel: Double) {
    //
}

func ziggeoRecorderFaceDetected(_ faceID: Int, rect: CGRect) {
    // this method will be called when face is detected
}

func ziggeoRecorderReady() {
    // this method will be called when recorder is ready to recorder
}

func ziggeoRecorderCanceled() {
    // this method will be called when video recorder is canceled
}

func ziggeoRecorderStarted() {
    // this method will be called when recorder is started
}

func ziggeoRecorderStopped(_ path: String) {
    // this method will be called when recorder is stopped
}

func ziggeoRecorderCurrentRecordedDurationSeconds(_ seconds: Double) {
    // this method will be called while recording
}

func ziggeoRecorderPlaying() {
    // this method will be called when recorder plays the recorded audio
}

func ziggeoRecorderPaused() {
    // this method will be called when recorder pauses the recorded audio
}

func ziggeoRecorderRerecord() {
    // this method will be called when recorder is rerecorded
}

func ziggeoRecorderManuallySubmitted() {
    // this method will be called when recorded file(video or audio) is uploaded by the user
}

func ziggeoStreamingStarted() {
    // Triggered when a streaming process has started (Press on the Record button if countdown 0 or after the countdown goes to 0)
}

func ziggeoStreamingStopped() {
    // Triggered when a streaming process has stopped (automatically after reaching the maximum duration or manually.)
}
```

You can use ZiggeoDelegate in your app to be notified about file(video, audio, image) uploading events.
```
func preparingToUpload(_ path: String) {
    // this method will be called first before any Ziggeo API interaction
}

func failedToUpload(_ path: String) {
    // this method will be called when file(video, audio, image) uploading was failed
}

func uploadStarted(_ path: String, token: String, streamToken: String, backgroundTask: URLSessionTask) {
    // this method will be called on actual file(video, audio, image) upload start after empty file(video, audio, image) creation on Ziggeo platform
}

func uploadProgress(_ path: String, token: String, streamToken: String, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    // this method will be called while uploading the file(video, audio, image)
}

func uploadFinished(_ path:String, token: String, streamToken: String) {
    // this method will be called after the file(video, audio, image) was uploaded
}

func uploadVerified(_ path:String, token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
    // this method will be called when file(video, audio, image) upload finished successfully or failed
}

func uploadProcessing(_ path: String, token: String, streamToken: String) {
    // this method will be called while processing the file(video, audio, image)
}

func uploadProcessed(_ path: String, token: String, streamToken: String) {
    // this method will be called when uploading the file(video, audio, image) was finished by ziggeo servers
}

func delete(_ token: String, streamToken: String, response: URLResponse?, error: Error?, json: NSDictionary?) {
    // this method will be called when file(video, audio, image) was deleted
}
```

You can use ZiggeoDelegate in your app to be notified about file(video, audio) playing events.
```
func ziggeoPlayerPlaying() {
    // Fires any time a playback is started
}

func ziggeoPlayerPaused() {
    // Fires when the pause button is clicked (and at the end of the video)
}

func ziggeoPlayerEnded() {
    // Fires when a video playback has ended (reaches the end)
}

func ziggeoPlayerSeek(_ positionMillis: Double) {
    // Triggered when the user moves the progress indicator to continue video playback from a different position
}

func ziggeoPlayerReadyToPlay() {
    // Triggered when a video player is ready to play a video
}
```

You can use ZiggeoDelegate in your app to be notified about hardware and permission.
```
func checkCameraPermission(_ granted: Bool) {
    // this method will return when camera access permission is granted or denied.
}

func checkMicrophonePermission(_ granted: Bool) {
    // this method will return when microphone access permission is granted or denied.
}

func checkPhotoLibraryPermission(_ granted: Bool) {
    // this method will return when photo library access permission is granted or denied.
}

func checkHasCamera(_ hasCamera: Bool) {
    // this method will return whether camera hardware is detected or not.
}

func checkHasMicrophone(_ hasMicrophone: Bool) {
    // this method will return whether microphone hardware is detected or not.
}
```

## Custom Ziggeo API Requests
The SDK provides an opportunity to make custom requests to Ziggeo Embedded Server API. You can make POST/GET/custom_method requests and receive RAW data, json-dictionary or string as the result.

### Get API Accessor Object
```
let connection = self.application.connect
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


## Notification when uploading videos in background
iOS has limitations on time which the app can do various activity in background mode. 
For instance in iOS 14 this time is limited by around 30 seconds.
In case if user moves the current app into background and Ziggeo SDK is still uploading some video(s) then the SDK will show 
an user notification asking the user to bring the app to foreground to make sure that videos will be uploaded successfully.
This functionality requires UNNotifications enabled in the app. 
To enable them add the following code in the method `func application(_ application: didFinishLaunchingWithOptions: )` in the `AppDelegate` class:

```
if #available(iOS 10.0, *) {
    let center  = UNUserNotificationCenter.current()
    center.delegate = self
    center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
        if error == nil {
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            })
        }
    }
} else {
    let settings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
    UIApplication.shared.registerUserNotificationSettings(settings)
    UIApplication.shared.registerForRemoteNotifications()
}
```
