//
//  SampleHandler.m
//  ShowProject
//
//  Created by Gpf 郭 on 2024/3/21.
//


#import "SampleHandler.h"
#import "LFLiveSession.h"
#import <UIKit/UIKit.h>

@interface SampleHandler ()<LFLiveSessionDelegate>
@property (nonatomic, strong) LFLiveSession * lfLiveSession;

@property (nonatomic, strong) NSUserDefaults *sharedUserDefaults;
@end

@implementation SampleHandler

#define RTMPUrlKey @"RTMPUrl"
#define GroupKey @"group.gpf.test.demo.group"

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    
    NSString * rtmpUrl = [self.sharedUserDefaults objectForKey:RTMPUrlKey];

    self.sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:GroupKey];
    [self.sharedUserDefaults setObject:@"0x0001" forKey:@"SharedData"];
    
    LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
    stream.url = rtmpUrl;
    [self lfLiveSession];
    [self.lfLiveSession startLive:stream];
    self.lfLiveSession.delegate = self;
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
}


- (void)broadcastAnnotatedWithApplicationInfo:(NSDictionary *)applicationInfo
{
    NSString * bundleId = applicationInfo[RPApplicationInfoBundleIdentifierKey];
    if(bundleId) {
        NSLog(@"当前应用的bundleId：%@", bundleId);
    }
}

- (void)liveSession:(LFLiveSession *)session liveStateDidChange:(LFLiveState)state
{
    BOOL LinkState = NO;
    [self.sharedUserDefaults setObject:@"0" forKey:@"LinkStatus"];
    [self log:[NSString stringWithFormat:@"连接状态回调：%ld", state]];
    NSLog(@"liveStateDidChange: %ld", state);
    switch (state) {
    case LFLiveReady:
            NSLog(@"未连接");
            LinkState = NO;
        break;
    case LFLivePending:
            NSLog(@"连接中");
            LinkState = NO;
        break;
    case LFLiveStart:
            NSLog(@"已连接");
            LinkState = YES;
        break;
    case LFLiveError:
            NSLog(@"连接错误");
            LinkState = NO;
        break;
    case LFLiveStop:
            NSLog(@"未连接");
            LinkState = NO;
        break;
    default:
        break;
    }
    [self.sharedUserDefaults setObject:LinkState?@"1":@"0" forKey:@"LinkStatus"];
}


- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            [self.lfLiveSession captureOutputPixelBuffer:CMSampleBufferGetImageBuffer(sampleBuffer)];
            break;
        case RPSampleBufferTypeAudioApp:
            [self.lfLiveSession captureOutputAudioData:sampleBuffer];
            break;
        case RPSampleBufferTypeAudioMic:
            [self.lfLiveSession captureOutputAudioData:sampleBuffer];
            break;
        default:
            break;
    }
}

- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo
{

}
/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode
{
    
}




- (void)showAlert
{

}

static NSUInteger frameIndex = 0;
- (void)log:(NSString *)str
{
    NSString *existingData = [self.sharedUserDefaults objectForKey:@"SharedData"];
    str = [str stringByAppendingFormat:@"%---ld", frameIndex];
    frameIndex++;
    NSString *combinedData = [existingData stringByAppendingString:[str stringByAppendingString:@"\n"]];
    
    [self.sharedUserDefaults setObject:combinedData forKey:@"SharedData"];
    [self.sharedUserDefaults synchronize];
}

// 获取当前设备的方向
- (UIInterfaceOrientation)currentDeviceOrientation {
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
    if ([UIDevice currentDevice].orientation != UIDeviceOrientationUnknown) {
        orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    }
    return orientation;
}

- (LFLiveSession *)lfLiveSession
{
    if (!_lfLiveSession) {
        LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
        if([self currentDeviceOrientation] == UIInterfaceOrientationPortrait || [self currentDeviceOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
            videoConfiguration.videoSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        } else {
            
            videoConfiguration.videoSize = CGSizeMake(UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width);
        }
        
        videoConfiguration.videoBitRate = 1024*1024;
        videoConfiguration.videoMaxBitRate = 1024*1024;
        videoConfiguration.videoMinBitRate = 500*1024;
        videoConfiguration.videoFrameRate = 24;
        videoConfiguration.videoMaxKeyframeInterval = 48;
        UIInterfaceOrientation currentOrientation = [self currentDeviceOrientation];
        videoConfiguration.outputImageOrientation = currentOrientation;
        videoConfiguration.autorotate = YES;
        videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
        
        LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
        audioConfiguration.numberOfChannels = 1;
        audioConfiguration.audioBitrate = LFLiveAudioBitRate_64Kbps;
        audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
        
        
        _lfLiveSession = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration captureType:LFLiveCaptureDefaultMask];

        _lfLiveSession.delegate = self;
        _lfLiveSession.showDebugInfo = NO;
    }
    return _lfLiveSession;
}

- (void)dealloc
{
    [self.sharedUserDefaults setObject:nil forKey:RTMPUrlKey];
    [self.sharedUserDefaults setObject:nil forKey:GroupKey];
}

@end
