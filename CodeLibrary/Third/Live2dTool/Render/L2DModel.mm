//
//  L2DModel.m
//  Live2DMetal
//
//  Copyright (c) 2020-2020 Ian Wang
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "L2DModel.h"
#import "Live2DCubismCore.hpp"
#import "CubismUserModel.hpp"
#import "CubismFramework.hpp"
#import "CubismUserModel.hpp"
#import "CubismModelSettingJson.hpp"
#import "CubismIdManager.hpp"
#import "CubismDefaultParameterId.hpp"
#import "CubismString.hpp"
#import "CubismMotion.hpp"
#import "ACubismMotion.hpp"
#import "CubismRenderer.hpp"
#import "CubismRenderer_OpenGLES2.hpp"
#include "CubismEyeBlink.hpp"


using namespace Live2D::Cubism::Core;
using namespace Live2D::Cubism::Framework;
using namespace Live2D::Cubism::Framework::Rendering;
using namespace Live2D::Cubism::Framework::DefaultParameterId;


@interface L2DModel () {
 @private
   NSURL *baseURL;
   
   CubismUserModel *model;
   CubismPhysics *physics;
   ICubismModelSetting *modelSetting;
   CubismEyeBlink  *_eyeBlink;
   CubismBreath    *_breath;
   const Csm::CubismId* _paramAngleX; ///< パラメータID: ParamAngleX
   const Csm::CubismId* _paramAngleY; ///< パラメータID: ParamAngleX
   const Csm::CubismId* _paramAngleZ; ///< パラメータID: ParamAngleX
   const Csm::CubismId* _paramBodyAngleX; ///< パラメータID: ParamBodyAngleX
   const Csm::CubismId* _paramEyeBallX; ///< パラメータID: ParamEyeBallX
   const Csm::CubismId* _paramEyeBallY; ///< パラメータID: ParamEyeBallXY
}

@property (nonatomic, assign, readonly, getter=userModel) CubismUserModel *userModel;
@property (nonatomic, assign, readonly, getter=cubismModel) CubismModel *cubismModel;
@property (nonatomic, assign) Csm::csmVector<Csm::CubismIdHandle> eyeBlinkIds;//在模型中设置的眨眼功能参数ID
@property (nonatomic, assign) Csm::csmVector<Csm::CubismIdHandle> lipSyncIds;//在模型中设置的用于口型功能的参数ID
@property (nonatomic, assign) Csm::csmMap<Csm::csmString, Csm::ACubismMotion*>motions;//正在读取的动作列表

@end

@implementation L2DModel

