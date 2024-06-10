//
//  LiveStreamer.h
//  CameraTest
//
//  Created by alex on 26/03/2017.
//  Copyright © 2017 alex. All rights reserved.
//

#ifndef LiveStreamer_h
#define LiveStreamer_h

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

@protocol LiveStreamerDelegate
-(void) onPublishStart;
-(void) onPublishStop;
-(void) onError:(NSString* _Nonnull)description;
@end

@interface LiveStreamer : NSObject
-(id) initWithTargetAddress:(NSString *)address streamName:(NSString *)streamName;
-(void) putVideoSample:(CMSampleBufferRef)sampleBuffer;
-(void) putAudioSample:(NSData*)data asc:(NSData*)asc pts:(CMTime)pts;
-(void) stop;
@property (weak, nonatomic) id<LiveStreamerDelegate> delegate;
@end


#endif /* LiveStreamer_h */
