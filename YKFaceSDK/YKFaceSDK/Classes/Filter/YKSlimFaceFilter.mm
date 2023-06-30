//
//  YKSlimFaceFilter.m
//  YKFaceSDK
//
//  Created by feng on 2018/8/31.
//  Copyright © 2018年 feng. All rights reserved.
//
#import "YKFaceSDK.h"
#import "YKSlimFaceFilter.h"

#define GL_FRAGMENT_PRECISION_HIGH

NSString *const kYKSlimFaceFilterFragmentShaderString = SHADER_STRING
(
    precision highp float;
    varying highp vec2 textureCoordinate;

    uniform sampler2D inputImageTexture;

    uniform float faceShape[9 * 2];
    uniform float noseShape[9 * 2];
     
    uniform highp vec2 left_eye_top;
    uniform highp vec2 left_eye_center;
    uniform highp vec2 right_eye_top;
    uniform highp vec2 right_eye_center;

    uniform int hasFace;

    uniform highp float aspectRatio;
    uniform float thinFaceDelta;
    uniform float bigEyeDelta;
  
    //圓內放大
    vec2 enlargeEye(vec2 textureCoord, vec2 originPosition, float radius, float delta) {
      
      float weight = distance(vec2(textureCoord.x, textureCoord.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio)) / radius;
      
      weight = 1.0 - (1.0 - weight * weight) * delta;
      weight = clamp(weight, 0.0, 1.0);
      textureCoord = originPosition + (textureCoord - originPosition) * weight;
      return textureCoord;
    }

    // 曲线形变处理
    vec2 curveWarp(vec2 textureCoord, vec2 originPosition, vec2 targetPosition, float delta) {
      
      vec2 offset = vec2(0.0);
      vec2 result = vec2(0.0);
      vec2 direction = (targetPosition - originPosition) * delta;
      
      float radius = distance(vec2(targetPosition.x, targetPosition.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio));
      float ratio = distance(vec2(textureCoord.x, textureCoord.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio)) / radius;
      
      ratio = 1.0 - ratio;
      ratio = clamp(ratio, 0.0, 1.0);
      offset = direction * ratio;
      
      result = textureCoord - offset;
      
      return result;
    }

    vec2 thinFace(vec2 currentCoordinate) {
      for(int i = 0; i < 9; i++)
      {
          vec2 originPoint = vec2(faceShape[i * 2], faceShape[i * 2 + 1]);
          vec2 targetPoint = vec2(noseShape[i * 2], noseShape[i * 2 + 1]);
          currentCoordinate = curveWarp(currentCoordinate, originPoint, targetPoint, thinFaceDelta);
      }
      return currentCoordinate;
    }

    vec2 bigEye(vec2 originPoint, vec2 targetPoint, vec2 currentCoordinate) {
      
      float radius = distance(vec2(targetPoint.x, targetPoint.y / aspectRatio), vec2(originPoint.x, originPoint.y / aspectRatio));
      radius = radius * 5.;
      currentCoordinate = enlargeEye(currentCoordinate, originPoint, radius, bigEyeDelta);

      return currentCoordinate;
    }

    void main()
    {
      vec2 positionToUse = textureCoordinate;
      
      if (hasFace == 1) {
          positionToUse = thinFace(positionToUse);
          positionToUse = bigEye(left_eye_center, left_eye_top, positionToUse);
          positionToUse = bigEye(right_eye_center, right_eye_top, positionToUse);
      }
      
      gl_FragColor = texture2D(inputImageTexture, positionToUse);
      
    }
);

@interface YKSlimFaceFilter () {

}

@property (nonatomic, strong) NSArray *enlargeEyePoints;
@property (nonatomic, strong) NSArray *enlargeEyePointNames;
@property (nonatomic, strong) NSArray *noseShapePoints;
@property (nonatomic, strong) NSArray *faceShapePoints;

@end

@implementation YKSlimFaceFilter