- (instancetype)initWithJsonPath:(NSString *)jsonPath {
    if (self = [super init]) {
        @autoreleasepool {
            NSURL *url = [NSURL fileURLWithPath:jsonPath];
            // Get base directory name.
            baseURL = [url URLByDeletingLastPathComponent];

            // Read json file.
            NSData *data = [NSData dataWithContentsOfURL:url];

            // Create settings.
            modelSetting = new CubismModelSettingJson((const unsigned char *)[data bytes], (unsigned int)[data length]);

            // Get model file.
            NSString *modelFileName = [NSString stringWithCString:modelSetting->GetModelFileName() encoding:NSUTF8StringEncoding];
            NSData *modelData = [NSData dataWithContentsOfURL:[baseURL URLByAppendingPathComponent:modelFileName]];

            // Create model.
            model = new CubismUserModel();
            model->LoadModel((const unsigned char *)[modelData bytes], (unsigned int)[modelData length]);

            // Create physics.
            NSString *physicsFileName = [NSString stringWithCString:modelSetting->GetPhysicsFileName() encoding:NSUTF8StringEncoding];
            if (physicsFileName.length > 0) {
                NSData *physicsData = [NSData dataWithContentsOfURL:[baseURL URLByAppendingPathComponent:physicsFileName]];
                physics = CubismPhysics::Create((const unsigned char *)[physicsData bytes], (unsigned int)[physicsData length]);
            }
            _paramAngleX = CubismFramework::GetIdManager()->GetId(ParamAngleX);
            _paramAngleY = CubismFramework::GetIdManager()->GetId(ParamAngleY);
            _paramAngleZ = CubismFramework::GetIdManager()->GetId(ParamAngleZ);
            _paramBodyAngleX = CubismFramework::GetIdManager()->GetId(ParamBodyAngleX);
            _paramEyeBallX = CubismFramework::GetIdManager()->GetId(ParamEyeBallX);
            _paramEyeBallY = CubismFramework::GetIdManager()->GetId(ParamEyeBallY);
            
            //EyeBlink
            if (modelSetting->GetEyeBlinkParameterCount() > 0)
            {
                _eyeBlink = CubismEyeBlink::Create(modelSetting);
            }
            
            //Breath
            {
                _breath = CubismBreath::Create();

                csmVector<CubismBreath::BreathParameterData> breathParameters;

                breathParameters.PushBack(CubismBreath::BreathParameterData(_paramAngleX, 0.0f, 15.0f, 6.5345f, 0.5f));
                breathParameters.PushBack(CubismBreath::BreathParameterData(_paramAngleY, 0.0f, 8.0f, 3.5345f, 0.5f));
                breathParameters.PushBack(CubismBreath::BreathParameterData(_paramAngleZ, 0.0f, 10.0f, 5.5345f, 0.5f));
                breathParameters.PushBack(CubismBreath::BreathParameterData(_paramBodyAngleX, 0.0f, 4.0f, 15.5345f, 0.5f));
                breathParameters.PushBack(CubismBreath::BreathParameterData(CubismFramework::GetIdManager()->GetId(ParamBreath), 0.5f, 0.5f, 3.2345f, 0.5f));

                _breath->SetParameters(breathParameters);
            }

            // EyeBlinkIds
            {
                csmInt32 eyeBlinkIdCount = modelSetting->GetEyeBlinkParameterCount();
                for (csmInt32 i = 0; i < eyeBlinkIdCount; ++i)
                {
                    _eyeBlinkIds.PushBack(modelSetting->GetEyeBlinkParameterId(i));
                }
            }
         
            // LipSyncIds
            {
                csmInt32 lipSyncIdCount = modelSetting->GetLipSyncParameterCount();
                for (csmInt32 i = 0; i < lipSyncIdCount; ++i)
                {
                    _lipSyncIds.PushBack(modelSetting->GetLipSyncParameterId(i));
                }
            }
            
//            for (csmInt32 i = 0; i < modelSetting->GetMotionGroupCount(); i++)
//            {
//                const csmChar* group = modelSetting->GetMotionGroupName(i);
//                [self preloadMotionGroup:group];
//            }
        }
    }

    return self;
}

- (void)dealloc {
    if (modelSetting) {
        free(modelSetting);
    }
    if (model) {
        free(model);
    }
    if (physics) {
        free(physics);
    }
    NSLog(@"[APP]live2d model free");

}

- (CubismUserModel*)userModel {
    return model;
}

- (CubismModel*)cubismModel {
    return model->GetModel();
}

- (void)preloadMotionGroup:(const csmChar*)group{
    const csmInt32 count = modelSetting->GetMotionCount(group);

    for (csmInt32 i = 0; i < count; i++)
    {
//        //ex) idle_0
//        csmString name = Utils::CubismString::GetFormatedString("%s_%d", group, i);
//        csmString path = modelSetting->GetMotionFileName(group, i);
//        NSURL* url = [baseURL URLByAppendingPathComponent:[NSString stringWithUTF8String:modelSetting->GetMotionFileName(group, i)]];
//        NSString *str = [url.absoluteString stringByReplacingOccurrencesOfString:@"motions/" withString:@""];
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
//
//        NSLog(@"[APP]load motion: %s => [%s_%d] ", path.GetRawString(), group, i);
//
//        CubismMotion* tmpMotion = static_cast<CubismMotion*>(self.userModel->LoadMotion((const unsigned char *)[data bytes], (unsigned int)[data length], name.GetRawString()));
//
//        csmFloat32 fadeTime = modelSetting->GetMotionFadeInTimeValue(group, i);
//        if (fadeTime >= 0.0f)
//        {
//            tmpMotion->SetFadeInTime(fadeTime);
//        }
//
//        fadeTime = modelSetting->GetMotionFadeOutTimeValue(group, i);
//        if (fadeTime >= 0.0f)
//        {
//            tmpMotion->SetFadeOutTime(fadeTime);
//        }
//        tmpMotion->SetEffectIds(_eyeBlinkIds, _lipSyncIds);
//
//        if (_motions[name] != NULL)
//        {
//            ACubismMotion::Delete(_motions[name]);
//        }
//        _motions[name] = tmpMotion;
//        NSLog(@"[APP]delete buffer: %s",path.GetRawString());

    }
}

