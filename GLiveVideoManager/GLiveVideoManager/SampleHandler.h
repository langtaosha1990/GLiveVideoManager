//
//  SampleHandler.h
//  ShowProject
//
//  Created by Gpf 郭 on 2024/3/21.
//

#import <ReplayKit/ReplayKit.h>

@protocol SampleHanderDelegate <NSObject>

- (void)sampleBufferCallBack:(CMSampleBufferRef)sampleBuffer;

@end

@interface SampleHandler : RPBroadcastSampleHandler
@property (nonatomic, weak) id<SampleHanderDelegate> delegate;
@end
