//
//  Live2DView.m
//  MurderMystery
//
//  Created by 李金柱 on 2021/2/22.
//  Copyright © 2021 YoKa. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Live2DView.h"
#import <GLKit/GLKit.h>
#import "ZQFacePoint.h"
#import "Live2DModelOpenGL.h"
#import "Live2dParamModel.h"
#import "CubismMatrix44.hpp"
#import "CubismViewMatrix.hpp"
#import "LAppDefine.h"
#import "TouchManager.h"
#import "LiveCubismVo.h"
#import "YKFacePoint.h"
#import <YKFaceSDK/YKFaceSDK.h>
#import "L2DCubism.h"

#define INTERVAL_SEC (1.0 / 20)

static CGFloat distance(CGPoint first, CGPoint second) {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX * deltaX + deltaY * deltaY);
}

static CGPoint centerPoint(CGPoint first, CGPoint second) {
    CGFloat deltaX = (second.x + first.x) / 2;
    CGFloat deltaY = (second.y + first.y) / 2;
    return CGPointMake(deltaX, deltaY);
}

static CGPoint lookAtPoint(CGPoint point, CGPoint zeroPoint) {
    CGFloat deltaX = point.x - zeroPoint.x;
    CGFloat deltaY = point.y - zeroPoint.y;
    CGFloat dist = sqrt(deltaX * deltaX + deltaY * deltaY);
    return CGPointMake(deltaX/dist, deltaY/dist);
}
@interface Live2DView ()<GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *contentView;

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, assign) CGFloat animationInterVal;

@property (nonatomic, strong) Live2DModelOpenGL *live2DModel;
@property (nonatomic, assign) NSTimeInterval lastFrame;
@property (nonatomic, copy,readwrite) NSString *loadedName;
@property (nonatomic, strong) YKFaceInfo *faceInfo;
@property (nonatomic, assign) BOOL brow;
@property (nonatomic, assign) BOOL browWorks;
@property (nonatomic, assign) BOOL resetModel;
@property (nonatomic, strong) NSMutableArray *msgArray;
@property (nonatomic, strong) NSMutableArray *extArray;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray *recCacheArray;
@property (nonatomic, assign) NSInteger countIndex;
@property (nonatomic, assign) NSInteger recordIndex;
@property (nonatomic) TouchManager *touchManager;
@property (nonatomic) Csm::CubismMatrix44 *deviceToScreen;
@property (nonatomic) Csm::CubismViewMatrix *viewMatrix;
@property (nonatomic, assign) BOOL openGLRun;
@property (nonatomic, assign) CGFloat lipValue;
@property (nonatomic, assign) CGFloat previousScale;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGes;
@property (nonatomic, strong) UIPanGestureRecognizer *panGes;
@property (nonatomic, strong) UIPanGestureRecognizer *bodyAngleZPanGes;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGes;
/**相机权限是否打开*/
@property (nonatomic, assign) BOOL captureAvalib;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, GLKTextureInfo *> *textureMap;
@property (nonatomic, strong) Live2dParamModel*lastParamModel;//当前数据参数模型
@property (nonatomic, strong) Live2dParamModel*lastOriParamModel;//当前原始数据参数模型
@property (nonatomic, strong) Live2dParamModel*firstOriParamModel;//首次原始数据参数模型
@property (nonatomic, strong) Live2dParamModel*firstParamModel;//首次数据参数模型
@property (nonatomic, assign) BOOL lastLostFace;//上一次丢失过人脸
@property (nonatomic, assign) NSInteger testIndex;
/**15个口型 对应的口型参数 sil,PP,FF,TH,DD,kk,CH,SS,nn,RR,aa,E,ih,oh,ou, 严格按照次顺序取值 index为key value为参数字符串 mf_mY*/
@property (nonatomic, strong) NSDictionary *visemesDic;
/**mf_mY*/
@property (nonatomic, strong) NSDictionary *lipDic;
@end

using namespace std;
using namespace LAppDefine;

@implementation Live2DView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [EAGLContext setCurrentContext:self.context];
    self.animationInterVal = 1.0/20.0;
    self.openGLRun = YES;
    self.countIndex = 0;
    self.previousScale = 1.0;
    self.zoom = 1;
    [self addObsever];
    self.textureMap = [[NSMutableDictionary alloc] init];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [EAGLContext setCurrentContext:self.context];
        self.animationInterVal = 1.0/20.0;
        self.openGLRun = YES;
        self.countIndex = 0;
        self.previousScale = 1.0;
        self.zoom = 1;
        [self addObsever];
        self.textureMap = [[NSMutableDictionary alloc] init];
//        // 触摸相关的事件管理
//        _touchManager = [[TouchManager alloc]init];
//        // 从设备坐标到屏幕坐标的转换
//        _deviceToScreen = new CubismMatrix44();
//        // 进行画面显示的放大缩小和移动变换的矩阵
//        _viewMatrix = new CubismViewMatrix();
        
    }
    return self;
}
- (void)addObsever{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationEnterBack:) name:UIApplicationDidEnterBackgroundNotification object:nil];

}
- (void)setOwner:(BOOL)owner{
    _owner = owner;
    if (owner) {
        self.captureAvalib = [MMAuthorizationHelper requestMediaCapturerAccessWithHandler:^(NSError * _Nullable error) {
         }];
    }
    [self resetDefultAnimationInterval];
}
- (void)applicationActive:(NSNotification *)noti{
    self.openGLRun = YES;
}
- (void)applicationEnterBack:(NSNotification *)noti{
    self.openGLRun = NO;
}
- (void)initializeScreen{
    self.backgroundColor = UIColor.clearColor;
    CGRect screenRect = self.contentView.frame;
    int width = screenRect.size.width;
    int height = screenRect.size.height;

    // 縦サイズを基準とする
    float ratio = static_cast<float>(width) / static_cast<float>(height);
    float left = -ratio;
    float right = ratio;
    float bottom = ViewLogicalLeft;
    float top = ViewLogicalRight;

    // 与设备相对应的画面范围。X的左端，X的右端，Y的下端，Y的上端
    _viewMatrix->SetScreenRect(left, right, bottom, top);
    _viewMatrix->Scale(ViewScale, ViewScale);

    _deviceToScreen->LoadIdentity(); // サイズが変わった際などリセット必須
    if (width > height)
    {
      float screenW = fabsf(right - left);
      _deviceToScreen->ScaleRelative(screenW / width, -screenW / width);
    }
    else
    {
      float screenH = fabsf(top - bottom);
      _deviceToScreen->ScaleRelative(screenH / height, -screenH / height);
    }
    _deviceToScreen->TranslateRelative(-width * 0.5f, -height * 0.5f);

    // 表示範囲の設定
    _viewMatrix->SetMaxScale(ViewMaxScale); // 限界拡大率
    _viewMatrix->SetMinScale(ViewMinScale); // 限界縮小率

    // 表示できる最大範囲
    _viewMatrix->SetMaxScreenRect(
                                  ViewLogicalMaxLeft,
                                  ViewLogicalMaxRight,
                                  ViewLogicalMaxBottom,
                                  ViewLogicalMaxTop
                                  );
}

