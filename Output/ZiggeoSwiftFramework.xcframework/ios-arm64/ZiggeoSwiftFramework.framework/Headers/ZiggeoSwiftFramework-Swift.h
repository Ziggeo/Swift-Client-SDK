// Generated by Apple Swift version 5.3.2 (swiftlang-1200.0.45 clang-1200.0.32.28)
#ifndef ZIGGEOSWIFTFRAMEWORK_SWIFT_H
#define ZIGGEOSWIFTFRAMEWORK_SWIFT_H
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <Foundation/Foundation.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(ns_consumed)
# define SWIFT_RELEASES_ARGUMENT __attribute__((ns_consumed))
#else
# define SWIFT_RELEASES_ARGUMENT
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility)
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if !defined(IBSegueAction)
# define IBSegueAction
#endif
#if __has_feature(modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import AVFoundation;
@import CoreGraphics;
@import CoreMedia;
@import Foundation;
@import GoogleInteractiveMediaAds;
@import ObjectiveC;
@import ReplayKit;
@import UIKit;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="ZiggeoSwiftFramework",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif


@class NSCoder;

/// <ul>
///   <li>
///     Subclass this class to use
///   </li>
///   <li>
///     @note
///   </li>
///   <li>
///     Instructions:
///   </li>
///   <li>
///     <ul>
///       <li>
///         Subclass this class
///       </li>
///     </ul>
///   </li>
///   <li>
///     <ul>
///       <li>
///         Associate it with a nib via File’s Owner (Whose name is defined by [-nibName])
///       </li>
///     </ul>
///   </li>
///   <li>
///     <ul>
///       <li>
///         Bind contentView to the root view of the nib
///       </li>
///     </ul>
///   </li>
///   <li>
///     <ul>
///       <li>
///         Then you can insert it either in code or in a xib/storyboard, your choice
///       </li>
///     </ul>
///   </li>
/// </ul>
SWIFT_CLASS("_TtC20ZiggeoSwiftFramework11BaseNibView")
@interface BaseNibView : UIView
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)awakeFromNib;
@end

enum AudioVisualizationMode : NSInteger;
@class UIColor;

SWIFT_CLASS("_TtC20ZiggeoSwiftFramework22AudioVisualizationView")
@interface AudioVisualizationView : BaseNibView
@property (nonatomic) IBInspectable CGFloat meteringLevelBarWidth;
@property (nonatomic) IBInspectable CGFloat meteringLevelBarInterItem;
@property (nonatomic) IBInspectable CGFloat meteringLevelBarCornerRadius;
@property (nonatomic) IBInspectable BOOL meteringLevelBarSingleStick;
@property (nonatomic) enum AudioVisualizationMode audioVisualizationMode;
@property (nonatomic, copy) NSArray<NSNumber *> * _Nullable meteringLevels;
@property (nonatomic, strong) IBInspectable UIColor * _Nonnull gradientStartColor;
@property (nonatomic, strong) IBInspectable UIColor * _Nonnull gradientEndColor;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)drawRect:(CGRect)rect;
- (void)reset;
- (void)addWithMeteringLevel:(float)meteringLevel;
- (NSArray<NSNumber *> * _Nonnull)scaleSoundDataToFitScreen SWIFT_WARN_UNUSED_RESULT;
- (void)playFrom:(NSURL * _Nonnull)url;
- (void)playFor:(NSTimeInterval)duration;
- (void)pause;
- (void)stop;
@end

typedef SWIFT_ENUM(NSInteger, AudioVisualizationMode, open) {
  AudioVisualizationModeRead = 0,
  AudioVisualizationModeWrite = 1,
};



