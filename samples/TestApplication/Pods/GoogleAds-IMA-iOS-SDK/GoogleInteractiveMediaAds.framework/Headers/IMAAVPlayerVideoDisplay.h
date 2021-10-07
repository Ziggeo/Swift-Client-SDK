//
//  IMAAVPlayerVideoDisplay.h
//  GoogleIMA3
//
//  Copyright (c) 2013 Google Inc. All rights reserved.
//
//  Declares an object that reuses an AVPlayer for both content and ad playback

#import <UIKit/UIKit.h>

#import "IMAVideoDisplay.h"

@class AVPlayer;
@class AVPlayerItem;
@class AVURLAsset;
@class IMAAVPlayerVideoDisplay;

/**
 *  The key for subtitle language.
 */
extern NSString *const kIMASubtitleLanguage;

/**
 *  The key for the WebVTT sidecar subtitle URL.
 */
extern NSString *const kIMASubtitleWebVTT;

/**
 *  The key for the TTML sidecar subtitle URL.
 */
extern NSString *const kIMASubtitleTTML;

/**
 *  A callback protocol for IMAAVPlayerVideoDisplayDelegate.
 */
@protocol IMAAVPlayerVideoDisplayDelegate<NSObject>

@optional

/**
 *  Called when the IMAAVPlayerVideoDisplay will load a stream for playback. Allows the publisher to
 *  register the AVURLAsset for Fairplay content protection before playback starts.
 *
 *  @param playerVideoDisplay the IMAVPlayerVideoDisplay that will load the AVURLAsset.
 *  @param URLAsset           the AVURLAsset representing the stream to be loaded.
 */
- (void)playerVideoDisplay:(IMAAVPlayerVideoDisplay *)playerVideoDisplay
       willLoadStreamAsset:(AVURLAsset *)URLAsset;

/**
 * Called when the <code>IMAAVPlayerVideoDisplay</code> has at least partially loaded media for
 * playback and the player item is loaded. Only called for dynamic ad insertion.
 */
- (void)playerVideoDisplay:(IMAAVPlayerVideoDisplay *)playerVideoDisplay
         didLoadPlayerItem:(AVPlayerItem *)playerItem;

@end

/**
 *  An implementation of the IMAVideoDisplay protocol. This object is intended
 *  to be initialized with the content player, and will reuse the player for
 *  playing ads.
 */
@interface IMAAVPlayerVideoDisplay : NSObject <IMAVideoDisplay>

/**
 *  The content player used for both content and ad video playback.
 */
@property(nonatomic, strong, readonly) AVPlayer *player DEPRECATED_MSG_ATTRIBUTE(
    "Use the player passed into initWithAVPlayer: instead.");

/**
 *  The player item that will be played by the player. Access to the player item is provided
 *  so the item can be seeked, to select subtitles, and to inspect media attributes.
 */
@property(nonatomic, strong, readonly) AVPlayerItem *playerItem DEPRECATED_MSG_ATTRIBUTE(
    "Use playerVideoDisplay:didLoadPlayerItem: instead.");

/**
 *  Allows the publisher to receive IMAAVPlayerVideoDisplay specific events.
 */
@property(nonatomic, weak) id<IMAAVPlayerVideoDisplayDelegate> playerVideoDisplayDelegate;

/**
 *  The subtitles for the current stream. Will be nil until the stream starts playing.
 */
@property(nonatomic, strong, readonly) NSArray *subtitles;

/**
 *  Creates an IMAAVPlayerVideoDisplay that will play ads in the passed in
 *  content player.
 *
 *  @param player the AVPlayer instance used for playing content
 *
 *  @return an IMAAVPlayerVideoDisplay instance
 */
- (instancetype)initWithAVPlayer:(AVPlayer *)player;

/**
 * :nodoc:
 */
- (instancetype)init NS_UNAVAILABLE;

@end