- (void)setCurrentContext{
    [EAGLContext setCurrentContext:nil];
    [EAGLContext  setCurrentContext:self.context];
}
- (BOOL)isExist:(NSString *)str{
    return ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] != 0 && ![str isKindOfClass:[NSNull class]] && ![str isEqualToString: @"(null)"]);
}
- (void)loadModelWithName:(NSString *)name{
    NSLog(@"====name %@ ===",name);
    if (![self isExist:name]) return;
    bool initialzed = CubismFramework::IsInitialized();
    if (!initialzed) {
        [L2DCubism initializesdk];
    }
    self.hidden = NO;
    self.contentView.hidden = NO;
    self.iconImgView.hidden = YES;
    NSString *modelName = [NSString stringWithFormat:@"%@.model3.json",name];
    NSString *path = [NSFileManager pathForLive2dModelWithModelName:name];
    if (![self isExist:path]) return;
    [self releaseAllTexture];
    self.loadedName = name;
    NSString *modelPath = [path stringByAppendingFormat:@"/%@",modelName];
    self.live2DModel = [[Live2DModelOpenGL alloc]initWithJsonPath:modelPath textureMap:self.textureMap];
    [self updateFrame];
}

- (void)releaseAllTexture {
    NSTimeInterval before = NSDate.date.timeIntervalSince1970 * 1000;
    NSLog(@"context glContext delete texture count = [%p][%u]",
                      self.textureMap,
                      (unsigned int)self.textureMap.allKeys.count);
    [self.textureMap enumerateKeysAndObjectsUsingBlock:^(
                         NSNumber *_Nonnull key, GLKTextureInfo *_Nonnull obj, BOOL *_Nonnull stop) {
      GLuint textureName = obj.name;
        NSLog(@"context current delete texture = [%u]", (unsigned int)textureName);
      glDeleteTextures(1, &textureName);
    }];
    [self.textureMap removeAllObjects];
    NSTimeInterval after = NSDate.date.timeIntervalSince1970 * 1000;
    NSLog(@"Statistics Time Cost releaseAllTexture=[%u]", (unsigned int)(after - before));
}
- (void)resetDefultAnimationInterval{
    CGFloat defultInterVal = INTERVAL_SEC;
    if (defultInterVal != self.animationInterVal) {
        [self stopAnimatioTimer];
        self.animationInterVal = defultInterVal;
        [self startAnimation];
    }
}
- (void)startAnimation {
    if (!self.isAnimating) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationInterVal target:self selector:@selector(drawView) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.animationTimer forMode:NSRunLoopCommonModes];
        self.isAnimating = YES;
    }
    if([EAGLContext currentContext] != self.context) {
        [EAGLContext  setCurrentContext:self.context];
    }
}
- (void)stopAnimatioTimer{
    if (self.isAnimating) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        self.isAnimating = NO;
    }
}
- (void)stopAnimation {
    if (self.isAnimating) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        self.isAnimating = NO;
        self.loadedName = nil;
    }
}
- (void)pauseAnimation{
    if (self.isAnimating) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        self.isAnimating = NO;
    }
}
- (void)showContentView:(BOOL)show{
    self.contentView.hidden = !show;
}
- (void)resetOwnerStatus{
    self.resetModel = YES;
}
- (void)releaseView{
    [self releaseAllTexture];
    [self stopAnimation];
    self.live2DModel = nil;
    _contentView = nil;
    [L2DCubism dispose];
}
- (void)destroy{
    [self releaseAllTexture];
    [self stopAnimation];
    self.live2DModel = nil;
    _contentView = nil;
    [L2DCubism dispose];
}
- (void)setSendl2dData:(BOOL)sendl2dData{
    _sendl2dData = sendl2dData;
    self.countIndex  = 0;
}
- (void)setPositonInfoStr:(NSString *)positonInfoStr{
    _positonInfoStr = positonInfoStr;
    if ([self isExist:positonInfoStr]) {
        NSData *jsonData = [positonInfoStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *positionDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        self.zoom = [positionDic jsonDouble:@"zoom"];
        self.positionX = [positionDic jsonDouble:@"px"];
        self.positionY = [positionDic jsonDouble:@"py"];
    }
}
- (void)drawView {
    bool l2dClose = NO;//self.getL2dClose;
    if (l2dClose) {//低性能逻辑
        if (self.owner) {//模型拥有者 可以开始摄像头进行人脸识别
            if (self.resetModel) {//没有识别到人脸
                if (self.sendl2dData) {//生成没有人脸的数据
                    if (!self.msgArray.count) {
                        self.countIndex = 0;
                    }
                    Live2dParamModel *paramModel = [Live2dParamModel new];
                    paramModel.fl = YES;
                    paramModel.ls =  [NSString stringWithFormat:@"%.2f",self.lipValue];
                    NSString *mf_mYStr = self.visemesValue;//[self.visemesDic jsonString:[NSString stringWithFormat:@"%d",self.visemesIndex]];
                    paramModel.mf = [[mf_mYStr componentsSeparatedByString:@"_"]objectAtIndexCheck:0];
                    paramModel.mY = [[mf_mYStr componentsSeparatedByString:@"_"]objectAtIndexCheck:1];
                    [self.msgArray addObject:paramModel.mj_keyValues];
                }
            }else{
                [self makeFaceDataWithRefresh:NO];
            }
        }
        if (self.sendl2dData) {
            self.countIndex ++;
            if (self.countIndex/20) {
                [self sendL2dData];
                self.countIndex = 0;
            }
        }
        return;
    }
    
    bool initialzed = CubismFramework::IsInitialized();
    if (!initialzed) {
        return;
    }
    if (self.openGLRun) {
        [self.contentView display];
    }else{
        if (self.owner) {//模型拥有者 可以开始摄像头进行人脸识别
            if (self.resetModel) {//没有识别到人脸
                if (self.recording) {
                    Live2dParamModel *paramModel = [Live2dParamModel new];
                    paramModel.fl = YES;
                    [self.recordArray addObject:paramModel.mj_keyValues];
                }
                if (self.sendl2dData) {
                    if (!self.msgArray.count) {
                        self.countIndex = 0;
                    }
                    Live2dParamModel *paramModel = [Live2dParamModel new];
                    paramModel.fl = YES;
                    paramModel.ls =  [NSString stringWithFormat:@"%.2f",self.lipValue];
                    NSString *mf_mYStr = self.visemesValue;//[self.visemesDic jsonString:[NSString stringWithFormat:@"%d",self.visemesIndex]];
                    paramModel.mf = [[mf_mYStr componentsSeparatedByString:@"_"]objectAtIndexCheck:0];
                    paramModel.mY = [[mf_mYStr componentsSeparatedByString:@"_"]objectAtIndexCheck:1];
                    [self.msgArray addObject:paramModel.mj_keyValues];
                }
            }
        }
    }
    if (self.sendl2dData) {
        self.countIndex ++;
        if (self.countIndex/20) {
            [self sendL2dData];
            self.countIndex = 0;
        }
    }

}

- (void)setupSizeAndPosition{
    CGSize size = self.frame.size;
    CGFloat zoom = self.zoom ? self.zoom : 1;
    CGFloat scx = zoom;
    CGFloat scy = (size.width/size.height)*zoom;
    CGFloat x = self.positionX ? self.positionX : 0;
    CGFloat y = self.positionY ? self.positionY : 0;
    
    SCNMatrix4 matrix4 = {
        .m11 = static_cast<float>(scx), .m12 = 0.f, .m13 = 0.f, .m14 = 0.f,
        .m21 = 0.f, .m22 = static_cast<float>(scy), .m23 = 0.f, .m24 = 0.f,
        .m31 = 0.f, .m32 = 0.f, .m33 = 1.f, .m34 = 0.f,
        .m41 =  static_cast<float>(x), .m42 =  static_cast<float>(y),    .m43 =  0, .m44 = 1.f
    };
    [self.live2DModel setMatrix:matrix4];
//    float fMatrix[] = {
//        matrix4.m11, matrix4.m12, matrix4.m13, matrix4.m14,
//        matrix4.m21, matrix4.m22, matrix4.m23, matrix4.m24,
//        matrix4.m31, matrix4.m32, matrix4.m33, matrix4.m34,
//        matrix4.m41, matrix4.m42, matrix4.m43, matrix4.m44
//    };
//    _viewMatrix->SetMatrix(fMatrix);
}
- (NSTimeInterval )updateFrame{
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    NSTimeInterval delteTime = now - self.lastFrame;
    self.lastFrame = now;
    return delteTime;
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    self.iconImgView.frame = CGRectMake(0, self.height/9, self.width, self.height);
//    [self initializeScreen];
}

#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(0.0f, 0.0f,0.0f, 0.0f);
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT));
    
