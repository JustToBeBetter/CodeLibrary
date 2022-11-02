//
//  MMPlayerManager.m
//  Created by 李金柱 on 2021/3/11.
//  Copyright © 2021 YoKa. All rights reserved.
//

#import "MMPlayerManager.h"
#import "lame.h"

@interface MMPlayerManager ()<AVAudioPlayerDelegate,AVAudioRecorderDelegate>
{
    dispatch_queue_t _playerManagerQueue;

}
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) AVAudioRecorder *recorder;

@property (nonatomic, copy) NSString *recordPath;

@property (nonatomic, strong) void (^completeBlock)(CGFloat time);

@property (nonatomic, strong) NSTimer *progressTimer;

@property (nonatomic, assign) CGFloat maxDuration;
@property (nonatomic, strong) UIImageView *imgAnimation;

@end

@implementation MMPlayerManager

+ (instancetype)shareManager
{
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MMPlayerManager alloc]init];
    });
    return instance;
}
- (instancetype)init
{
    if (self = [super init]) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    return self;
}

#pragma mark ---------AVAudioPlayer--------

- (void)playAudioWithData:(NSData *)data imgAnimation:(UIImageView *)imgAnimation completion:(void (^)(NSError * _Nullable))completon {
    self.imgAnimation = imgAnimation;
    [self playAudioWithData:data completion:completon];
}

- (void)playAudioWithAudioUrl:(NSString *)audioUrl imgAnimation:(UIImageView *)imgAnimation completion:(void (^)(NSError * _Nullable))completon {
    self.imgAnimation = imgAnimation;
    [self playAudioWithAudioUrl:audioUrl completion:completon];
}

- (void)playAudioWithData:(NSData*)data
               completion:(nonnull void (^)(NSError * _Nullable))completion{
    
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer.delegate = nil;
        self.audioPlayer = nil;
    }
    
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    if (error || !self.audioPlayer) {
        self.audioPlayer = nil;
        error = [NSError errorWithDomain:@"播放器初始化失败，请稍后重试" code:-2 userInfo:nil];
        !completion ? : completion(error);
        return;
    }
    self.audioPlayer.numberOfLoops = 0;//设置不循环
    self.audioPlayer.volume = 1.0;
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];//加载音频文件到缓存
    [self.audioPlayer play];
    !completion ? : completion(nil);

}
- (void)playAudioWithAudioUrl:(NSString *)audioUrl
                   completion:(nonnull void (^)(NSError * _Nullable))completion{
    
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer.delegate = nil;
        self.audioPlayer = nil;
    }
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:audioUrl] error:&error];
    if (error || !self.audioPlayer) {
        self.audioPlayer = nil;
        error = [NSError errorWithDomain:@"播放器初始化失败，请稍后重试" code:-1 userInfo:nil];
        !completion ? : completion(error);
        return;
    }
    
    self.audioPlayer.numberOfLoops = 0;//设置不循环
    self.audioPlayer.volume = 1.0;
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];//加载音频文件到缓存
    [self.audioPlayer play];
    !completion ? : completion(nil);
    [self startProgressTimer];

}
- (void)play{
    [self.audioPlayer play];
    [self startProgressTimer];
}
- (void)pause{
    [self.audioPlayer pause];
    [self stopProgressTimer];
}
- (void)stopPlay{
    [self.audioPlayer stop];
    [self stopProgressTimer];
    [self.imgAnimation stopAnimating];
}
- (void)startProgressTimer{
//    WEAKSELF
//    self.progressTimer = [NSTimer bk_scheduledTimerWithTimeInterval:1/30.0f block:^(NSTimer *timer) {
//        NSLog(@"currentTime %f durtion %f",weakSelf.audioPlayer.currentTime,weakSelf.audioPlayer.duration);
//    } repeats:YES];
}

- (void)stopProgressTimer{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

#pragma mark ---------AVAudioPlayerDelegate--------

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    !self.audioPlayerDidFinishPlayingCallBack ? : self.audioPlayerDidFinishPlayingCallBack(player,flag);
    [self stopProgressTimer];
}