SWIFT_CLASS("_TtC20ZiggeoSwiftFramework18CapturePreviewView")
@interface CapturePreviewView : UIView
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) Class _Nonnull layerClass;)
+ (Class _Nonnull)layerClass SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC20ZiggeoSwiftFramework11Chronometer")
@interface Chronometer : NSObject
- (nonnull instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval OBJC_DESIGNATED_INITIALIZER;
- (void)startWithShouldFire:(BOOL)fire;
- (void)pause;
- (void)stop;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class UITableView;
@class UITableViewCell;
@class NSBundle;

SWIFT_CLASS("_TtC20ZiggeoSwiftFramework13CoverSelector")
@interface CoverSelector : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (void)viewDidLoad;
@property (nonatomic, readonly) BOOL prefersStatusBarHidden;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (NSInteger)tableView:(UITableView * _Nonnull)tableView numberOfRowsInSection:(NSInteger)section SWIFT_WARN_UNUSED_RESULT;
- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath SWIFT_WARN_UNUSED_RESULT;
- (CGFloat)tableView:(UITableView * _Nonnull)tableView heightForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath SWIFT_WARN_UNUSED_RESULT;
- (void)tableView:(UITableView * _Nonnull)tableView didSelectRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil SWIFT_UNAVAILABLE;
@end


SWIFT_CLASS("_TtC20ZiggeoSwiftFramework22CoverSelectorTableCell")
@interface CoverSelectorTableCell : UITableViewCell
- (nonnull instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString * _Nullable)reuseIdentifier OBJC_DESIGNATED_INITIALIZER SWIFT_AVAILABILITY(ios,introduced=3.0);
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder OBJC_DESIGNATED_INITIALIZER;
@end



SWIFT_CLASS("_TtC20ZiggeoSwiftFramework20RecordedVideoPreview")
@interface RecordedVideoPreview : UIViewController
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@property (nonatomic, readonly) BOOL shouldAutorotate;
- (void)viewDidAppear:(BOOL)animated;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil SWIFT_UNAVAILABLE;
@end




SWIFT_CLASS("_TtC20ZiggeoSwiftFramework9ViewModel")
@interface ViewModel : NSObject
@property (nonatomic, copy) NSURL * _Nullable audioFilePathLocal;
@property (nonatomic, copy) NSArray<NSNumber *> * _Nullable meteringLevels;
@property (nonatomic, copy) void (^ _Nullable audioMeteringLevelUpdate)(float);
@property (nonatomic, copy) void (^ _Nullable audioDidFinish)(void);
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (void)askAudioRecordingPermissionWithCompletion:(void (^ _Nullable)(BOOL))completion;
- (void)startRecordingWithCompletion:(void (^ _Nonnull)(NSURL * _Nullable, NSArray<NSNumber *> * _Nullable, NSError * _Nullable))completion;
- (BOOL)stopRecordingAndReturnError:(NSError * _Nullable * _Nullable)error;
- (BOOL)resetRecordingAndReturnError:(NSError * _Nullable * _Nullable)error;
- (double)startPlaying SWIFT_WARN_UNUSED_RESULT;
- (void)setCurrentTime:(NSTimeInterval)currentTime;
- (BOOL)pausePlayingAndReturnError:(NSError * _Nullable * _Nullable)error;
@end


SWIFT_CLASS("_TtC20ZiggeoSwiftFramework6Ziggeo")
@interface Ziggeo : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class UIImagePickerController;

@interface Ziggeo (SWIFT_EXTENSION(ZiggeoSwiftFramework)) <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (void)imagePickerController:(UIImagePickerController * _Nonnull)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> * _Nonnull)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController * _Nonnull)picker;
@end

@class UISlider;

SWIFT_CLASS("_TtC20ZiggeoSwiftFramework19ZiggeoAudioRecorder")
@interface ZiggeoAudioRecorder : UIViewController
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)viewDidLoad;
- (IBAction)onClose:(id _Nonnull)sender;
- (IBAction)onRerecord:(id _Nonnull)sender;
- (IBAction)onRecord:(id _Nonnull)sender;
- (IBAction)onUpload:(id _Nonnull)sender;
- (IBAction)timeChanged:(UISlider * _Nonnull)sender;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil SWIFT_UNAVAILABLE;
@end


SWIFT_CLASS("_TtC20ZiggeoSwiftFramework18ZiggeoCacheManager")
@interface ZiggeoCacheManager : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC20ZiggeoSwiftFramework12ZiggeoConfig")
@interface ZiggeoConfig : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class NSURLSession;
@class NSURLSessionDataTask;
@class NSURLSessionTask;

