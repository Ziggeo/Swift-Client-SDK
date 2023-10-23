#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@class SelfieSegmentation;


@protocol SelfieSegmentationDelegate <NSObject>

- (void)selfieSegmentation:(SelfieSegmentation*)selfieSegmentation didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer cmTime:(CMTime)cmTime;

@end


@interface SelfieSegmentation : NSObject

@property (weak, nonatomic) id <SelfieSegmentationDelegate> delegate;

- (instancetype)init;
- (void)startGraph;
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer cmTime:(CMTime)cmTime;

@end
