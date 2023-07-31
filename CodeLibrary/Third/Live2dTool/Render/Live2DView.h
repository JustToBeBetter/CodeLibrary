//
//  Live2DView.h
//  MurderMystery
//
//  Created by 李金柱 on 2021/2/22.
//  Copyright © 2021 YoKa. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MNNFaceDetectionReport;
@class YKFaceInfo;

@interface Live2DView : UIView

/**是否可以手势转动头部*/
@property (nonatomic, assign) BOOL bodyGesResponse;
/**是否可以手势缩放移动*/
@property (nonatomic, assign) BOOL gesResponse;
/**模型x坐标点 默认0*/
@property (nonatomic, assign) CGFloat positionX;
/**模型y坐标点 默认0*/
@property (nonatomic, assign) CGFloat positionY;
/**模型放大倍数 默认值为1倍*/
@property (nonatomic, assign) CGFloat zoom;
/**yes 人脸捕捉生效 no 人脸捕捉失效*/
@property (nonatomic, assign) BOOL owner;
/**生产脸部数据 应用场景 展示的是别人的形象 但是发送自己的脸部数据*/
@property (nonatomic, assign) BOOL shouldMakeFaceData;
/**是否是正在录制*/
@property (nonatomic, assign) BOOL recording;
/**是否是正在播放录制*/
@property (nonatomic, assign) BOOL recordPlaying;
/**是否是播放录制暂停*/
@property (nonatomic, assign) BOOL recordPlayingPause;
/**是否发送数据*/
@property (nonatomic, assign) BOOL sendl2dData;
/**是否展示默认状态动画*/
@property (nonatomic, assign) BOOL showDefultStatus;
/**已经加载的模型名字*/
@property (nonatomic, copy,readonly) NSString *loadedName;
/**录制数据*/
@property (nonatomic, strong) NSMutableArray *recordArray;
/**手势操作回调*/
@property (nonatomic, copy) void (^gesEndCallBack)(void);
/**位置信息*/
@property (nonatomic, copy) NSString *positonInfoStr;
/**发数据*/
@property (nonatomic, copy) void (^sendDataWithDataArrayCallBack)(NSArray *dataArray);

@property (nonatomic, copy) NSString *chatroomId;

@property (nonatomic, strong) NSArray<YKFaceInfo*> *detectResult;

@property (nonatomic, strong) UIImageView *iconImgView;
/**口型索引*/
@property (nonatomic, assign) int visemesIndex;

@property (nonatomic, copy) NSString *visemesValue;

- (void)setCurrentContext;

- (void)setFaceDetectionData:(YKFaceInfo *)faceDetectionReport;

- (void)loadModelWithName:(NSString *)name;

- (void)startAnimation;
/**结束会重置已加载的形象名*/
- (void)stopAnimation;

- (void)pauseAnimation;

- (void)showContentView:(BOOL)show;

- (void)resetOwnerStatus;

- (void)releaseView;

- (void)destroy;

- (void)receiveMsgExtDataArray:(NSArray *)extArray;

- (void)lipSyncUpdateWithValue:(CGFloat)value;

- (void)resetExtData;

- (void)setParam:(NSString *)paramId value:(Float32)value;

@end

NS_ASSUME_NONNULL_END