#pragma mark ---------AVAudioRecorder--------

- (void)startRecordWithFilePath:(NSString *)filePath completeBlock:(void (^)(CGFloat))complete{
    self.recordPath = filePath;
    self.completeBlock = complete;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    if (self.recorder) {
        [self.recorder stop];
        self.recorder.delegate = nil;
        self.recorder = nil;
    }
    [self.recorder prepareToRecord];
    [self.recorder recordForDuration:15];

}
- (void)startRecordWithFilePath:(NSString *)filePath maxDuration:(CGFloat)maxDuration completeBlock:(void (^)(CGFloat))complete{
    self.recordPath = filePath;
    self.completeBlock = complete;
    self.maxDuration = maxDuration;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    if (self.recorder) {
        [self.recorder stop];
        self.recorder.delegate = nil;
        self.recorder = nil;
    }
    [self.recorder prepareToRecord];
    [self.recorder recordForDuration:maxDuration];
    
}
- (void)stopRecording
{
    CGFloat time = self.recorder.currentTime;
    [self.recorder stop];
    if (self.completeBlock) {
        self.completeBlock(time);
        self.completeBlock = nil;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    self.maxDuration = 0;
}

- (void)cancelRecording
{
    [self.recorder stop];
    self.maxDuration = 0;
    self.completeBlock = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

#pragma mark ---------AVAudioRecorderDelegate--------

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        NSLog(@"录音成功");
        if (self.completeBlock) {
            if (self.maxDuration) {
                self.completeBlock(self.maxDuration);
            }else{
                self.completeBlock(15);
            }
            self.completeBlock = nil;
        }
    }else{
        NSLog(@"录制失败请重试");
    }
}


- (void)encodePCM2MP3:(NSString *)pcmFilePath outPutFile:(void (^)(NSString *mp3FilePath, NSData *outData))callBack{
    NSAssert(callBack != nil, @"");
    typeof(self) __weak weakSelf = self;;
    [self inSerialQueue:^{
    NSString *cafFilePath = pcmFilePath;
    NSMutableString *mp3FilePath = [NSMutableString stringWithString:pcmFilePath];
    [mp3FilePath replaceCharactersInRange:NSMakeRange(mp3FilePath.length-3, 3) withString:@"mp3"];
    NSLog(@"mp3FilePath : [%@]", mp3FilePath);
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:mp3FilePath]) {
        if([fileManager removeItemAtPath:mp3FilePath error:nil]){
            NSLog(@"删除原MP3文件失败");
        }
    }
    
    @try {
        int read, write;
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSData *mp3AudioData = [NSData dataWithContentsOfFile:mp3FilePath];
        [weakSelf inMainQueue:^{
            callBack(mp3FilePath, mp3AudioData);
        }];
    }
    }];
}
- (void)inSerialQueue:(dispatch_block_t)task{
    
    _playerManagerQueue = dispatch_queue_create("com.yoka.playerManager", DISPATCH_QUEUE_SERIAL);
    dispatch_async(_playerManagerQueue, ^{
        task();
    });
}
- (void)inMainQueue:(dispatch_block_t)task{
    dispatch_async(dispatch_get_main_queue(), ^{
        task();
    });
}

#pragma mark ---------lazy--------

- (AVAudioRecorder *)recorder
{
    if (_recorder == nil) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        
        if(session == nil){
            NSLog(@"Error creating session: %@", [sessionError description]);
            return nil;
        }
        else {
            [session setActive:YES error:nil];
        }
        
        // 设置录音的一些参数
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[AVFormatIDKey] = @(kAudioFormatLinearPCM);              // 音频格式
        setting[AVSampleRateKey] = @(44100);                            // 录音采样率(Hz)
        setting[AVNumberOfChannelsKey] = @(2);                          // 音频通道数 1 或 2
//        setting[AVLinearPCMBitDepthKey] = @(8);                         // 线性音频的位深度
        setting[AVEncoderAudioQualityKey] = [NSNumber numberWithInt:AVAudioQualityMax];        //录音的质量
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.recordPath] settings:setting error:NULL];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
    }
    return _recorder;
}
@end
