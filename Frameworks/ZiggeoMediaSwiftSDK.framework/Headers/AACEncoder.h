//
//  AACEncoder.h
//  CameraTest
//
//  Created by alex on 12/03/2017.
//  Copyright © 2017 alex. All rights reserved.
//

#ifndef AACEncoder_h
#define AACEncoder_h

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>

@protocol AACEncoderDelegate <NSObject>
//-(void) compressedAudioDataReceived:(CMSampleBufferRef) sampleBuffer;
-(void) compressedAudioDataReceived:(NSData* _Nonnull) data asc:(NSData* _Nonnull)asc pts:(CMTime)pts;
@end

@interface AACEncoder : NSObject
-(id) initWithSampleRate:(int)sampleRate channels:(int)channels bitrate:(int)bitrate;
-(void) putCMSampleBuffer:(CMSampleBufferRef) sampleBuffer;
@property (weak, nonatomic) id<AACEncoderDelegate> delegate;
@end


#endif /* AACEncoder_h */
