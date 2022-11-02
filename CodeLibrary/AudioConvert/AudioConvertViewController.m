//
//  AudioConvertViewController.m
//  CodeLibrary
//
//  Created by lijinzhu on 2022/11/2.
//  Copyright © 2022 李金柱. All rights reserved.
//

#import "AudioConvertViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ExtAudioConverter.h"
#import "MMPlayerManager.h"

@interface AudioConvertViewController ()
{
    dispatch_queue_t _playerManagerQueue;
}
@end

@implementation AudioConvertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self convertAction];
}
- (void)convertAction{
    //m4a 文件合并
    [self composeAudioAction];
    
    [self convertM4aToAACWithPath:[[NSBundle mainBundle]pathForResource:@"12" ofType:@"m4a"]];
    
    [self convertWavToM4aWithFilePath:[[NSBundle mainBundle]pathForResource:@"input" ofType:@"wav"]];

    [self convertPCMToWavWithFilePath:[[NSBundle mainBundle]pathForResource:@"4" ofType:@"pcm"]];
    
    [MMPlayerManager.shareManager encodePCM2MP3:[[NSBundle mainBundle]pathForResource:@"4" ofType:@"pcm"] outPutFile:^(NSString * _Nonnull mp3FilePath, NSData * _Nonnull outData) {
        NSLog(@"mp3 Path:%@",mp3FilePath);
    }];
    
}
- (void)composeAudioAction{
    NSString *audio1 = [[NSBundle mainBundle]pathForResource:@"12" ofType:@"m4a"];
    NSString *audio2 = [[NSBundle mainBundle]pathForResource:@"13" ofType:@"m4a"];
    NSString *outPath =  [[self convertTempDirectory]  stringByAppendingPathComponent:@"compose.m4a"];
    AVURLAsset *audioAsset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audio1]];
    AVURLAsset *audioAsset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audio2]];
    AVMutableComposition *composition = [AVMutableComposition composition];
    // 音频通道
    AVMutableCompositionTrack *audioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    AVMutableCompositionTrack *audioTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    AVAssetTrack *audioAssetTrack1 = [[audioAsset1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVAssetTrack *audioAssetTrack2 = [[audioAsset2 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [audioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset1.duration) ofTrack:audioAssetTrack1 atTime:kCMTimeZero error:nil];
    [audioTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset2.duration) ofTrack:audioAssetTrack2 atTime:kCMTimeZero error:nil];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    NSString *outPutFilePath = outPath;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outPutFilePath error:nil];
    }
    NSLog(@"---%@",[session supportedFileTypes]);
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    session.outputFileType = AVFileTypeAppleM4A; //与上述的`present`相对应
    session.shouldOptimizeForNetworkUse = YES;   //优化网络
    [session exportAsynchronouslyWithCompletionHandler:^{
        if (session.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"合并成功----%@", outPutFilePath);
        }else if (session.status == AVAssetExportSessionStatusFailed){
            NSLog(@"合并失败！");
        }
    }];
}
- (void)convertWavToM4aWithFilePath:(NSString *)filePath{
    NSString *outPath = [NSString stringWithFormat:@"%@/wav2m4a.m4a",[self convertTempDirectory]];
    [[NSFileManager defaultManager]removeItemAtPath:outPath error:nil];
    ExtAudioConverter* converter = [[ExtAudioConverter alloc] init];
    converter.outputFormatID = kAudioFormatMPEG4AAC;
    converter.outputFileType = kAudioFileM4AType;
    converter.inputFile =  filePath;
    converter.outputFile = outPath;
    [converter convert];
}
- (void)convertM4aToAACWithPath:(NSString *)filePath{
    NSString *outPath = [NSString stringWithFormat:@"%@/m4a2aac.aac",[self convertTempDirectory]];
    ExtAudioConverter* converter = [[ExtAudioConverter alloc] init];
    converter.outputFormatID = kAudioFormatMPEG4AAC;
    converter.outputFileType = kAudioFileAAC_ADTSType;
    converter.inputFile =  filePath;
    converter.outputFile = outPath;
    BOOL suc = [converter convert];
    NSLog(@"录制%@",suc ? @"成功" :@"失败");
}
- (void)convertPCMToWavWithFilePath:(NSString *)filePath{
    NSString *wavFilePath = [NSString stringWithFormat:@"%@/pcm2wav.wav",[self convertTempDirectory]];;  //wav文件的路径
    if(![[NSFileManager defaultManager]fileExistsAtPath:wavFilePath]){
        [[NSFileManager defaultManager]createFileAtPath:wavFilePath contents:nil attributes:nil];
    }
    FILE *fout;
    short NumChannels = 2;       //录音通道数
    short BitsPerSample = 16;    //线性采样位数
    int SamplingRate = 44100;     //录音采样率(Hz)
    int numOfSamples = (int)[[NSData dataWithContentsOfFile:filePath] length];
    
    int ByteRate = NumChannels*BitsPerSample*SamplingRate/8;
    short BlockAlign = NumChannels*BitsPerSample/8;
    int DataSize = NumChannels*numOfSamples*BitsPerSample/8;
    int chunkSize = 16;
    int totalSize = 46 + DataSize;
    short audioFormat = 1;
    
    if((fout = fopen([wavFilePath cStringUsingEncoding:1], "w")) == NULL)
    {
        printf("Error opening out file ");
    }
    
    fwrite("RIFF", sizeof(char), 4,fout);
    fwrite(&totalSize, sizeof(int), 1, fout);
    fwrite("WAVE", sizeof(char), 4, fout);
    fwrite("fmt ", sizeof(char), 4, fout);
    fwrite(&chunkSize, sizeof(int),1,fout);
    fwrite(&audioFormat, sizeof(short), 1, fout);
    fwrite(&NumChannels, sizeof(short),1,fout);
    fwrite(&SamplingRate, sizeof(int), 1, fout);
    fwrite(&ByteRate, sizeof(int), 1, fout);
    fwrite(&BlockAlign, sizeof(short), 1, fout);
    fwrite(&BitsPerSample, sizeof(short), 1, fout);
    fwrite("data", sizeof(char), 4, fout);
    fwrite(&DataSize, sizeof(int), 1, fout);
    
    fclose(fout);
    
    NSMutableData *pamdata = [NSMutableData dataWithContentsOfFile:filePath];
    NSFileHandle *handle;
    handle = [NSFileHandle fileHandleForUpdatingAtPath:wavFilePath];
    [handle seekToEndOfFile];
    [handle writeData:pamdata];
    [handle closeFile];

}

- (NSString *)convertTempDirectory{
    NSString *path = [NSString stringWithFormat:@"%@/convertTemp",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]];
    NSLog(@"File path: %@", path);
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return path;
}

@end
