//
//  Live2DModelOpenGL.m
//  MurderMystery
//
//  Created by 李金柱 on 2021/2/22.
//  Copyright © 2021 YoKa. All rights reserved.
//

#import "Live2DModelOpenGL.h"
#import "CubismModelSettingJson.hpp"
#import "CubismUserModel.hpp"
#import "CubismRenderer_OpenGLES2.hpp"
#import "CubismIdManager.hpp"
#import "CubismPhysics.hpp"
#import "LAppPal.h"
#import "LAppDefine.h"
#import "CubismString.hpp"
#import "ACubismMotion.hpp"
#import "CubismMotion.hpp"
#import "CubismDefaultParameterId.hpp"
#import <GLKit/GLKit.h>

using namespace Live2D::Cubism::Framework;
using namespace Live2D::Cubism::Core;


#pragma mark - Allocator class

class Allocator : public Csm::ICubismAllocator
{
    void* Allocate(const Csm::csmSizeType size) {
        return malloc(size);
    }
    
    void Deallocate(void* memory) {
        free(memory);
    }
    
    void* AllocateAligned(const Csm::csmSizeType size, const Csm::csmUint32 alignment) {
        size_t offset, shift, alignedAddress;
        void* allocation;
        void** preamble;

        offset = alignment - 1 + sizeof(void*);

        allocation = Allocate(size + static_cast<csmUint32>(offset));

        alignedAddress = reinterpret_cast<size_t>(allocation) + sizeof(void*);

        shift = alignedAddress % alignment;

        if (shift)
        {
            alignedAddress += (alignment - shift);
        }

        preamble = reinterpret_cast<void**>(alignedAddress);
        preamble[-1] = allocation;

        return reinterpret_cast<void*>(alignedAddress);
    }
    
    void DeallocateAligned(void* alignedMemory){
        void** preamble;

        preamble = static_cast<void**>(alignedMemory);

        Deallocate(preamble[-1]);
    }
};

#pragma mark - Live2DCubism class

static Allocator _allocator;

@implementation Live2DCubism
+ (void)initL2D {
    Csm::CubismFramework::StartUp(&_allocator, NULL);
    Csm::CubismFramework::Initialize();
}

+ (void)dispose {
    Csm::CubismFramework::Dispose();
}

+ (NSString *)live2DVersion {
    unsigned int version = csmGetVersion();
    unsigned int major = (version >> 24) & 0xff;
    unsigned int minor = (version >> 16) & 0xff;
    unsigned int patch = version & 0xffff;

    return [NSString stringWithFormat:@"v%1$d.%2$d.%3$d", major, minor, patch];
}
@end

#pragma mark - Live2DModelOpenGL class


@interface Live2DModelOpenGL ()
{
    const Csm::CubismId* _idParamAngleX; ///< パラメータID: ParamAngleX
    const Csm::CubismId* _idParamAngleY; ///< パラメータID: ParamAngleX
    const Csm::CubismId* _idParamAngleZ; ///< パラメータID: ParamAngleX
    const Csm::CubismId* _idParamBodyAngleX; ///< パラメータID: ParamBodyAngleX
    const Csm::CubismId* _idParamBodyAngleY; ///< パラメータID: ParamBodyAngleY
    const Csm::CubismId* _idParamBodyAngleZ; ///< パラメータID: ParamBodyAngleZ
    const Csm::CubismId* _idParamEyeBallX; ///< パラメータID: ParamEyeBallX
    const Csm::CubismId* _idParamEyeBallY; ///< パラメータID: ParamEyeBallXY
    CubismEyeBlink  *_eyeBlink;
    CubismBreath    *_breath;
    csmFloat32  _dragX;                   ///< マウスドラッグのX位置
    csmFloat32  _dragY;                   ///< マウスドラッグのY位置
}
@property (nonatomic, assign) CubismUserModel *userModel;
@property (nonatomic, strong) NSURL *baseUrl;
@property (nonatomic, assign) CubismPhysics *physics;
@property (nonatomic, assign) ICubismModelSetting *modelSetting;
@property (nonatomic, assign) Csm::csmMap<Csm::csmString, Csm::ACubismMotion*>expressions;
@property (nonatomic, assign) Csm::csmVector<Csm::CubismIdHandle> eyeBlinkIds;//在模型中设置的眨眼功能参数ID
@property (nonatomic, assign) Csm::csmVector<Csm::CubismIdHandle> lipSyncIds;//在模型中设置的用于口型功能的参数ID
@property (nonatomic, assign) Csm::csmMap<Csm::csmString, Csm::ACubismMotion*>motions;//正在读取的动作列表
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, GLKTextureInfo *> *textureMap;