- (id)init {
    if (!(self = [super initWithFragmentShaderFromString:kYKSlimFaceFilterFragmentShaderString])) {
        return nil;
    }
    
    self.slimFace = NO;
    self.largeEyes = NO;
    _slimFaceDelta = 0.5;
    _enlargeEyesDelta = 0.5;
    
    // 275点
    self.faceShapePoints = @[@78, @114, @83, @109, @90, @103, @93, @96, @99];
    self.noseShapePoints = @[@35, @35, @34, @34, @33, @33, @32, @32, @32];
    self.enlargeEyePoints = @[@166, @269, @190, @270];
    self.enlargeEyePointNames = @[@"left_eye_top", @"left_eye_center", @"right_eye_top",  @"right_eye_center"];
    
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    [super setInputSize:newSize atIndex:textureIndex];
    [self setInteger:newSize.width forUniformName:@"textureWidth"];
    [self setInteger:newSize.height forUniformName:@"textureHeight"];
    CGFloat aspect = inputTextureSize.width / inputTextureSize.height;
    [self setFloat:aspect forUniformName:@"aspectRatio"];
}

- (void)setSlimFace:(BOOL)slimFace {
    _slimFace = slimFace;
    if (_slimFace) {
        [self setFloat:0.05 * _slimFaceDelta forUniformName:@"thinFaceDelta"];
    } else {
        [self setFloat:0 forUniformName:@"thinFaceDelta"];
    }
}

- (void)setLargeEyes:(BOOL)largeEyes {
    _largeEyes = largeEyes;
    if (_largeEyes) {
        [self setFloat:0.15 * _enlargeEyesDelta forUniformName:@"bigEyeDelta"];
    } else {
        [self setFloat:0 forUniformName:@"bigEyeDelta"];
    }
}

- (void)setFaceInfoArray:(NSArray *)faceInfoArray {
    _faceInfoArray = faceInfoArray;
}

- (void)resetLandMarkPoint {
    [self setInteger:0 forUniformName:@"hasFace"];
}

- (void)setUniformWithFaceInfo {
    if (_faceInfoArray && _faceInfoArray.count > 0) {
        YKFaceInfo *faceInfo = [_faceInfoArray objectAtIndex:0];
        if (faceInfo.normalizationLandmarks.count > 0) {
            [self setFloatPointsWithArray:self.faceShapePoints size:18 landmarks:faceInfo.normalizationLandmarks forUniformName:@"faceShape"];
            [self setFloatPointsWithArray:self.noseShapePoints size:18 landmarks:faceInfo.normalizationLandmarks forUniformName:@"noseShape"];
            for (NSInteger i = 0; i < self.enlargeEyePointNames.count; i++) {
                NSInteger index = [[self.enlargeEyePoints objectAtIndex:i] integerValue];
                NSString *pointName = [self.enlargeEyePointNames objectAtIndex:i];
                [self setPoint: [self convertLandmarkPointByIndex:index faceInfo:faceInfo] forUniformName:pointName];
            }
            [self setInteger:1 forUniformName:@"hasFace"];
        } else {
            [self resetLandMarkPoint];
            
        }
    } else {
        [self resetLandMarkPoint];
    }
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    [self setUniformWithFaceInfo];
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
}

- (void)setFloatPointsWithArray:(NSArray *)array size:(GLsizei)size landmarks:(NSArray *)landmarks forUniformName:(NSString *)uniformName {
    GLfloat *facePoints = (GLfloat *)malloc(size * sizeof(GLfloat));
    int index = 0;
    for (int i = 0; i < array.count; i++) {
        NSInteger pointIndex = [[array objectAtIndex:i] integerValue];
        CGPoint point = [[landmarks objectAtIndex:pointIndex] CGPointValue];
        *(facePoints + index) = point.x;
        *(facePoints + index + 1) = point.y;
        index += 2;
        
        if (index == size) {
            break;
        }
    }
    [self setFloatArray:facePoints length:size forUniform:uniformName];
    free(facePoints);
}

- (CGPoint)convertLandmarkPointByIndex:(NSInteger)index faceInfo:(YKFaceInfo *)faceInfo {
    CGPoint pt = [[faceInfo.normalizationLandmarks objectAtIndex:index] CGPointValue];
    if (!CGSizeEqualToSize(inputTextureSize, CGSizeZero)) {
        return CGPointMake(pt.x, pt.y);
    } else {
        return CGPointZero;
    }
}

@end
