//
//  IMAAdDisplayContainer.h
//  GoogleIMA3
//
//  Copyright (c) 2014 Google Inc. All rights reserved.
//
//  Declares the IMAAdDisplayContainer interface that manages the views,
//  ad slots, and displays used for ad playback.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IMACompanionAdSlot;
@class IMAFriendlyObstruction;

/**
 * The IMAAdDisplayContainer is responsible for managing the ad container view and companion ad
 * slots used for ad playback.
 */
@interface IMAAdDisplayContainer : NSObject

/**
 * View containing the video display and ad related UI. This view must be present in the view
 * hierarchy in order to make ad or stream requests.
 */
@property(nonatomic, readonly) UIView *adContainer;

/** List of companion ad slots. Can be nil or empty. */
@property(nonatomic, readonly, nullable) NSArray<IMACompanionAdSlot *> *companionSlots;

/**
 * Initializes IMAAdDisplayContainer for rendering the ad and displaying the ad UI without any
 * companion slots.
 *
 * @param adContainer The view where the ad will be rendered. Fills the view's bounds.
 *
 * @return A new IMAAdDisplayContainer instance
 */
- (instancetype)initWithAdContainer:(UIView *)adContainer;

/**
 * Initializes IMAAdDisplayContainer for rendering the ad and displaying the ad UI.
 *
 * @param adContainer    The view where the ad will be rendered. Fills the view's bounds.
 * @param companionSlots The array of IMACompanionAdSlots. Can be nil or empty.
 *
 * @return A new IMAAdDisplayContainer instance
 */
- (instancetype)initWithAdContainer:(UIView *)adContainer
                     companionSlots:(nullable NSArray<IMACompanionAdSlot *> *)companionSlots;

/** :nodoc: */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Registers a view that overlays or obstructs this container as "friendly" for viewability
 * measurement purposes.
 *
 * See <a
 * href="https://developers.google.com/interactive-media-ads/docs/sdks/ios/omsdk">Open Measurement
 * in the IMA SDK</a> for guidance on what is and what is not allowed to be registered.
 *
 * @param friendlyObstruction An obstruction to be marked as "friendly" until unregistered.
 */
- (void)registerFriendlyObstruction:(IMAFriendlyObstruction *)friendlyObstruction;

/** Unregisters all previously registered friendly obstructions. */
- (void)unregisterAllFriendlyObstructions;

/** :nodoc: */
- (void)registerVideoControlsOverlay:(UIView *)videoControlsOverlay
    DEPRECATED_MSG_ATTRIBUTE("Use registerFriendlyObstruction: instead.");

/** :nodoc: */
- (void)unregisterAllVideoControlsOverlays DEPRECATED_MSG_ATTRIBUTE(
    "Use unregisterAllFriendlyObstructions: instead.");

@end

NS_ASSUME_NONNULL_END