SWIFT_CLASS("_TtC20ZiggeoSwiftFramework13ZiggeoConnect")
@interface ZiggeoConnect : NSObject <NSURLSessionDataDelegate>
- (void)URLSession:(NSURLSession * _Nonnull)session dataTask:(NSURLSessionDataTask * _Nonnull)dataTask didReceiveData:(NSData * _Nonnull)data;
- (void)URLSession:(NSURLSession * _Nonnull)session task:(NSURLSessionTask * _Nonnull)task didCompleteWithError:(NSError * _Nullable)error;
- (void)URLSession:(NSURLSession * _Nonnull)session task:(NSURLSessionTask * _Nonnull)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class NSURLResponse;
@class NSDictionary;

SWIFT_PROTOCOL("_TtP20ZiggeoSwiftFramework14ZiggeoDelegate_")
@protocol ZiggeoDelegate
@optional
- (void)ziggeoRecorderLuxMeter:(double)luminousity;
- (void)ziggeoRecorderAudioMeter:(double)audioLevel;
- (void)ziggeoRecorderFaceDetected:(NSInteger)faceID rect:(CGRect)rect;
- (void)ziggeoRecorderReady;
- (void)ziggeoRecorderCanceled;
- (void)ziggeoRecorderStarted;
- (void)ziggeoRecorderStopped:(NSString * _Nonnull)path;
- (void)ziggeoRecorderCurrentRecordedDurationSeconds:(double)seconds;
- (void)ziggeoRecorderPlaying;
- (void)ziggeoRecorderPaused;
- (void)ziggeoRecorderRerecord;
- (void)ziggeoRecorderManuallySubmitted;
- (void)ziggeoStreamingStarted;
- (void)ziggeoStreamingStopped;
- (void)preparingToUpload:(NSString * _Nonnull)path;
- (void)failedToUpload:(NSString * _Nonnull)path;
- (void)uploadStarted:(NSString * _Nonnull)path token:(NSString * _Nonnull)token streamToken:(NSString * _Nonnull)streamToken backgroundTask:(NSURLSessionTask * _Nonnull)backgroundTask;
- (void)uploadProgress:(NSString * _Nonnull)path token:(NSString * _Nonnull)token streamToken:(NSString * _Nonnull)streamToken totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;
- (void)uploadFinished:(NSString * _Nonnull)path token:(NSString * _Nonnull)token streamToken:(NSString * _Nonnull)streamToken;
- (void)uploadVerified:(NSString * _Nonnull)path token:(NSString * _Nonnull)token streamToken:(NSString * _Nonnull)streamToken response:(NSURLResponse * _Nullable)response error:(NSError * _Nullable)error json:(NSDictionary * _Nullable)json;
- (void)uploadProcessing:(NSString * _Nonnull)path token:(NSString * _Nonnull)token streamToken:(NSString * _Nonnull)streamToken;
- (void)uploadProcessed:(NSString * _Nonnull)path token:(NSString * _Nonnull)token streamToken:(NSString * _Nonnull)streamToken;
- (void)delete:(NSString * _Nonnull)token streamToken:(NSString * _Nonnull)streamToken response:(NSURLResponse * _Nullable)response error:(NSError * _Nullable)error json:(NSDictionary * _Nullable)json;
- (void)checkCameraPermission:(BOOL)granted;
- (void)checkMicrophonePermission:(BOOL)granted;
- (void)checkPhotoLibraryPermission:(BOOL)granted;
- (void)checkHasCamera:(BOOL)hasCamera;
- (void)checkHasMicrophone:(BOOL)hasMicrophone;
- (void)ziggeoPlayerPlaying;
- (void)ziggeoPlayerPaused;
- (void)ziggeoPlayerEnded;
- (void)ziggeoPlayerSeek:(double)positionMillis;
- (void)ziggeoPlayerReadyToPlay;
@end

