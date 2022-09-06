#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class SelfieSegmentation;


@protocol SelfieSegmentationDelegate <NSObject>

- (void)selfieSegmentation:(SelfieSegmentation*)selfieSegmentation didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end


@interface SelfieSegmentation : NSObject

@property (weak, nonatomic) id <SelfieSegmentationDelegate> delegate;

- (instancetype)init;
- (void)startGraph;
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer;

@end