- (void)normalState{
    csmBool motionUpdated = false;
    csmFloat32 deltaTimeSeconds = 0.03f;
    model->GetModel()->LoadParameters(); //加载上次保存的状态
    model->GetModel()->SaveParameters(); //保存状态
//    //ドラッグによる変化
//    //ドラッグによる顔の向きの調整
//    self.cubismModel->AddParameterValue(_paramAngleX, 0 * 30); // -30から30の値を加える
//    self.cubismModel->AddParameterValue(_paramAngleY, 0 * 30);
//    self.cubismModel->AddParameterValue(_paramAngleZ, 0 * -30);
//
//    //ドラッグによる体の向きの調整
//    self.cubismModel->AddParameterValue(_paramBodyAngleX, 0 * 10); // -10から10の値を加える
//
//    //ドラッグによる目の向きの調整
//    self.cubismModel->AddParameterValue(_paramEyeBallX, 0); // -1から1の値を加える
//    self.cubismModel->AddParameterValue(_paramEyeBallY, 0);
    
    // まばたき
    if (!motionUpdated)
    {
        if (_eyeBlink != NULL)
        {
            // メインモーションの更新がないとき
            _eyeBlink->UpdateParameters(self.cubismModel, deltaTimeSeconds); // 目パチ
        }
    }

    // 呼吸など
    if (_breath != NULL)
    {
        _breath->UpdateParameters(self.cubismModel, deltaTimeSeconds);
    }

    // 物理演算の設定
    if (physics != NULL)
    {
        physics->Evaluate(self.cubismModel, deltaTimeSeconds);
    }
    
}
- (void)startRandomMotion{
    csmInt32 priority = 1;
    const csmChar* group = "Idle";
    if (modelSetting->GetMotionCount(group) == 0){
       NSLog(@"[APP]motion invalid");
        return;
    }
    csmInt32 no = rand() % modelSetting->GetMotionCount(group);


    const csmString fileName = modelSetting->GetMotionFileName(group, no);

    //ex) idle_0
    csmString name = Utils::CubismString::GetFormatedString("%s_%d", group, no);
    CubismMotion* motion = static_cast<CubismMotion*>(_motions[name.GetRawString()]);
    csmBool autoDelete = false;

    if (motion == NULL)
    {
        csmString path = fileName;
        NSURL* url = [baseURL URLByAppendingPathComponent:[NSString stringWithUTF8String:path.GetRawString()]];
        NSString *str = [url.absoluteString stringByReplacingOccurrencesOfString:@"motions/" withString:@""];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
       
        motion = static_cast<CubismMotion*>(self.userModel->LoadMotion((const unsigned char *)[data bytes], (unsigned int)[data length], NULL, NULL));
        csmFloat32 fadeTime = modelSetting->GetMotionFadeInTimeValue(group, no);
        if (fadeTime >= 0.0f)
        {
            motion->SetFadeInTime(fadeTime);
        }

        fadeTime = modelSetting->GetMotionFadeOutTimeValue(group, no);
        if (fadeTime >= 0.0f)
        {
            motion->SetFadeOutTime(fadeTime);
        }
        motion->SetEffectIds(_eyeBlinkIds, _lipSyncIds);
        autoDelete = true; // 終了時にメモリから削除
    }
    else
    {
//        motion->SetFinishedMotionHandler(onFinishedMotionHandler);
    }

    NSLog(@"[APP]start motion: [%s_%d]", group, no);
}

- (CGSize)modelSize {
    return CGSizeMake(self.cubismModel->GetCanvasWidth(), self.cubismModel->GetCanvasHeight());
}

- (void)setModelParameterNamed:(NSString *)name withValue:(float)value {
    const auto cubismParamID = CubismFramework::GetIdManager()->GetId((const char *)[name UTF8String]);
    self.cubismModel->SetParameterValue(cubismParamID, value);
}

- (float)getValueForModelParameterNamed:(NSString *)name {
    const auto cubismParamID = CubismFramework::GetIdManager()->GetId((const char *)[name UTF8String]);
    float value = self.cubismModel->GetParameterValue(cubismParamID);
    return value;
}

- (void)setPartsOpacityNamed:(NSString *)name opacity:(float)opacity {
    const auto cubismPartID = CubismFramework::GetIdManager()->GetId((const char *)[name UTF8String]);
    self.cubismModel->SetPartOpacity(cubismPartID, opacity);
}