@class AVPlayerItem;
@class IMAAdsLoader;
@class IMAAdsLoadedData;
@class IMAAdLoadingErrorData;
@class IMAAdsManager;
@class IMAAdEvent;
@class IMAAdError;

SWIFT_CLASS("_TtC20ZiggeoSwiftFramework12ZiggeoPlayer")
@interface ZiggeoPlayer : AVPlayer <IMAAdsLoaderDelegate, IMAAdsManagerDelegate>
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithPlayerItem:(AVPlayerItem * _Nullable)playerItem OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithURL:(NSURL * _Nonnull)url OBJC_DESIGNATED_INITIALIZER;
- (void)adsLoader:(IMAAdsLoader * _Null_unspecified)loader adsLoadedWithData:(IMAAdsLoadedData * _Null_unspecified)adsLoadedData;
- (void)adsLoader:(IMAAdsLoader * _Null_unspecified)loader failedWithErrorData:(IMAAdLoadingErrorData * _Null_unspecified)adErrorData;
- (void)adsManager:(IMAAdsManager * _Null_unspecified)adsManager didReceiveAdEvent:(IMAAdEvent * _Null_unspecified)event;
- (void)adsManager:(IMAAdsManager * _Null_unspecified)adsManager didReceiveAdError:(IMAAdError * _Null_unspecified)error;
- (void)adsManagerDidRequestContentPause:(IMAAdsManager * _Null_unspecified)adsManager;
- (void)adsManagerDidRequestContentResume:(IMAAdsManager * _Null_unspecified)adsManager;
@end

@protocol UIViewControllerTransitionCoordinator;
@class UIGestureRecognizer;
@class AVCaptureOutput;
@class AVCaptureConnection;
@class AVCaptureMetadataOutput;
@class AVMetadataObject;

SWIFT_CLASS("_TtC20ZiggeoSwiftFramework14ZiggeoRecorder") SWIFT_AVAILABILITY(maccatalyst,introduced=13.0)
@interface ZiggeoRecorder : UIViewController <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)viewDidLoad;
- (IBAction)onCloseButtonTap:(id _Nonnull)sender;
@property (nonatomic, readonly) BOOL shouldAutorotate;
@property (nonatomic, readonly) UIInterfaceOrientationMask supportedInterfaceOrientations;
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator> _Nonnull)coordinator;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;
- (void)observeValueForKeyPath:(NSString * _Nullable)keyPath ofObject:(id _Nullable)object change:(NSDictionary<NSKeyValueChangeKey, id> * _Nullable)change context:(void * _Nullable)context;
- (IBAction)changeCamera:(id _Nonnull)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer * _Nonnull)gestureRecognizer;
- (IBAction)toggleMovieRecording:(id _Nonnull)sender;
- (void)captureOutput:(AVCaptureOutput * _Nonnull)output didOutputSampleBuffer:(CMSampleBufferRef _Nonnull)sampleBuffer fromConnection:(AVCaptureConnection * _Nonnull)connection;
- (void)captureOutput:(AVCaptureMetadataOutput * _Nonnull)output didOutputMetadataObjects:(NSArray<AVMetadataObject *> * _Nonnull)metadataObjects fromConnection:(AVCaptureConnection * _Nonnull)connection;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil SWIFT_UNAVAILABLE;
@end


SWIFT_CLASS("_TtC20ZiggeoSwiftFramework33ZiggeoScreenRecorderSampleHandler") SWIFT_AVAILABILITY(maccatalyst,introduced=13.0) SWIFT_AVAILABILITY(ios,introduced=10.0)
@interface ZiggeoScreenRecorderSampleHandler : RPBroadcastSampleHandler
- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *, NSObject *> * _Nullable)setupInfo;
- (void)broadcastPaused;
- (void)broadcastResumed;
- (void)processSampleBuffer:(CMSampleBufferRef _Nonnull)sampleBuffer withType:(RPSampleBufferType)sampleBufferType;
- (void)broadcastFinished;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC20ZiggeoSwiftFramework22ZiggeoUploadingHandler")
@interface ZiggeoUploadingHandler : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#pragma clang diagnostic pop
#endif
