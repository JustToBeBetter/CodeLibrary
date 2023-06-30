//
//  Live2DModelOpenGL.h
//  MurderMystery
//
//  Created by 李金柱 on 2021/2/22.
//  Copyright © 2021 YoKa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <SceneKit/SceneKit.h>

@interface Live2DCubism : NSObject
+ (void)initL2D;
+ (void)dispose;
+ (NSString *)live2DVersion;
@end


NS_ASSUME_NONNULL_BEGIN

@interface Live2DModelOpenGL : NSObject
- (instancetype)initWithJsonPath:(NSString *)jsonPath textureMap:(NSMutableDictionary *)textureMap;
- (void)loadModelWithPath:(NSString *)path;
- (int)getNumberOfTextures;
- (NSString *)getFileNameOfTexture:(int)number;
- (void)setTexture:(int)textureNo to:(uint32_t)openGLTextureNo;
- (void)setPremultipliedAlpha:(bool)enable;
- (float)getCanvasWidth;
- (float)getCanvasHeight;
- (void)setMatrix:(SCNMatrix4)matrix;
- (void)setParam:(NSString *)paramId value:(Float32)value;
- (void)setPartsOpacity:(NSString *)paramId opacity:(Float32)value;
- (void)updatePhysics:(Float32)delta;
- (void)updateExpStateWith:(Float32)delta;
- (void)update;
- (void)draw;

- (void)lipSyncWithValue:(CGFloat)value;

- (void)onDrag:(Float32)x floatY:(Float32)y;
- (void)onTap:(Float32)x floatY:(Float32)y;

- (void)normalStateWith:(Float32)delta;
- (void)startRandomExpression;
- (void)startRandomMotion;

- (void)releasRender;

@property (nonatomic, copy) NSString *modelPath;
@property (nonatomic, strong) NSArray<NSString *> *texturePaths;
@property (nonatomic, strong) NSArray<NSString *> *parts;
@property (nonatomic, assign) CGFloat lipSyncValue;
@property (nonatomic, assign) CGFloat mouthMf;
@property (nonatomic, assign) CGFloat mouthMY;

@end

NS_ASSUME_NONNULL_END