@end

@implementation Live2DModelOpenGL

- (instancetype)init{
    if (self = [super init]) {
        
        _idParamAngleX = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamAngleX);
        _idParamAngleY = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamAngleY);
        _idParamAngleZ = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamAngleZ);
        _idParamBodyAngleX = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamBodyAngleX);
        _idParamBodyAngleY = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamBodyAngleY);
        _idParamBodyAngleZ = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamBodyAngleZ);
        _idParamEyeBallX = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamEyeBallX);
        _idParamEyeBallY = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamEyeBallY);
    }
    return self;
}

- (instancetype)initWithJsonPath:(NSString *)jsonPath textureMap:(NSMutableDictionary *)textureMap{
    if (self = [super init]) {
        self.textureMap = textureMap;
        _idParamAngleX = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamAngleX);
        _idParamAngleY = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamAngleY);
        _idParamAngleZ = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamAngleZ);
        _idParamBodyAngleX = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamBodyAngleX);
        _idParamBodyAngleY = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamBodyAngleY);
        _idParamBodyAngleZ = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamBodyAngleZ);
        _idParamEyeBallX = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamEyeBallX);
        _idParamEyeBallY = CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamEyeBallY);
        
        NSURL *url = [NSURL fileURLWithPath:jsonPath];
        NSData *jsonData = [NSData dataWithContentsOfURL:url];
    
        csmByte* settingBuffer;
        csmSizeInt settingSize;
        
        NSUInteger settingLen = [jsonData length];
        Byte *settingByteData = (Byte*)malloc(settingLen);
        memcpy(settingByteData, [jsonData bytes], settingLen);

        settingSize = static_cast<Csm::csmSizeInt>(settingLen);
        settingBuffer = static_cast<Csm::csmByte*>(settingByteData);
        
        _modelSetting = new CubismModelSettingJson(settingBuffer, settingSize);
        
        free(settingBuffer);
        //[url URLByDeletingLastPathComponent];
        
        NSString* baseUrlStr= [url.absoluteString stringByReplacingOccurrencesOfString:url.lastPathComponent withString:@""];
        _baseUrl = [NSURL fileURLWithPath:baseUrlStr];

        url = [_baseUrl URLByAppendingPathComponent:[NSString stringWithUTF8String:_modelSetting->GetModelFileName()]];

        NSData *data = [NSData dataWithContentsOfURL:url];
    
        csmByte* modelBuffer;
        csmSizeInt modelSize;
        
        NSUInteger modelLen = [data length];
        Byte *modelByteData = (Byte*)malloc(modelLen);
        memcpy(modelByteData, [data bytes], modelLen);

        modelSize = static_cast<Csm::csmSizeInt>(modelLen);
        modelBuffer = static_cast<Csm::csmByte*>(modelByteData);
        
        
        _userModel = new CubismUserModel();
        _userModel->LoadModel(modelBuffer, modelSize);
        free(modelBuffer);
        
        [self setupModel];
        _userModel->CreateRenderer();
        [self setupTextres];
    }
    return self;
}
- (void)loadModelWithPath:(NSString *)path{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];

    if (_userModel!=NULL) {
        delete _userModel;
    }
    _modelSetting = new CubismModelSettingJson((const unsigned char *)[jsonData bytes], (unsigned int)[jsonData length]);
    _baseUrl = [url URLByDeletingLastPathComponent];

    url = [_baseUrl URLByAppendingPathComponent:[NSString stringWithUTF8String:_modelSetting->GetModelFileName()]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    _userModel = new CubismUserModel();
    _userModel->LoadModel((const unsigned char *)[data bytes], (unsigned int)[data length]);
    [self setupModel];
    
    _userModel->DeleteRenderer();
    _userModel->CreateRenderer();
    _userModel->GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->Initialize(_userModel->GetModel());
 
    [self setupTextres];
}
- (void)setupModel{
    
    csmByte* buffer;
    csmSizeInt size;

    //Physics
   if (strcmp(_modelSetting->GetPhysicsFileName(), "") != 0)
   {
       NSURL* url = [_baseUrl URLByAppendingPathComponent:[NSString stringWithUTF8String:_modelSetting->GetPhysicsFileName()]];
       NSData *data = [NSData dataWithContentsOfURL:url];
       if (data){
           NSUInteger len = [data length];
           Byte *byteData = (Byte*)malloc(len);
           memcpy(byteData, [data bytes], len);

           size = static_cast<Csm::csmSizeInt>(len);
           buffer = static_cast<Csm::csmByte*>(byteData);
           _physics = CubismPhysics::Create(buffer, size);
           free(buffer);
       }
   }
   //EyeBlink
   if (_modelSetting->GetEyeBlinkParameterCount() > 0)
   {
       _eyeBlink = CubismEyeBlink::Create(_modelSetting);
   }
   //Breath
   {
       _breath = CubismBreath::Create();
       csmVector<CubismBreath::BreathParameterData> breathParameters;

       breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamAngleX, 0.0f, 15.0f, 6.5345f, 0.5f));
       breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamAngleY, 0.0f, 8.0f, 3.5345f, 0.5f));
       breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamAngleZ, 0.0f, 10.0f, 5.5345f, 0.5f));
       breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamBodyAngleX, 0.0f, 4.0f, 15.5345f, 0.5f));
       breathParameters.PushBack(CubismBreath::BreathParameterData(CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamBreath), 0.5f, 0.5f, 3.2345f, 0.5f));
       _breath->SetParameters(breathParameters);
   }

   //Expression
   if (_modelSetting->GetExpressionCount() > 0)
   {
       const csmInt32 count = _modelSetting->GetExpressionCount();
       for (csmInt32 i = 0; i < count; i++)
       {
           csmString name = _modelSetting->GetExpressionName(i);
           csmString path = _modelSetting->GetExpressionFileName(i);
           NSURL* url = [_baseUrl URLByAppendingPathComponent:[NSString stringWithUTF8String:_modelSetting->GetExpressionFileName(i)]];
           NSData *data = [NSData dataWithContentsOfURL:url];
           if (data){
               NSUInteger len = [data length];
               Byte *byteData = (Byte*)malloc(len);
               memcpy(byteData, [data bytes], len);

               size = static_cast<Csm::csmSizeInt>(len);
               buffer = static_cast<Csm::csmByte*>(byteData);
               
               ACubismMotion* motion =_userModel->LoadExpression(buffer, size, name.GetRawString());
               if (_expressions[name] != NULL)
               {
                   ACubismMotion::Delete(_expressions[name]);
                   _expressions[name] = NULL;
               }
               _expressions[name] = motion;
               free(buffer);
           };
      
       }
   }
   
   //Pose
   if (strcmp(_modelSetting->GetPoseFileName(), "") != 0)
   {
       csmString path = _modelSetting->GetPoseFileName();
       NSURL* url = [_baseUrl URLByAppendingPathComponent:[NSString stringWithUTF8String:_modelSetting->GetPoseFileName()]];
       NSData *data = [NSData dataWithContentsOfURL:url];
       if (data) {
           
           NSUInteger len = [data length];
           Byte *byteData = (Byte*)malloc(len);
           memcpy(byteData, [data bytes], len);

           size = static_cast<Csm::csmSizeInt>(len);
           buffer = static_cast<Csm::csmByte*>(byteData);
           
           _userModel->LoadPose(buffer, size);
           LAppPal::ReleaseBytes(buffer);
       };
       if (LAppDefine::DebugLogEnable)
       {
           LAppPal::PrintLog("[APP]delete buffer: %s",path.GetRawString());
       }
   }
   
   //UserData
   if (strcmp(_modelSetting->GetUserDataFile(), "") != 0)
   {
       csmString path = _modelSetting->GetUserDataFile();
       NSURL* url = [_baseUrl URLByAppendingPathComponent:[NSString stringWithUTF8String:_modelSetting->GetUserDataFile()]];
       NSData *data = [NSData dataWithContentsOfURL:url];
       if (data) {
           NSUInteger len = [data length];
           Byte *byteData = (Byte*)malloc(len);
           memcpy(byteData, [data bytes], len);

           size = static_cast<Csm::csmSizeInt>(len);
           buffer = static_cast<Csm::csmByte*>(byteData);
           _userModel->LoadUserData(buffer, size);
           
           free(buffer);
       }
       if (LAppDefine::DebugLogEnable)
       {
           LAppPal::PrintLog("[APP]delete buffer: %s",path.GetRawString());
       }
   }

   // EyeBlinkIds
   {
       csmInt32 eyeBlinkIdCount = _modelSetting->GetEyeBlinkParameterCount();
       for (csmInt32 i = 0; i < eyeBlinkIdCount; ++i)
       {
           _eyeBlinkIds.PushBack(_modelSetting->GetEyeBlinkParameterId(i));
       }
   }

   // LipSyncIds
   {
       csmInt32 lipSyncIdCount = _modelSetting->GetLipSyncParameterCount();
       for (csmInt32 i = 0; i < lipSyncIdCount; ++i)
       {
           _lipSyncIds.PushBack(_modelSetting->GetLipSyncParameterId(i));
       }
   }
    
   for (csmInt32 i = 0; i < _modelSetting->GetMotionGroupCount(); i++)
   {
       const csmChar* group = _modelSetting->GetMotionGroupName(i);
       [self preloadMotionGroup:group];
   }
}