//    if (self.getL2dClose) return;

    bool initialzed = CubismFramework::IsInitialized();
    if (!_live2DModel||!initialzed) {
        return;
    }
    NSTimeInterval delta = [self updateFrame];
    [self.live2DModel updatePhysics:delta];
    if (self.openGLRun) {
        [self.live2DModel update];
    }
    if (self.owner) {//模型拥有者 可以开始摄像头进行人脸识别
        if (self.resetModel) {//没有识别到人脸
            if (self.shouldMakeFaceData) {//生成数据 自己的数据不展示 此时看的是他人 需要刷新他人的数据
                [self refreshExtModelWith:delta];
            }else{
                if ([self needSmoothReturnEvent]) {
                    [self smoothReturnAction];
                }else{
                    [self.live2DModel normalStateWith:delta];
                }
                //关闭唇同步参数 采用口型识别
//                self.live2DModel.lipSyncValue = self.lipValue;
                [self refreshMouthParam];
            }
            if (self.recording) {
                Live2dParamModel *paramModel = [Live2dParamModel new];
                paramModel.fl = YES;
                [self.recordArray addObject:paramModel.mj_keyValues];
            }
            if (self.sendl2dData) {//生成没有人脸的数据
                if (!self.msgArray.count) {
                    self.countIndex = 0;
                }
                Live2dParamModel *paramModel = [Live2dParamModel new];
                paramModel.fl = YES;
                paramModel.ls =  [NSString stringWithFormat:@"%.2f",self.lipValue];
                NSString *mf_mYStr = self.visemesValue;//[self.visemesDic jsonString:[NSString stringWithFormat:@"%d",self.visemesIndex]];
                paramModel.mf = [[mf_mYStr componentsSeparatedByString:@"_"]objectAtIndexCheck:0];
                paramModel.mY = [[mf_mYStr componentsSeparatedByString:@"_"]objectAtIndexCheck:1];
                [self.msgArray addObject:paramModel.mj_keyValues];
            }
        }else{//识别到人脸
            if (self.shouldMakeFaceData) {//生成数据 自己的数据不展示 此时看的是他人 需要刷新他人的数据
                [self makeFaceDataWithRefresh:NO];
                [self refreshExtModelWith:delta];
            }else{//生成数据并展示
                if (self.captureAvalib) {//摄像头可用
                    [self makeFaceDataWithRefresh:YES];
                }else{
                    [self.live2DModel normalStateWith:delta];
                }
            }
        }
        self.recordIndex = 0;

    }else{//非模型拥有者 观看
        if(self.recordPlaying){//是否是播放录制数据
            [self refreshWithRecordDataWith:delta];
        }else{
            self.recordIndex = 0;
            [self refreshExtModelWith:delta];
        }
    }
    if (self.openGLRun) {
        [self setupSizeAndPosition];
        [self.live2DModel draw];
    }
}