- (float)getPartsOpacityNamed:(NSString *)name {
    const auto cubismPartID = CubismFramework::GetIdManager()->GetId((const char *)[name UTF8String]);
    float opacity = self.cubismModel->GetPartOpacity(cubismPartID);
    return opacity;
}

- (NSArray *)textureURLs {
    NSMutableArray<NSURL *> *urls = [NSMutableArray array];
    for (int i = 0; i < modelSetting->GetTextureCount(); ++i) {
        @autoreleasepool {
            NSString *name = [NSString stringWithCString:modelSetting->GetTextureFileName(i) encoding:NSUTF8StringEncoding];
            NSURL *file = [NSURL URLWithString:name relativeToURL:baseURL];
            NSString *filePath = [[NSBundle mainBundle]pathForResource:[file lastPathComponent] ofType:nil];
            [urls addObject:[NSURL fileURLWithPath:filePath]];
        }
    }
    return urls;
}

- (int) textureIndexForDrawable:(int)index {
    return self.cubismModel->GetDrawableTextureIndices(index);
}

- (int) drawableCount {
    return self.cubismModel->GetDrawableCount();
}

- (RawFloatArray*) vertexPositionsForDrawable: (int)index {
    int vertexCount = self.cubismModel->GetDrawableVertexCount(index);
    const float *positions = self.cubismModel->GetDrawableVertices(index);

    return [[RawFloatArray alloc] initWithCArray:positions count:vertexCount];
}

- (RawFloatArray*) vertexTextureCoordinateForDrawable: (int)index {
    int vertexCount = self.cubismModel->GetDrawableVertexCount(index);
    const csmVector2 *uvs = self.cubismModel->GetDrawableVertexUvs(index);

    return [[RawFloatArray alloc] initWithCArray:reinterpret_cast<const csmFloat32 *>(uvs) count:vertexCount];
}

- (RawUShortArray*) vertexIndicesForDrawable: (int)index {
    int indexCount = self.cubismModel->GetDrawableVertexIndexCount(index);
    const unsigned short *indices = self.cubismModel->GetDrawableVertexIndices(index);

    return [[RawUShortArray alloc] initWithCArray:indices count:indexCount];
}

- (RawIntArray *)masksForDrawable:(int)index {
    const int *maskCounts = self.cubismModel->GetDrawableMaskCounts();
    const int **masks = self.cubismModel->GetDrawableMasks();

    return [[RawIntArray alloc] initWithCArray:masks[index] count:maskCounts[index]];
}

- (bool) cullingModeForDrawable: (int)index {
    return (self.cubismModel->GetDrawableCulling(index) != 0);
}

- (float) opacityForDrawable: (int)index {
    return self.cubismModel->GetDrawableOpacity(index);
}

- (bool) visibilityForDrawable: (int)index {
    return self.cubismModel->GetDrawableDynamicFlagIsVisible(index);
}

- (L2DBlendMode) blendingModeForDrawable: (int)index {
    switch (self.cubismModel->GetDrawableBlendMode(index)) {
    case CubismRenderer::CubismBlendMode_Normal:
        return NormalBlending;
    case CubismRenderer::CubismBlendMode_Additive:
        return AdditiveBlending;
    case CubismRenderer::CubismBlendMode_Multiplicative:
        return MultiplicativeBlending;
    default:
        return NormalBlending;
    }
}

- (RawIntArray *)renderOrders {
    return [[RawIntArray alloc] initWithCArray:self.cubismModel->GetDrawableRenderOrders() count:[self drawableCount]];
}

- (bool) isRenderOrderDidChangedForDrawable: (int)index {
    return self.cubismModel->GetDrawableDynamicFlagRenderOrderDidChange(index);
}

- (bool) isOpacityDidChangedForDrawable: (int)index {
    return self.cubismModel->GetDrawableDynamicFlagOpacityDidChange(index);
}

- (bool) isVisibilityDidChangedForDrawable: (int)index {
    return self.cubismModel->GetDrawableDynamicFlagVisibilityDidChange(index);
}

- (bool) isVertexPositionDidChangedForDrawable: (int)index {
    return self.cubismModel->GetDrawableDynamicFlagVertexPositionsDidChange(index);
}


@end

@implementation L2DModel (UpdateAndPhysics)

- (void) update {
    self.cubismModel->Update();
}

- (void) updatePhysics: (NSTimeInterval)dt {
    if (physics != nil) {
        physics->Evaluate(self.cubismModel, dt);
    }
}
    

@end
