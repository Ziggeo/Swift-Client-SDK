#import <Foundation/Foundation.h>

/** An object that holds data corresponding to the companion ad. */
@interface IMACompanionAd : NSObject

/** The value for the resource of this companion. */
@property(nullable, nonatomic, copy, readonly) NSString *resourceValue;

/** The API needed to execute this ad, or nil if unavailable. */
@property(nullable, nonatomic, copy, readonly) NSString *APIFramework;

/** The width of the companion in pixels. 0 if unavailable. */
@property(nonatomic, readonly) NSInteger width;

/** The height of the companion in pixels. 0 if unavailable. */
@property(nonatomic, readonly) NSInteger height;

/**
 * Obtain an instance from <code>IMAAd.companionAds</code>.
 * :nodoc:
 */
- (nullable instancetype)init NS_UNAVAILABLE;

@end