/**refresh 是否实时生效 实时展示效果就YES*/
- (void)makeFaceDataWithRefresh:(BOOL)refresh{
    if (self.faceInfo && self.faceInfo.landmark) {
        // 眼睛
        YKFacePoint *eyeLeftPoint = [YKFacePoint facePointForPosition:YKFacePositionLeftEye];
        YKFacePoint *eyeRightPoint = [YKFacePoint facePointForPosition:YKFacePositionRightEye];
        
        CGFloat l_eye_w = [self getPointDistance:eyeLeftPoint.left otherPoint:eyeLeftPoint.right];
        CGFloat l_eye_h = [self getPointDistance:eyeLeftPoint.top otherPoint:eyeLeftPoint.bottom];
        CGFloat l_eye_blink = l_eye_h / (l_eye_w * 0.42) - 0.1;
        l_eye_blink = MIN(MAX(0.0, l_eye_blink), 1.0);
        
        CGFloat r_eye_w = [self getPointDistance:eyeRightPoint.left otherPoint:eyeRightPoint.right];
        CGFloat r_eye_h = [self getPointDistance:eyeRightPoint.top otherPoint:eyeRightPoint.bottom];
        CGFloat r_eye_blink = r_eye_h / (r_eye_w * 0.42) - 0.1;
        r_eye_blink = MIN(MAX(0.0, r_eye_blink), 1.0);
        
        // 眉毛
        YKFacePoint *leftEyeBrowPoint = [YKFacePoint facePointForPosition:YKFacePositionLeftEyebrow];
        YKFacePoint *rightEyeBrowPoint = [YKFacePoint facePointForPosition:YKFacePositionRightEyebrow];
        CGFloat l_eye_brow_w = [self getPointDistance:leftEyeBrowPoint.left otherPoint:leftEyeBrowPoint.right];
        CGFloat l_eye_brow_h = [self getPointDistance:leftEyeBrowPoint.center otherPoint:eyeLeftPoint.center];
        CGFloat l_eye_brow = ((l_eye_brow_h - (l_eye_brow_w * 0.33)) / (l_eye_brow_w * 0.33))*2;
        l_eye_brow = MIN(MAX(-1.0, l_eye_brow), 1.0);

        CGFloat r_eye_brow_w = [self getPointDistance:rightEyeBrowPoint.left otherPoint:rightEyeBrowPoint.right];
        CGFloat r_eye_brow_h = [self getPointDistance:rightEyeBrowPoint.center otherPoint:eyeRightPoint.center];
        CGFloat r_eye_brow = ((r_eye_brow_h - (r_eye_brow_w * 0.33)) / (r_eye_brow_w * 0.33))*2;
        r_eye_brow = MIN(MAX(-1.0, r_eye_brow), 1.0);
        
        // 瞳孔
        YKFacePoint *leftEyeBallPoint = [YKFacePoint facePointForPosition:YKFacePositionLeftEyeBall];
        CGFloat l_eyeball_w = [self getPointDistance:leftEyeBallPoint.left otherPoint:leftEyeBallPoint.right];
        CGFloat l_eyeball_offset = [self getPointDistance:eyeLeftPoint.left otherPoint:leftEyeBallPoint.left];
        CGFloat l_e_x = (l_eyeball_offset / (l_eye_w - l_eyeball_w) - 0.5) * 2.0 * 1.2;
        l_e_x = MIN(MAX(-1.0, l_e_x), 1.0);
                
        // 嘴巴
        YKFacePoint *nosePoint = [YKFacePoint facePointForPosition:YKFacePositionNose];
        CGFloat nose_w = [self getPointDistance:nosePoint.left otherPoint:nosePoint.right];
        
        YKFacePoint *mousePoint = [YKFacePoint facePointForPosition:YKFacePositionMouth];
        CGFloat mouse_w = [self getPointDistance:mousePoint.left otherPoint:mousePoint.right];
        CGFloat mouse_h = [self getPointDistance:mousePoint.top otherPoint:mousePoint.bottom];
        CGFloat mouse_open = (mouse_h / (nose_w * 0.3)) * 0.3;
        CGFloat mouse_width_open = (mouse_w - nose_w * 1.20) / nose_w * 6.0;
        mouse_open = MIN(MAX(0.0, mouse_open), 1.0);
        mouse_width_open = MIN(MAX(-1.0, mouse_width_open), 1.0);
        
        Live2dParamModel *paramModel = [Live2dParamModel new];
        paramModel.hX = [NSString stringWithFormat:@"%.2f",-self.faceInfo.yaw / M_PI_2 * 180];
        paramModel.hY = [NSString stringWithFormat:@"%.2f",-self.faceInfo.pitch / M_PI_2 * 180];
        paramModel.hZ = [NSString stringWithFormat:@"%.2f",self.faceInfo.roll / M_PI_2 * 180];
        paramModel.eL = [NSString stringWithFormat:@"%.2f",r_eye_blink];
        paramModel.eR = [NSString stringWithFormat:@"%.2f",l_eye_blink];
        paramModel.eBx = [NSString stringWithFormat:@"%.2f",l_e_x];
        paramModel.eBy = [NSString stringWithFormat:@"%.2f",self.faceInfo.pitch];
        paramModel.bLy = [NSString stringWithFormat:@"%.2f",l_eye_brow];
        paramModel.bRy = [NSString stringWithFormat:@"%.2f",r_eye_brow];
        paramModel.mY  = [NSString stringWithFormat:@"%.2f",mouse_open];
        paramModel.mf  = [NSString stringWithFormat:@"%.2f",mouse_width_open];
        paramModel.fl = self.resetModel;

        if (refresh) {
            if (self.lastLostFace) {
                self.firstOriParamModel = [Live2dParamModel mj_objectWithKeyValues:paramModel.mj_keyValues];
                [self smoothAnimationAction];
            }else{
                self.lastParamModel = [Live2dParamModel mj_objectWithKeyValues:paramModel.mj_keyValues];
                self.lastOriParamModel = [Live2dParamModel mj_objectWithKeyValues:paramModel.mj_keyValues];
                
                // 头部转动
                [self.live2DModel setParam:@"ParamAngleX" value:-self.faceInfo.yaw / M_PI_2 * 180];
                [self.live2DModel setParam:@"ParamAngleY" value:-self.faceInfo.pitch / M_PI_2 * 180];
                [self.live2DModel setParam:@"ParamAngleZ" value:self.faceInfo.roll / M_PI_2 * 180];
                // 眼睛
                [self.live2DModel setParam:@"ParamEyeLOpen" value:l_eye_blink];
                [self.live2DModel setParam:@"ParamEyeROpen" value:r_eye_blink];
                // 眉毛
                [self.live2DModel setParam:@"ParamBrowLY" value:l_eye_brow];
                [self.live2DModel setParam:@"ParamBrowRY" value:r_eye_brow];
                // 瞳孔
                [self.live2DModel setParam:@"ParamEyeBallX" value:l_e_x];
                [self.live2DModel setParam:@"ParamEyeBallY" value:self.faceInfo.pitch];
                // 嘴巴
                [self.live2DModel setParam:@"ParamMouthOpenY" value:mouse_open];
                [self.live2DModel setParam:@"ParamMouthForm" value:mouse_width_open];
            }
            if (self.recording) {//录制数据
                [self.recordArray addObject:paramModel.mj_keyValues];
            }
        }
        
        if (!self.msgArray.count) {
            self.countIndex = 0;
        }
        if (self.sendl2dData) {
            [self.msgArray addObject:paramModel.mj_keyValues];
        }
    }
}

