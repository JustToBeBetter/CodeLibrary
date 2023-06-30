//
//  YKFaceSticker.m
//  YKFaceSDK
//
//  Created by feng on 2016/10/14.
//  Copyright © 2016年 feng. All rights reserved.
//

#import "YKFaceStickersManager.h"
#import <OpenGLES/ES2/GL.h>

@interface YKFaceStickerItem()

@end

@implementation YKFaceStickerItem {
    NSArray *_imageFileURLs;
    GLuint *_textureArr;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.type = [[dict objectForKey:@"type"] intValue];
        self.triggerType = (YKFaceStickerItemTriggerType)[[dict objectForKey:@"trigerType"] intValue];

        self.itemDir = [dict objectForKey:@"frameFolder"];
        self.count = [[dict objectForKey:@"frameNum"] intValue];
        self.duration = [[dict objectForKey:@"frameDuration"] doubleValue] / 1000.;
        self.width = [[dict objectForKey:@"frameWidth"] floatValue];
        self.height = [[dict objectForKey:@"frameHeight"] floatValue];

        self.position = [[dict objectForKey:@"facePos"] intValue];

        self.scaleWidthOffset = [[dict objectForKey:@"scaleWidthOffset"] floatValue];
        self.scaleHeightOffset = [[dict objectForKey:@"scaleHeightOffset"] floatValue];
        self.scaleXOffset = [[dict objectForKey:@"scaleXOffset"] floatValue];
        self.scaleYOffset = [[dict objectForKey:@"scaleYOffset"] floatValue];

        self.accumulator = 0.;
        self.currentFrameIndex = 0;
        self.loopCountdown = NSIntegerMax;
        self.triggered = NO;
    }
    return self;
}

- (NSUInteger)_nextFrameIndexForInterval:(NSTimeInterval)interval {
    // This is where FLAnimatedImage loads the GIF
    NSUInteger nextFrameIndex = self.currentFrameIndex;
    self.accumulator += interval;

    while (self.accumulator > self.duration) {
        self.accumulator -= self.duration;
        nextFrameIndex++;
        if (nextFrameIndex >= self.count) {
            // If we've looped the number of times that this animated image describes, stop looping.
            self.loopCountdown--;

            if (self.loopCountdown == 0) {
                if (self.isLastItem && self.stickerItemPlayOver) {
                    self.stickerItemPlayOver();
                }
                nextFrameIndex = self.count - 1;
                break;
            } else {
                nextFrameIndex = 0;
            }
        }
    }

    return nextFrameIndex;
}

- (UIImage *)currentFrame {
    return [self _imageAtIndex:self.currentFrameIndex];
}

- (UIImage *)nextImageForInterval:(NSTimeInterval)interval {
    if (self.loopCountdown == 0) {
        return self.currentFrame;
    }

    self.currentFrameIndex = [self _nextFrameIndexForInterval:interval];

    return [self _imageAtIndex:self.currentFrameIndex];
}

- (UIImage *)_imageAtIndex:(NSUInteger)index {
    if (_imageFileURLs.count <= 0) {
        [self _loadImages];
    }

    if (index >= _imageFileURLs.count) {
        return nil;
    }

    return [UIImage imageWithContentsOfFile:[[_imageFileURLs objectAtIndex:index] path]];
}

- (void)_loadImages {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.itemDir isDirectory:YES];
    NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLNameKey];

    // First get the cache file related properties
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:diskCacheURL
                                                                 includingPropertiesForKeys:resourceKeys
                                                                                    options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles
                                                                               errorHandler:^BOOL(NSURL *_Nonnull url, NSError *_Nonnull error) {
                                                                                   NSLog(@"error: %@", error);
                                                                                   return NO;
                                                                               }];

    NSMutableDictionary *imageFiles = [NSMutableDictionary dictionary];

    // 遍历目录下的所有文件
    for (NSURL *fileURL in fileEnumerator) {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }

        [imageFiles setObject:resourceValues forKey:fileURL];
    }

    _imageFileURLs = [imageFiles keysSortedByValueWithOptions:NSSortConcurrent
                                              usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                  return [obj1[NSURLNameKey] compare:obj2[NSURLNameKey]
                                                                             options:NSNumericSearch];
                                              }];
}

- (GLuint)_textureWithImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    NSAssert(imageRef, @"Failed to load image.");

    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);

    GLubyte *imageData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));

    CGContextRef spriteContext = CGBitmapContextCreate(imageData, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), imageRef);
    
    CGContextRelease(spriteContext);

    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei) width, (GLsizei) height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);

    glBindTexture(GL_TEXTURE_2D, 0);
    free(imageData);

    return texture;
}

- (GLuint)_textureAtIndex:(NSUInteger)index {
    if (_textureArr == NULL) {
        _textureArr = malloc(sizeof(GLuint) * self.count);
        if (_textureArr == NULL) {
            // 分配内存失败
            return 0;
        }

        for (int i = 0; i < self.count; i++) {
            _textureArr[i] = 0;
        }
    }

    GLuint texture = _textureArr[index];
    if (texture == 0) {
        texture = [self _textureWithImage:[self _imageAtIndex:index]];
        _textureArr[index] = texture;
    }

    return texture;
}

- (GLuint)nextTextureForInterval:(NSTimeInterval)interval {
    self.currentFrameIndex = [self _nextFrameIndexForInterval:interval];
    return [self _textureAtIndex:self.currentFrameIndex];
}

- (void)deleteTextures {
    if (_textureArr) {
        glDeleteTextures((GLsizei) self.count, _textureArr);
        free(_textureArr);
        _textureArr = NULL;
    }
}

- (void)dealloc {
    [self deleteTextures];
}

@end

