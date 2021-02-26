//
//  GifWebPImgViewController.m
//  CodeLibrary
//
//  Created by 李金柱 on 2021/2/24.
//  Copyright © 2021 李金柱. All rights reserved.
//

#import "GifWebPImgViewController.h"

@interface GifWebPImgViewController ()

@end

@implementation GifWebPImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    self.view.backgroundColor = UIColor.whiteColor;
    [[SDImageCodersManager sharedManager] addCoder:[SDImageWebPCoder sharedCoder]];
    [[SDWebImageDownloader sharedDownloader] setValue:@"image/webp,image/*,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [self initUI];
}
- (void)initUI{
    
    /*动态web http://littlesvr.ca/apng/images/world-cup-2014-42.webp
             https://upload-images.jianshu.io/upload_images/14783885-392024644087619a.gif?imageMogr2/auto-orient/strip/imageView2/2/w/440/format/webp
    **/
    
    /*静态web https://www.gstatic.com/webp/gallery/2.webp **/
    
    /*gif https://upload-images.jianshu.io/upload_images/3885450-f94ea2ba66ea1b2c.gif **/

    
    FLAnimatedImageView *imageView = [FLAnimatedImageView new];
    imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 3);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    
    FLAnimatedImageView *imageView1 = [FLAnimatedImageView new];
    imageView1.frame = CGRectMake(0, self.view.bounds.size.height / 3, self.view.bounds.size.width, self.view.bounds.size.height / 3);
    imageView1.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView1];
    
    FLAnimatedImageView *imageView2 = [FLAnimatedImageView new];
    imageView2.frame = CGRectMake(0, 2 * self.view.bounds.size.height / 3, self.view.bounds.size.width, self.view.bounds.size.height / 3);
    imageView2.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView2];
    
    NSURL *gifURL = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/3885450-f94ea2ba66ea1b2c.gif"];
    NSURL *staticWebPURL = [NSURL URLWithString:@"https://www.gstatic.com/webp/gallery/2.webp"];
    NSURL *animatedWebPURL = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/14783885-392024644087619a.gif?imageMogr2/auto-orient/strip/imageView2/2/w/440/format/webp"];
    
    
    [imageView sd_setImageWithURL:gifURL];
    
    [imageView1 sd_setImageWithURL:staticWebPURL placeholderImage:nil options:0 context:@{SDWebImageContextImageThumbnailPixelSize : @(CGSizeMake(300, 300))} progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            NSLog(@"%@", @"Static WebP load success");
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger maxFileSize = 4096;
            NSData *webpData = [SDImageWebPCoder.sharedCoder encodedDataWithImage:image format:SDImageFormatWebP options:@{SDImageCoderEncodeMaxFileSize : @(maxFileSize)}];
            if (webpData) {
                NSCAssert(webpData.length <= maxFileSize, @"WebP Encoding with max file size limit works");
                NSLog(@"%@", @"WebP encoding success");
            }
        });
    }];
    [imageView2 sd_setImageWithURL:animatedWebPURL placeholderImage:nil options:SDWebImageProgressiveLoad completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            NSLog(@"%@", @"Animated WebP load success");
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