- (void)refreshExtModelWith:(CGFloat)delta{
    if (self.recCacheArray.count) {
        NSArray *currentArray = self.recCacheArray.firstObject;
//        NSLog(@"l2d===收到数据组数 %ld 处理数据个数 %ld",self.recCacheArray.count,currentArray.count);
        CGFloat currentInterVal = 1.0/MAX(currentArray.count, 10);
        if (currentInterVal != self.animationInterVal) {
            [self stopAnimatioTimer];
            self.animationInterVal = currentInterVal;
            [self startAnimation];
        }
        LiveCubismVo *paramModel  = [currentArray objectAtIndexCheck:self.index];
        self.index ++ ;
        if (self.index == currentArray.count) {
            self.index = 0;
            [self.recCacheArray removeObjectAtIndex:0];
        }
        if (!self.openGLRun) return;
//        NSLog(@"===%@===",paramModel.mj_keyValues);
        if (paramModel.fl) {
            self.lastLostFace = YES;
            if ([self needSmoothReturnEvent]) {
                [self smoothReturnAction];
            }else{
                self.live2DModel.mouthMY = paramModel.mY;
                self.live2DModel.mouthMf = paramModel.mf;

                [self.live2DModel normalStateWith:delta];
//                self.live2DModel.lipSyncValue = paramModel.ls;
            }
        }else{
            if (self.lastLostFace) {
                self.firstOriParamModel = [Live2dParamModel mj_objectWithKeyValues:paramModel.mj_keyValues];
                [self smoothAnimationAction];
            }else{
                self.lastParamModel = [Live2dParamModel mj_objectWithKeyValues:paramModel.mj_keyValues];
                self.lastOriParamModel = [Live2dParamModel mj_objectWithKeyValues:paramModel.mj_keyValues];
                [self.live2DModel setParam:@"ParamAngleX" value:paramModel.hX];
                [self.live2DModel setParam:@"ParamAngleY" value:paramModel.hY];
                [self.live2DModel setParam:@"ParamAngleZ" value:paramModel.hZ];
                [self.live2DModel setParam:@"ParamEyeLOpen" value:paramModel.eL];
                [self.live2DModel setParam:@"ParamEyeROpen" value:paramModel.eR];
                [self.live2DModel setParam:@"ParamEyeBallX" value:paramModel.eBx];
                [self.live2DModel setParam:@"ParamEyeBallY" value:paramModel.eBy];
                [self.live2DModel setParam:@"ParamBrowLY" value:paramModel.bLy];
                [self.live2DModel setParam:@"ParamBrowRY" value:paramModel.bRy];
                [self.live2DModel setParam:@"ParamMouthOpenY" value:paramModel.mY];
                [self.live2DModel setParam:@"ParamMouthForm" value:paramModel.mf];
            }
        }
      
    }else{
        if (self.showDefultStatus) {
            if (!self.openGLRun) return;
            if ([self needSmoothReturnEvent]) {
                [self smoothReturnAction];
            }else{
                [self resetDefultAnimationInterval];
                self.live2DModel.lipSyncValue = 0;
                [self.live2DModel normalStateWith:delta];
            }
        }
    }
}
- (void)refreshWithRecordDataWith:(CGFloat)delta{
    if (self.recordPlayingPause)return;
    if (self.recordArray.count) {
//        NSLog(@"录制数据个数 %ld  recordIndex %ld",self.recordArray.count,self.recordIndex);
        Live2dParamModel *paramModel  = [Live2dParamModel mj_objectWithKeyValues:[self.recordArray objectAtIndex:self.recordIndex]];
        self.recordIndex ++ ;
        if (self.recordIndex >= self.recordArray.count) {
            self.recordIndex = 0;
        }
        if (!self.openGLRun) {
            return;
        }
        if (paramModel.fl) {
            self.lastLostFace = YES;
            if ([self needSmoothReturnEvent]) {
                [self smoothReturnAction];
            }else{
                [self.live2DModel normalStateWith:delta];
            }
            return;
        }
        
        if (self.lastLostFace) {
            self.firstOriParamModel = [Live2dParamModel mj_objectWithKeyValues:paramModel.mj_keyValues];
            [self smoothAnimationAction];
        }else{
            self.lastParamModel = [Live2dParamModel mj_objectWithKeyValues:paramModel.mj_keyValues];
            self.lastOriParamModel = [Live2dParamModel mj_objectWithKeyValues:paramModel.mj_keyValues];
            
            [self.live2DModel setParam:@"ParamAngleX" value:paramModel.hX.floatValue];
            [self.live2DModel setParam:@"ParamAngleY" value:paramModel.hY.floatValue];
            [self.live2DModel setParam:@"ParamAngleZ" value:paramModel.hZ.floatValue];
            [self.live2DModel setParam:@"ParamEyeLOpen" value:paramModel.eL.floatValue];
            [self.live2DModel setParam:@"ParamEyeROpen" value:paramModel.eR.floatValue];
            [self.live2DModel setParam:@"ParamEyeBallX" value:paramModel.eBx.floatValue];
            [self.live2DModel setParam:@"ParamEyeBallY" value:paramModel.eBy.floatValue];
            [self.live2DModel setParam:@"ParamBrowLY" value:paramModel.bLy.floatValue];
            [self.live2DModel setParam:@"ParamBrowRY" value:paramModel.bRy.floatValue];
            [self.live2DModel setParam:@"ParamMouthOpenY" value:paramModel.mY.floatValue];
            [self.live2DModel setParam:@"ParamMouthForm" value:paramModel.mf.floatValue];
        }
    }else{
        if (!self.openGLRun) return;
        [self.live2DModel normalStateWith:delta];
    }
}

- (BOOL)needSmoothReturnEvent{
    if (self.lastParamModel.hX.floatValue || self.lastParamModel.hY.floatValue || self.lastParamModel.hZ.floatValue) {
        return YES;
    }
    return NO;
}

