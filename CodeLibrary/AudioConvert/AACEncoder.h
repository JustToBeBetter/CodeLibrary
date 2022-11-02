//
//  AACEncoder.h
//  PCMtoAAC
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
NS_ASSUME_NONNULL_BEGIN

@interface AACEncoder : NSObject
@property (nonatomic) dispatch_queue_t encoderQueue;
@property (nonatomic) dispatch_queue_t callbackQueue;

- (void)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer isFinalEncode:(BOOL)isFinalEncode completionBlock:(void (^)(NSData * encodedData, NSError* error,BOOL isComplete))completionBlock;
@end

NS_ASSUME_NONNULL_END
