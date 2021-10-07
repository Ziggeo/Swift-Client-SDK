#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** A list of purposes for which an obstruction would be registered as friendly. */
typedef NS_ENUM(NSUInteger, IMAFriendlyObstructionPurpose) {
  IMAFriendlyObstructionPurposeMediaControls,
  IMAFriendlyObstructionPurposeCloseAd,
  IMAFriendlyObstructionPurposeNotVisible,
  IMAFriendlyObstructionPurposeOther,
};

/** An obstruction that is marked as "friendly" for viewability measurement purposes.  */
@interface IMAFriendlyObstruction : NSObject

/** The view causing the obstruction. */
@property(nonatomic, readonly) UIView *view;

/** The purpose for registering the obstruction as friendly. */
@property(nonatomic, readonly) IMAFriendlyObstructionPurpose purpose;

/** Optional, detailed reasoning for registering this obstruction as friendly. */
@property(nonatomic, readonly, nullable) NSString *detailedReason;

/**
 * Initializes a friendly obstruction.
 *
 * @param view The view causing the obstruction.
 * @param purpose The purpose for registering the obstruction as friendly.
 * @param detailedReason Optional, detailed reasoning for registering this obstruction as friendly.
 *
 * @return A new IMAFriendlyObstruction instance
 */
- (instancetype)initWithView:(UIView *)view
                     purpose:(IMAFriendlyObstructionPurpose)purpose
              detailedReason:(nullable NSString *)detailedReason;

@end

NS_ASSUME_NONNULL_END