//有人脸到没有人脸过渡
- (void)smoothReturnAction{
    //0.5秒内恢复到默认
    NSInteger smoothTimes = 1/self.animationInterVal * 0.5;
    smoothTimes = MAX(1, smoothTimes);
    CGFloat smoothValueParamAngleX = self.lastOriParamModel.hX.floatValue/smoothTimes;
    CGFloat smoothValueParamAngleY = self.lastOriParamModel.hY.floatValue/smoothTimes;
    CGFloat smoothValueParamAngleZ = self.lastOriParamModel.hZ.floatValue/smoothTimes;
    
    //ParamAngleX
    CGFloat valueParamAngleXNew = self.lastParamModel.hX.floatValue - smoothValueParamAngleX;
    if (smoothValueParamAngleX >= 0) {//正值则减到负值归0
        if (valueParamAngleXNew <= 0) {
            valueParamAngleXNew = 0;
        }
    }else{
        if (valueParamAngleXNew >= 0) {
            valueParamAngleXNew = 0;
        }
    }
    self.lastParamModel.hX = [NSString stringWithFormat:@"%f",valueParamAngleXNew];
    [self.live2DModel setParam:@"ParamAngleX" value:valueParamAngleXNew];

    //ParamAngleY
    CGFloat valueParamAngleYNew = self.lastParamModel.hY.floatValue - smoothValueParamAngleY;
    if (smoothValueParamAngleY >= 0) {//正值则减到负值归0
        if (valueParamAngleYNew <= 0) {
            valueParamAngleYNew = 0;
        }
    }else{
        if (valueParamAngleYNew >= 0) {
            valueParamAngleYNew = 0;
        }
    }
    self.lastParamModel.hY = [NSString stringWithFormat:@"%f",valueParamAngleYNew];
    [self.live2DModel setParam:@"ParamAngleY" value:valueParamAngleYNew];

    //ParamAngleZ
    CGFloat valueParamAngleZNew = self.lastParamModel.hZ.floatValue - smoothValueParamAngleZ;
    if (smoothValueParamAngleZ >= 0) {//正值则减到负值归0
        if (valueParamAngleZNew <= 0) {
            valueParamAngleZNew = 0;
        }
    }else{
        if (valueParamAngleZNew >= 0) {
            valueParamAngleZNew = 0;
        }
    }
    self.lastParamModel.hZ = [NSString stringWithFormat:@"%f",valueParamAngleZNew];
    [self.live2DModel setParam:@"ParamAngleZ" value:valueParamAngleZNew];
    
    [self.live2DModel setParam:@"ParamEyeLOpen" value:1.0f];
    [self.live2DModel setParam:@"ParamEyeROpen" value:1.0f];
}
//没有人脸到人脸过渡
- (void)smoothAnimationAction{
    //0.3秒内过渡到识别
    NSInteger smoothTimes = 1/self.animationInterVal * 0.3;
    smoothTimes = MAX(1, smoothTimes);
    CGFloat smoothValueParamAngleX = self.firstOriParamModel.hX.floatValue/smoothTimes;
    CGFloat smoothValueParamAngleY = self.firstOriParamModel.hY.floatValue/smoothTimes;
    CGFloat smoothValueParamAngleZ = self.firstOriParamModel.hZ.floatValue/smoothTimes;
    
    //ParamAngleX
    CGFloat valueParamAngleXNew = self.firstParamModel.hX.floatValue + smoothValueParamAngleX;
    self.firstParamModel.hX = [NSString stringWithFormat:@"%f",valueParamAngleXNew];
    [self.live2DModel setParam:@"ParamAngleX" value:valueParamAngleXNew];

    //ParamAngleY
    CGFloat valueParamAngleYNew = self.firstParamModel.hY.floatValue + smoothValueParamAngleY;
    self.firstParamModel.hY = [NSString stringWithFormat:@"%f",valueParamAngleYNew];
    [self.live2DModel setParam:@"ParamAngleY" value:valueParamAngleYNew];

    //ParamAngleZ
    CGFloat valueParamAngleZNew = self.firstParamModel.hZ.floatValue + smoothValueParamAngleZ;
    self.firstParamModel.hZ = [NSString stringWithFormat:@"%f",valueParamAngleZNew];
    [self.live2DModel setParam:@"ParamAngleZ" value:valueParamAngleZNew];

    [self.live2DModel setParam:@"ParamEyeLOpen" value:1.0f];
    [self.live2DModel setParam:@"ParamEyeROpen" value:1.0f];
    
    if (smoothValueParamAngleX>=0) {
        if (valueParamAngleXNew >= self.firstOriParamModel.hX.floatValue) {
            self.lastLostFace = NO;
            self.firstParamModel = nil;
            self.firstOriParamModel = nil;
        }
    }else{
        if (valueParamAngleXNew <= self.firstOriParamModel.hX.floatValue) {
            self.lastLostFace = NO;
            self.firstParamModel = nil;
            self.firstOriParamModel = nil;
        }
    }
    
}
- (void)sendL2dData{
    if (!self.msgArray.count)return;
    if (self.sendDataWithDataArrayCallBack) {
        self.sendDataWithDataArrayCallBack([NSArray arrayWithArray:self.msgArray]);
    }
    [self.msgArray removeAllObjects];
}

- (void)resetBrow{
    self.browWorks = NO;
    bool initialzed = CubismFramework::IsInitialized();
    if (!initialzed) {
        return;
    }
    [self.live2DModel setParam:@"ParamBrowLY" value:0];
    [self.live2DModel setParam:@"ParamBrowRY" value:0];
}

- (void)refreshMouthParam{
    NSString *mf_mYStr = self.visemesValue;//[self.visemesDic jsonString:[NSString stringWithFormat:@"%d",self.visemesIndex]];
    NSString *mf = [[mf_mYStr componentsSeparatedByString:@"_"]objectAtIndexCheck:0];
    NSString *mY = [[mf_mYStr componentsSeparatedByString:@"_"]objectAtIndexCheck:1];
    [self.live2DModel setParam:@"ParamMouthOpenY" value:mY.floatValue];
    [self.live2DModel setParam:@"ParamMouthForm" value:mf.floatValue];
}

- (void)receiveMsgExtDataArray:(NSArray *)extArray{
    if (!extArray.count) return;
    [self.recCacheArray addObject:extArray];
}

- (void)lipSyncUpdateWithValue:(CGFloat)value{
    self.lipValue = value;
//    NSLog(@"lipValue:%f",value);
}
- (void)resetExtData{
    [self.recCacheArray removeAllObjects];
}
- (void)setParam:(NSString *)paramId value:(Float32)value{
    if (self.live2DModel) {
        [self.live2DModel setParam:paramId value:1];
    }
}
-(void)setDetectResult:(NSArray<YKFaceInfo *> *)detectResult {
    _detectResult = detectResult;
    if (!detectResult.count) {//未识别到
        self.resetModel = YES;
        self.lastLostFace = YES;
    }else{
        self.resetModel = NO;
        self.lipValue = 0;
    }
 
}
- (void)setFaceDetectionData:(YKFaceInfo *)faceDetectionReport {
    self.faceInfo = faceDetectionReport;
}