- (void)setupTextres{
    for (int i = 0; i < [self getNumberOfTextures]; ++i) {
        NSURL* url = [_baseUrl URLByAppendingPathComponent:[NSString stringWithUTF8String:_modelSetting->GetTextureFileName(i)]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (!data) {
            return;
        }
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfURL:url options:@{ GLKTextureLoaderApplyPremultiplication: @(NO), GLKTextureLoaderGenerateMipmaps: @(YES) } error:nil];
        if (!textureInfo) {
            return;
        }
        int textureNumber = textureInfo.name;
        [self setTexture:i to:textureNumber];
        self.textureMap[@(textureNumber)] = textureInfo;
    }
    BOOL isPremultipliedAlpha = IOS_VERSION < 14.0f;
    [self setPremultipliedAlpha:isPremultipliedAlpha];
}

- (void)preloadMotionGroup:(const csmChar*)group{
    const csmInt32 count = _modelSetting->GetMotionCount(group);

    for (csmInt32 i = 0; i < count; i++)
    {
        //ex) idle_0
        csmString name = Utils::CubismString::GetFormatedString("%s_%d", group, i);
        csmString path = _modelSetting->GetMotionFileName(group, i);
        NSURL* url = [_baseUrl URLByAppendingPathComponent:[NSString stringWithUTF8String:_modelSetting->GetMotionFileName(group, i)]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (LAppDefine::DebugLogEnable)
        {
            LAppPal::PrintLog("[APP]load motion: %s => [%s_%d] ", path.GetRawString(), group, i);
        }
        if (!data) {
            continue;
        }
        csmByte* buffer;
        csmSizeInt size;
        
        NSUInteger len = [data length];
        Byte *byteData = (Byte*)malloc(len);
        memcpy(byteData, [data bytes], len);

        size = static_cast<Csm::csmSizeInt>(len);
        buffer = static_cast<Csm::csmByte*>(byteData);
        
        CubismMotion* tmpMotion = static_cast<CubismMotion*>(_userModel->LoadMotion(buffer, size, name.GetRawString()));

        csmFloat32 fadeTime = _modelSetting->GetMotionFadeInTimeValue(group, i);
        if (fadeTime >= 0.0f)
        {
            tmpMotion->SetFadeInTime(fadeTime);
        }

        fadeTime = _modelSetting->GetMotionFadeOutTimeValue(group, i);
        if (fadeTime >= 0.0f)
        {
            tmpMotion->SetFadeOutTime(fadeTime);
        }
        tmpMotion->SetEffectIds(_eyeBlinkIds, _lipSyncIds);

        if (_motions[name] != NULL)
        {
            ACubismMotion::Delete(_motions[name]);
        }
        _motions[name] = tmpMotion;
        
        free(buffer);
        if (LAppDefine::DebugLogEnable)
        {
            LAppPal::PrintLog("[APP]delete buffer: %s",path.GetRawString());
        }
    }
}
- (void)startRandomMotion{
    [self startRandomMotionWithGroup:LAppDefine::MotionGroupTapBody priority:LAppDefine::PriorityNormal];
}
- (void)startRandomMotionWithGroup:(const csmChar*)group priority:(csmInt32)priority{

    if (_modelSetting->GetMotionCount(group) == 0)
    {
        return;
    }

    csmInt32 no = rand() % _modelSetting->GetMotionCount(group);
    
    if (priority == LAppDefine::PriorityForce)
    {
        _userModel->GetMotionManager()->SetReservePriority(priority);
    }
    else if (!_userModel->GetMotionManager()->ReserveMotion(priority))
    {
        if (LAppDefine::DebugLogEnable)
        {
            LAppPal::PrintLog("[APP]can't start motion.");
        }
        return ;
    }

    const csmString fileName = _modelSetting->GetMotionFileName(group, no);

    //ex) idle_0
    csmString name = Utils::CubismString::GetFormatedString("%s_%d", group, no);
    CubismMotion* motion = static_cast<CubismMotion*>(_motions[name.GetRawString()]);
    csmBool autoDelete = false;

    if (motion == NULL)
    {
        NSURL* url = [_baseUrl URLByAppendingPathComponent:[NSString stringWithUTF8String:fileName.GetRawString()]];
        NSData *data = [NSData dataWithContentsOfURL:url];

        csmByte* buffer;
        csmSizeInt size;
        
        NSUInteger len = [data length];
        Byte *byteData = (Byte*)malloc(len);
        memcpy(byteData, [data bytes], len);

        size = static_cast<Csm::csmSizeInt>(len);
        buffer = static_cast<Csm::csmByte*>(byteData);
        
        motion = static_cast<CubismMotion*>(_userModel->LoadMotion(buffer, size, name.GetRawString()));
        csmFloat32 fadeTime = _modelSetting->GetMotionFadeInTimeValue(group, no);
        if (fadeTime >= 0.0f)
        {
            motion->SetFadeInTime(fadeTime);
        }

        fadeTime = _modelSetting->GetMotionFadeOutTimeValue(group, no);
        if (fadeTime >= 0.0f)
        {
            motion->SetFadeOutTime(fadeTime);
        }
        motion->SetEffectIds(_eyeBlinkIds, _lipSyncIds);
        autoDelete = true; // 終了時にメモリから削除
        free(buffer);
    }
    else
    {
        motion->SetFinishedMotionHandler(NULL);
    }

    if (LAppDefine::DebugLogEnable)
    {
        LAppPal::PrintLog("[APP]start motion: [%s_%d]", group, no);
    }
   _userModel->GetMotionManager()->StartMotionPriority(motion, autoDelete, priority);
    
}

- (void)startRandomExpression{
    if (_expressions.GetSize() == 0)
    {
        return;
    }
    csmInt32 no = rand() % _expressions.GetSize();
    csmMap<csmString, ACubismMotion*>::const_iterator map_ite;
    csmInt32 i = 0;
    for (map_ite = _expressions.Begin(); map_ite != _expressions.End(); map_ite++)
    {
        if (i == no)
        {
            csmString name = (*map_ite).First;
            ACubismMotion* motion = _expressions[name.GetRawString()];
            if (LAppDefine::DebugLogEnable)
            {
                LAppPal::PrintLog("[APP]expression: [%s]", name.GetRawString());
            }

            if (motion != NULL)
            {
                _userModel->GetExpressionManager()->StartMotionPriority(motion, false, LAppDefine::PriorityForce);
            }
            else
            {
                if (LAppDefine::DebugLogEnable)
                {
                    LAppPal::PrintLog("[APP]expression[%s] is null ", name.GetRawString());
                }
            }
            return;
        }
        i++;
    }
}


- (int)getNumberOfTextures {
    return _modelSetting->GetTextureCount();
}

- (NSString *)getFileNameOfTexture:(int)number {
    NSString* fileName = [NSString stringWithUTF8String:_modelSetting->GetTextureFileName(number)];
    NSURL *url = [NSURL URLWithString:fileName relativeToURL:_baseUrl];
    return [url lastPathComponent];
}

- (void)setTexture:(int)textureNo to:(uint32_t)openGLTextureNo {
    _userModel->GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->BindTexture(textureNo, openGLTextureNo);
}

- (void)setPremultipliedAlpha:(bool)enable {
    _userModel->GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->IsPremultipliedAlpha(enable);
}

- (float)getCanvasWidth {
    return _userModel->GetModel()->GetCanvasWidth();
}
- (float)getCanvasHeight {
    return _userModel->GetModel()->GetCanvasHeight();
}
- (void)setMatrix:(SCNMatrix4)matrix {
    float fMatrix[] = {
        matrix.m11, matrix.m12, matrix.m13, matrix.m14,
        matrix.m21, matrix.m22, matrix.m23, matrix.m24,
        matrix.m31, matrix.m32, matrix.m33, matrix.m34,
        matrix.m41, matrix.m42, matrix.m43, matrix.m44
    };
    const auto cMatrix = new CubismMatrix44();
    cMatrix->SetMatrix(fMatrix);
    _userModel->GetRenderer<Live2D::Cubism::Framework::Rendering::CubismRenderer_OpenGLES2>()->SetMvpMatrix(cMatrix);
}

- (void)setParam:(NSString *)paramId value:(Float32)value {
    const auto cid = CubismFramework::GetIdManager()->GetId((const char*)[paramId UTF8String]);
    _userModel->GetModel()->SetParameterValue(cid, value);
}

- (void)setPartsOpacity:(NSString *)paramId opacity:(Float32)value {
    const auto cid = CubismFramework::GetIdManager()->GetId((const char*)[paramId UTF8String]);
    _userModel->GetModel()->SetPartOpacity(cid, value);
}

- (void)updatePhysics:(Float32)delta {
    if (_physics != NULL)
    {
        _physics->Evaluate(_userModel->GetModel(), delta);
    }
}
- (void)updateExpStateWith:(Float32)delta{
    if (_userModel->GetExpressionManager() != NULL)
    {
        _userModel->GetExpressionManager()->UpdateMotion(_userModel->GetModel(), delta); // 表情でパラメータ更新（相対変化）
    }
}
- (void)update {
    if (!CubismFramework::IsInitialized()) {
        return;
    }
    _userModel->GetModel()->Update();
}

- (void)draw {
    if (!CubismFramework::IsInitialized()) {
        return;
    }
    _userModel->GetRenderer<Live2D::Cubism::Framework::Rendering::CubismRenderer_OpenGLES2>()->DrawModel();
}
- (void)lipSyncWithValue:(CGFloat)value{
    if (!value) {
        [self setParam:@"ParamMouthOpenY" value:0];
        return;
    }
//    NSLog(@"===lipSync value:%f",value);
    csmInt32 lipSyncIdCount = _modelSetting->GetLipSyncParameterCount();
    for (csmInt32 i = 0; i < lipSyncIdCount; ++i)
    {
        _userModel->GetModel()->AddParameterValue(_modelSetting->GetLipSyncParameterId(i), value, 0.8f);;
    }
}
- (void)onDrag:(Float32)x floatY:(Float32)y{
    _userModel->SetDragging(x,y);
}
- (void)onTap:(Float32)x floatY:(Float32)y{
    if ([self hitTestWith:LAppDefine::HitAreaNameHead floatX:x floatY:y]) {
        NSLog(@"点击 Head");
    }
    if ([self hitTestWith:LAppDefine::HitAreaNameBody floatX:x floatY:y]) {
        NSLog(@"点击 Body");
    }
}

- (bool)hitTestWith:(const Csm::csmChar*)name floatX:(Float32)floatX floatY:(Float32)floatY{
    // 透明时没有判定
    if (_userModel->GetOpacity() < 1)
    {
        return false;
    }
    const csmInt32 count = _modelSetting->GetHitAreasCount();
    for (csmInt32 i = 0; i < count; i++)
    {
        if (strcmp(_modelSetting->GetHitAreaName(i), name) == 0)
        {
            const CubismIdHandle drawID = _modelSetting->GetHitAreaId(i);
            return _userModel->IsHit(drawID, floatX, floatY);
        }
    }
    return false;

}
- (void)normalStateWith:(Float32)delta{
    
    if (!CubismFramework::IsInitialized()) {
        return;
    }
    csmBool motionUpdated = false;
    csmFloat32 deltaTimeSeconds = delta;
    
    _userModel->GetDragManager()->Update(deltaTimeSeconds);
    _dragX = _userModel->GetDragManager()->GetX();
    _dragY = _userModel->GetDragManager()->GetY();
    
    _userModel->GetModel()->LoadParameters(); //加载上次保存的状态
    
    if (_userModel->GetMotionManager()->IsFinished())
    {
        // 在没有运动的再生的情况下，从待机运动中随机再生
//        [self startRandomMotionWithGroup:LAppDefine::MotionGroupIdle priority:LAppDefine::PriorityIdle];
    }
    else
    {
        motionUpdated = _userModel->GetMotionManager()->UpdateMotion(_userModel->GetModel(), deltaTimeSeconds); // モーションを更新
    }
    _userModel->GetModel()->SaveParameters(); //保存状态
    // まばたき
    if (!motionUpdated)
    {
        if (_eyeBlink != NULL)
        {
            // メインモーションの更新がないとき
            _eyeBlink->UpdateParameters(_userModel->GetModel(), deltaTimeSeconds); // 目パチ
        }
    }
    
    _userModel->GetModel()->AddParameterValue(_idParamAngleX, _dragX * 30);
    _userModel->GetModel()->AddParameterValue(_idParamAngleY, _dragY * 30);
    _userModel->GetModel()->AddParameterValue(_idParamAngleZ, _dragX * _dragY * -30);

    _userModel->GetModel()->AddParameterValue(_idParamBodyAngleX, _dragX * 10);
    _userModel->GetModel()->AddParameterValue(_idParamBodyAngleZ, _dragX * _dragY * 10);

    _userModel->GetModel()->AddParameterValue(_idParamEyeBallX, _dragX);
    _userModel->GetModel()->AddParameterValue(_idParamEyeBallY, _dragY);

    // 呼吸など
    if (_breath != NULL)
    {
        _breath->UpdateParameters(_userModel->GetModel(), deltaTimeSeconds);
    }
    // 物理演算の設定
    if (_physics != NULL)
    {
        _physics->Evaluate(_userModel->GetModel(), deltaTimeSeconds);
    }
   
    if (_userModel->GetExpressionManager() != NULL)
    {
        _userModel->GetExpressionManager()->UpdateMotion(_userModel->GetModel(), deltaTimeSeconds); // 表情でパラメータ更新（相対変化）
    }

    if (self.lipSyncValue) {
        [self lipSyncWithValue:self.lipSyncValue];
    }
    
    if ((self.mouthMY || self.mouthMf)) {
        [self setParam:@"ParamMouthOpenY" value:self.mouthMY];
        [self setParam:@"ParamMouthForm" value:self.mouthMf];
    }
    
}
- (void)releasRender{
    _userModel->DeleteRenderer();
}
@end
  
