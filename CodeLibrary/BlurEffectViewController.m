//
//  BlurEffectViewController.m
//  CodeLibrary
//
//  Created by 李金柱 on 2020/7/21.
//  Copyright © 2020 李金柱. All rights reserved.
//

#import "BlurEffectViewController.h"
#import <Accelerate/Accelerate.h>
#import "UIImage+ImageEffects.h"


@interface BlurEffectViewController ()

@property (strong, nonatomic) UIImageView *photoImageView;

@end

@implementation BlurEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.photoImageView];
    [self methodOne];
}
- (void)methodOne{
    self.title = @"方法一";
    [self.photoImageView setImage:[UIImage imageNamed:@"test.jpeg"]];
    //毛玻璃效果（高斯模糊）
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.photoImageView.bounds;
    [self.photoImageView addSubview:visualEffectView];
    
    [self performSelector:@selector(methodTwo) withObject:nil afterDelay:5];
}
- (void)methodTwo{
    self.title = @"方法二";
    //毛玻璃效果（高斯模糊）
    [self.photoImageView setImage:[[UIImage imageNamed:@"test.jpeg"] applyLightEffect]];
    [self performSelector:@selector(methodThree) withObject:nil afterDelay:5];

}
- (void)methodThree{
    self.title = @"方法三";
    //毛玻璃效果（高斯模糊）
    [self.photoImageView setImage:[self createBlurBackground:[UIImage imageNamed:@"test.jpeg"] blurRadius:5.0f]];
    [self performSelector:@selector(methodFour) withObject:nil afterDelay:5];

}
- (void)methodFour{
    self.title = @"方法四";
    //毛玻璃效果（高斯模糊）
    [self.photoImageView setImage:[self blurryImage:[UIImage imageNamed:@"test.jpeg"] withBlurLevel:0.8f]];
    [self performSelector:@selector(methodOne) withObject:nil afterDelay:5];

}
//创建高斯模糊效果的背景
- (UIImage*)createBlurBackground:(UIImage*)image blurRadius:(CGFloat)blurRadius
{
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey,inputImage,@"inputRadius",@(blurRadius),nil];
    CIImage *outPutImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage:outPutImage fromRect:[inputImage extent]];
    return [UIImage imageWithCGImage:outImage];
}

- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 100);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer,
                                       &outBuffer,
                                       NULL,
                                       0,
                                       0,
                                       boxSize,
                                       boxSize,
                                       NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

#pragma mark ---------lazy--------

- (UIImageView *)photoImageView{
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _photoImageView;;
}

@end