- (CGFloat)getPointDistance:(NSInteger)point otherPoint:(NSInteger)otherPoint {

    CGPoint pos1 = [self.faceInfo.landmark[point] CGPointValue];;
    CGPoint pos2 = [self.faceInfo.landmark[otherPoint] CGPointValue];
    CGFloat dist = distance(pos1, pos2);
    return dist;
}
- (void)setGesResponse:(BOOL)gesResponse{
    _gesResponse = gesResponse;
    if (gesResponse) {
        [self setupGestures];
    }else{
        self.userInteractionEnabled = NO;
    }
}
- (void)setBodyGesResponse:(BOOL)bodyGesResponse{
    _bodyGesResponse = bodyGesResponse;
    if (bodyGesResponse) {
        [self addGestureRecognizer:self.bodyAngleZPanGes];
    }else{
        [self removeGestureRecognizer:self.bodyAngleZPanGes];
    }
}
- (void)setupGestures {

    [self addGestureRecognizer:self.pinchGes];
    [self addGestureRecognizer:self.longPressGes];
    //双指移动
    [self addGestureRecognizer:self.panGes];
}
- (void)onBodyAngleZPanGes:(UIPanGestureRecognizer *)ges{
    CGPoint translation = [ges translationInView:ges.view];
    CGFloat relX = translation.x/self.width*20;
    NSLog(@"====%f===",relX);
    
    if (self.live2DModel) {
        [self.live2DModel setParam:@"ParamBodyAngleZ" value:relX];
    }
    switch (ges.state) {
        case UIGestureRecognizerStateEnded:
        {
            if (self.live2DModel) {
                [self.live2DModel setParam:@"ParamBodyAngleZ" value:0];
            }
        }
            break;
        default:
            break;
    }
}
- (void)onPan:(UIPanGestureRecognizer *)panGes{
    CGPoint translation = [panGes translationInView:panGes.view];
    CGFloat relX = translation.x/self.width*4;
    CGFloat relY = translation.y/self.height*4;
    [panGes setTranslation:CGPointMake(0, 0) inView:panGes.view];
    self.positionX += relX;
    self.positionY -= relY;
    NSLog(@"positionY----%f",self.positionY);
    switch (panGes.state) {
        case UIGestureRecognizerStateEnded:
        {
            if (self.gesEndCallBack) {
                self.gesEndCallBack();
            }
        }
            break;
            
        default:
            break;
    }
    
}
- (void)onLongpress:(UILongPressGestureRecognizer *)longpress{
}
- (void)onPitch:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.previousScale = 1.0f;
        if (self.gesEndCallBack) {
            self.gesEndCallBack();
        }
        return;
    }
    CGFloat scale = 1.0f - (self.previousScale - pinchGestureRecognizer.scale);
    if (scale > 1.0) {
        CGFloat  addZoom =  self.zoom + 0.05;
        self.zoom = MIN(addZoom, 3);
    }
    else if (scale < 1.0) {
        CGFloat  recZoom =  self.zoom - 0.05;
        self.zoom = MAX(recZoom, 0.5);
    }
    self.previousScale = pinchGestureRecognizer.scale;
}

//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = touches.anyObject;
//    CGPoint location = [touch locationInView:self];
//    CGPoint previousLocation = [touch previousLocationInView:self];
//    float deltaX = location.x - previousLocation.x;
//    float deltaY = location.y - previousLocation.y;
//
//    CGFloat relX = deltaX/self.width*4;
//    CGFloat relY = deltaY/self.height*4;
//
//    self.positionX += relX;
//    self.positionY -= relY;
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self.contentView];
//    [_touchManager touchesBegan:point.x DeciveY:point.y];
//    [self.live2DModel startRandomExpression];
//    self.testIndex ++;
//    self.testIndex = self.testIndex%4;
////    [self testBQAction];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self.contentView];
//
//    float viewX = [self transformViewX:[_touchManager getX]];
//    float viewY = [self transformViewY:[_touchManager getY]];
//
//    [_touchManager touchesMoved:point.x DeviceY:point.y];
//    [self.live2DModel onDrag:viewX*2 floatY:viewY*2];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    NSLog(@"%@", touch.view);
//    [self.live2DModel onDrag:0.0f floatY:0.0f];
//    {
//        // シングルタップ
//        float getX = [_touchManager getX];// 論理座標変換した座標を取得。
//        float getY = [_touchManager getY]; // 論理座標変換した座標を取得。
//        float x = _deviceToScreen->TransformX(getX);
//        float y = _deviceToScreen->TransformY(getY);
//        NSLog(@"[APP]touchesEnded x:%.2f y:%.2f", x, y);
//        [self.live2DModel onTap:x floatY:y];
//    }
//}
- (float)transformViewX:(float)deviceX
{
    float screenX = _deviceToScreen->TransformX(deviceX); // 論理座標変換した座標を取得。
    return _viewMatrix->InvertTransformX(screenX); // 拡大、縮小、移動後の値。
}

- (float)transformViewY:(float)deviceY
{
    float screenY = _deviceToScreen->TransformY(deviceY); // 論理座標変換した座標を取得。
    return _viewMatrix->InvertTransformY(screenY); // 拡大、縮小、移動後の値。
}

- (float)transformScreenX:(float)deviceX
{
    return _deviceToScreen->TransformX(deviceX);
}

- (float)transformScreenY:(float)deviceY
{
    return _deviceToScreen->TransformY(deviceY);
}

