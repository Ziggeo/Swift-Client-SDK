# Changelog

Version 1.1.45-blurring *(2023-10-20)*
-----------------------------
* The update changes delegate functions of mediapipe selfiesegmentation framework.
* The update fixes pausable recording function on blurring mode.

Version 1.1.44-blurring *(2023-09-28)*
-----------------------------
* The update adds stop recording confirmation dialog config.
* The update adds pause button on recording video/audio screen.
* The update adds live streaming.

Version 1.1.42-blurring *(2023-09-21)*
-----------------------------
* The update adds ability to remove the video from uploading when connection is lost.
* The update adds method select the way to handle the video that failed.
* The update adds callback for the network connection status.
* The update adds custom recorder view.

Version 1.1.41-blurring *(2023-08-24)*
* The update changes `playVideo`, `showImage` and `playAudio` functions to use only a item.
* The update adds `playVideos`, `showImages` and `playAudios` functions to support multiple items.
* The update adds `playFromUri`, `playFromUris`, `showImageFromUri`, `showImageFromUris`, `playAudioWithPath` and `playAudioWithPaths`  functions to play from uri.
* The update changes `uploadFromFileSelector` to `startFileSelector`.
* The update creates getters and setters for `AppToken`, `ServerAuthToken` and `ClientAuthToken`.
* The update add configs for `FileSelectorConfig`, `RecorderConfig`, `UploadingConfig`, `PlayerConfig` and `QrScannerConfig`.

Version 1.1.40-blurring *(2023-03-27)*
-----------------------------
* The update adds pausable audio recording function.
* The update does not use `ZiggeoDelegate`, and use separated delegate(`ZiggeoHardwarePermissionDelegate`, `ZiggeoUploadingDelegate`, `ZiggeoFileSelectorDelegate`, `ZiggeoRecorderDelegate`, `ZiggeoSensorDelegate`, `ZiggeoPlayerDelegate`, `ZiggeoScreenRecorderDelegate`, `ZiggeoQRScannerDelegate`).
* The update changes some delegate functions.

Version 1.1.39-blurring *(2022-09-26)*
-----------------------------
* The update changes the pod name to `ZiggeoMediaSwiftSDK`.
* The update does not use `ZiggeoSwiftSDK.framework`, and use `ZiggeoMediaSwiftSDK.framework`.
* The update changes `playVideo`, `showImage`, `startAudioPlayer` and `playFromUrl` functions to support multiple items.

Version 1.1.38-blurring *(2022-08-10)*
-----------------------------
* The update adds multiple file uploads, multiple video plays, multiple audio plays and multiple image views.
* The update adds QR code reader, video trim, sending email to support and sending report.
* The update fixes the problem of playing video from url.
* The update updates some screens.

Version 1.1.37-blurring *(2022-05-23)*
-----------------------------
* The update adds Mediapipe SelfieSegmentation.

Version 1.1.36 *(2022-03-28)*
-----------------------------
* The update removes GoogleAds.
* The update fixes black button problem of audio recording and playing screen on the dark mode.
* The update does not use `ZiggeoSwiftSDK.xcframework`, and use `ZiggeoSwiftSDK.framework`.

Version 1.1.35 *(2022-02-18)*
-----------------------------
* The update adds the blurring effect using mediapipe selfiesegmentation.
* SelfieSegmentation.framework does not contain bitcode.
* Users have to set "Enable Bitcode" to "No" on the Build Settings of the project.

Version 1.1.34
-----------------------------
* Implemented `getVideoUrl` function.

Version 1.1.33
-----------------------------
* Merged several apis for videos, audios and images.

Version 1.1.32
-----------------------------
* Fixed several issues when playing and uploading files.

Version 1.1.31
-----------------------------
* Added the missing events.

Version 1.1.30
-----------------------------
* Added the updated uploading apis for videos, audios and images.

Version 1.1.29
-----------------------------
* Added the audio recording and play functions.

Version 1.1.28
-----------------------------
* Fixed Podfile in the demo app

Version 1.1.27
-----------------------------
* Implemented support for pre-roll ads using the VAST specification. See the new method `playWithAds` in the `ZiggeoPlayer` class

Version 1.1.26
-----------------------------
* Fixed the issue when authentication with server or client tokens did not work  

Version 1.1.25
-----------------------------
* Added notifications telling the user to switch back to the app when the app is uploading videos in background 

Version 1.1.24
-----------------------------
* Fixed issue when video uploads failed when they started right away after each other

Version 1.1.23
-----------------------------
* Implemented possibility to continue video uploads after the app was moved to background. Fixed compatibility with the iOS simulator.
* IMPORTANT! This and following releases require CocoaPods 1.10.0 or higher!

Version 1.1.22
-----------------------------
* Improved compatibility with some older Swift compilers

Version 1.1.21
-----------------------------
* Support for Swift 5.3.1

Version 1.1.20
-----------------------------
* Fixed support of Swift 5.2

Version 1.1.19
-----------------------------
* Added support for Swift 5.3

Version 1.1.18
-----------------------------
* Added support for Swift 5.3

Version 1.1.17
-----------------------------
* Fixed crashes and freezes when starting recording and flipping camera

Version 1.1.16
-----------------------------
* Fixed crash on latest iOS versions when opening recorder

Version 1.1.15
-----------------------------
* Fixed recorder layout on iPhone X and iPhone 11

Version 1.1.14
-----------------------------
* Implemented customization of recorder buttons

Version 1.1.13
-----------------------------
* Fixed an issue when uploading existing videos

Version 1.1.12
-----------------------------
* Swift 5.2 support added

Version 1.1.11
-----------------------------
* Crash fix on camera or microphone access disabled

Version 1.1.10
-----------------------------
* Swift 5.1.2 support added

Version 1.1.9
-----------------------------
* Cover generator updated

Version 1.1.8
-----------------------------
* Swift 5.1 support added

Version 1.1.7
-----------------------------
* Sequence of video items playback support added. See ZiggeoPlayer.createPlayerForMultipleVideos for details

Version 1.1.6
-----------------------------
* Custom data support fixed. Use `["data":"{\"foo\":\"bar\"}"]` as an extra data args to pass custom data to the recorded video

Version 1.1.5
-----------------------------
* Subtitles support added

Version 1.1.4
-----------------------------
* Swift 5 support added

Version 1.1.3
-----------------------------
* The update brings new optional features such as light meter, audio level meter and face outlining. These features are also available in the updated ZiggeoRecorder delegate

Version 1.1.0
-----------------------------
* Caching issue resolved for videos with default effect applied

Version 1.0.9
-----------------------------
* Swift 4.2(3.4) framework builds added

Version 1.0.8
-----------------------------
* The update bring dashboard `/debugger` error reporting.

Version 1.0.7
-----------------------------
* The update bring new `serverAuthToken` and `clientAuthToken` parameters in `ziggeo.connect` object (useful for global auth tokens).

Version 1.0.6
-----------------------------
*  New changes bring new features without changing the entry or exit points of any methods or functions. You can safely upgrade without any changes to your existing codes.

Added feature:
1. Video recorder can be utilized with `server_auth` and `client_auth` auth tokens.
	* To specify them for recorder you should use `extraArgsForCreateVideo`
2. Video player can be utilized with `server_auth` and `client_auth` auth tokens.
	* To specify them for player you should use [method described bellow](#initialization-with-optional-authorization-token)