- (float)transformTapY:(float)deviceY
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int height = screenRect.size.height;
    return deviceY * -1 + height;
}
- (CGPoint)transformRectWithCenter:(CGPoint)center transform:(CGPoint)transform rect:(CGRect)rect{
    CGPoint point = CGPointZero;
    if (transform.x < rect.origin.x + rect.size.width && transform.y < rect.origin.y + rect.size.height && transform.x > rect.origin.x && transform.y > rect.origin.y) {
        return  transform;
    }
    CGFloat len_x = center.x  - transform.x;
    CGFloat len_y = center.y  - transform.y;
    
    CGFloat angleTarget = [self angleWithX:len_x y:len_y];
    
    if (transform.x < center.x) {
        angleTarget = 360 - angleTarget;
    }
    
    CGFloat angleLeftTop = 360 - [self angleWithX:rect.origin.x - center.x y:(rect.origin.y - center.y)*-1];
    CGFloat angleLeftBottom = 360 - [self angleWithX:rect.origin.x - center.x y:(rect.origin.y  + rect.size.height - center.y)*-1];
    CGFloat angleRightTop = [self angleWithX:rect.origin.x + rect.size.width - center.x y:(rect.origin.y - center.y)*-1];
    CGFloat angleRightBottom = [self angleWithX:rect.origin.x + rect.size.width - center.x y:(rect.origin.y  + rect.size.height - center.y)*-1];
    CGFloat scale = len_y/len_x;
    
    CGFloat x3 = 0;
    CGFloat y3 = 0;

    if (angleTarget < angleRightTop) {
        y3 = rect.origin.y - center.y;
        x3 = y3/scale;
        point = CGPointMake(center.x + x3,center.y + y3);
    }else if(angleTarget < angleRightBottom) {
        x3 = rect.origin.x  + rect.size.width - center.x;
        y3 = x3*scale;
        point = CGPointMake(center.x + x3,center.y + y3);
    }else if(angleTarget < angleLeftBottom) {
        y3 = rect.origin.y + rect.size.height - center.y;
        x3 = y3/scale;
        point = CGPointMake(center.x + x3,center.y + y3);
    }else if(angleTarget < angleLeftTop) {
        x3 = center.x - rect.origin.x;
        y3 = x3*scale;
        point = CGPointMake(center.x - x3,center.y - y3);
    }else {
        y3 = rect.origin.y - center.y;
        x3 = y3/scale;
        point = CGPointMake(center.x + x3,center.y + y3);
    }

    return point;
}
- (CGFloat)angleWithX:(CGFloat)len_x y:(CGFloat)len_y{
    CGFloat normalizeY = len_y/sqrt(len_x*len_x + len_y*len_y);
    return acos(normalizeY)*180/M_PI;
}
- (void)testRandomExpressions{
    self.testIndex ++;
    
    if (self.testIndex == 41) {
        self.testIndex = 0;
        [self.live2DModel startRandomExpression];
    }
}
- (void)testBQAction{
    NSInteger random = arc4random()%4+1;
    random = 3;
    
    self.testIndex ++;
    
    if (self.testIndex == 41) {
        self.testIndex = 0;
    }else if(self.testIndex > 10){
        return;
    }

    CGFloat value = 0.1f * (self.testIndex%10 + 1);
    NSLog(@"===bq %ld value:%f",random,value);

    [self.live2DModel setParam:[NSString stringWithFormat:@"ParamBQ%ld",random] value:value];
}
- (void)testParamExp{

    BOOL exp1 = self.testIndex + 1 == 1;
    BOOL exp2 = self.testIndex + 1 == 2;
    BOOL exp3 = self.testIndex + 1 == 3;
    BOOL exp4 = self.testIndex + 1 == 4;
    if (exp4) {
        [self.live2DModel setParam:@"ParamBQ1" value:0.0f];
        [self.live2DModel setParam:@"ParamBQ2" value:0.0f];
        [self.live2DModel setParam:@"ParamBQ3" value:0.0f];
        return;
    }

    [self.live2DModel setParam:@"ParamBQ1" value:exp1 ? 1.0f:0.0f];
    [self.live2DModel setParam:@"ParamBQ2" value:exp2 ? 1.0f:0.0f];
    [self.live2DModel setParam:@"ParamBQ3" value:exp3 ? 1.0f:0.0f];
    [self.live2DModel setParam:@"ParamBQ4" value:exp3 ? 1.0f:0.0f];

}
#pragma mark ---------lazy--------

- (NSMutableArray *)msgArray{
    if (!_msgArray) {
        _msgArray = [[NSMutableArray alloc]init];
    }
    return _msgArray;
}
- (NSMutableArray *)recCacheArray{
    if (!_recCacheArray) {
        _recCacheArray = [[NSMutableArray alloc]init];
    }
    return _recCacheArray;
}
- (GLKView *)contentView{
    if (!_contentView) {
        _contentView = [[GLKView alloc] init];
        _contentView.delegate = self;
        _contentView.backgroundColor = UIColor.clearColor;
        _contentView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        _contentView.context = self.context;
        [self addSubview:_contentView];
    }
    return _contentView;
}
- (EAGLContext *)context{
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return _context;
}

- (NSMutableArray *)recordArray{
    if (!_recordArray) {
        _recordArray = [[NSMutableArray alloc]init];
    }
    return _recordArray;
}
- (UIImageView *)iconImgView{
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc]init];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImgView.hidden = YES;
        [self addSubview:_iconImgView];
    }
    return _iconImgView;
}
- (UIPinchGestureRecognizer *)pinchGes{
    if (!_pinchGes) {
        _pinchGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPitch:)];
    }
    return _pinchGes;
}
- (UIPanGestureRecognizer *)panGes{
    if (!_panGes) {
        _panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPan:)];
        _panGes.minimumNumberOfTouches = 1;
        _panGes.maximumNumberOfTouches = 1;
    }
    return _panGes;
}
- (UIPanGestureRecognizer *)bodyAngleZPanGes{
    if (!_bodyAngleZPanGes) {
        _bodyAngleZPanGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onBodyAngleZPanGes:)];
        _bodyAngleZPanGes.minimumNumberOfTouches = 1;
        _bodyAngleZPanGes.maximumNumberOfTouches = 1;
    }
    return _bodyAngleZPanGes;
}
- (UILongPressGestureRecognizer *)longPressGes{
    if (!_longPressGes) {
        _longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongpress:)];
    }
    return _longPressGes;
}
- (Live2dParamModel *)firstParamModel{
    if (!_firstParamModel) {
        _firstParamModel = [[Live2dParamModel alloc]init];
    }
    return _firstParamModel;
}
- (NSDictionary *)visemesDic{
    /**15个口型 对应的口型参数 sil,PP,FF,TH,DD,kk,CH,SS,nn,RR,aa,E,ih,oh,ou, 严格按照顺序取值 index为key value为参数字符串 mf_mY*/
    return @{@"0":@"0_0",
             @"1":@"-0.9_0",
             @"2":@"-0.9_0.2",
             @"3":@"-0.9_0.5",
             @"4":@"-0.2_0.6",
             @"5":@"0.3_0.5",
             @"6":@"-0.7_0.6",
             @"7":@"0.3_0.2",
             @"8":@"-0.9_0.5",
             @"9":@"-0.8_0.3",
             @"10":@"0.2_0.5",
             @"11":@"0.7_0.3",
             @"12":@"0.8_0.3",
             @"13":@"-0.8_0.8",
             @"14":@"-0.8_0.5",
    };
}
- (NSDictionary *)lipDic{
    return @{@"B":@"0_0",
             @"F":@"-0.2_0.1",
             @"D":@"-0.9_0.2",
             @"A":@"-0.9_0.5",
             @"O":@"-0.2_0.6",
             @"E":@"0.3_0.5",
             @"U":@"-0.7_0.6",
             @"7":@"0.3_0.2",
             @"8":@"-0.9_0.5",
             @"9":@"-0.8_0.3",
             @"10":@"0.2_0.5",
             @"11":@"0.7_0.3",
             @"12":@"0.8_0.3",
             @"13":@"-0.8_0.8",
             @"14":@"-0.8_0.5",
    };
}
@end
