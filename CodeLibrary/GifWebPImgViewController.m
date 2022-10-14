//
//  GifWebPImgViewController.m
//  CodeLibrary
//
//  Created by 李金柱 on 2021/2/24.
//  Copyright © 2021 李金柱. All rights reserved.
//

#import "GifWebPImgViewController.h"
#import "MMAvatarView.h""

@interface GifWebPImgViewController ()

@end

@implementation GifWebPImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    self.view.backgroundColor = UIColor.whiteColor;
    [[SDImageCodersManager sharedManager] addCoder:[SDImageWebPCoder sharedCoder]];
    [[SDWebImageDownloader sharedDownloader] setValue:@"image/webp,image/*,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [self testUI];
}
- (void)testUI{
    NSArray *webpArray =   @[@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-09-29/1664433922363.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-09-21/1663745765475.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-09-21/1663745030591.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-08-30/1661843657224.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-08-06/1659764421354.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-06-29/1656491704481.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-04-21/1650534806109.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-03-25/1648179332124.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-02-25/1645756808205.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642646112541.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642644460847.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642643766102.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642645941636.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642646465626.webp"];
    CGFloat imgW = 100;
    NSInteger numPerLine = 3;
    CGFloat space = (self.view.width - imgW * numPerLine)/(numPerLine + 1);
    for (int i = 0;  i < 12; i++) {
        MMAvatarView *avatarView = [[MMAvatarView alloc]initWithFrame:CGRectMake(space + imgW *(i%numPerLine), 100 + imgW *(i/numPerLine), imgW, imgW)];
        avatarView.contentMode = UIViewContentModeScaleAspectFit;
        NSString *micurl = @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-06-29/1656491704481.webp";
        if (i < webpArray.count-1) {
            micurl = webpArray[i];
        }
        [avatarView showWithUid:0 avatar:@"http://murder-mystery.oss-cn-shanghai.aliyuncs.com/th_nGDiObuIKJ.jpg" backgroundAvatar:@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2021-09-24/1632481127406.gif" clickBlock:^{
        }];
        [avatarView loadMicImgWithMicUrl:micurl showLevle:0];
        [avatarView showMicphoneImg:YES];
        [self.view addSubview:avatarView];
        
//        SDAnimatedImageView *imageView = [[SDAnimatedImageView alloc]initWithFrame:CGRectMake(space + imgW *(i%numPerLine), 100 + imgW *(i/numPerLine), imgW, imgW)];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        NSURL *url = [NSURL URLWithString:@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-06-29/1656491704481.webp"];
//        if (i < webpArray.count-1) {
//            url = [NSURL URLWithString:webpArray[i]];
//        }
//        [imageView sd_setImageWithURL:url];
//        [self.view addSubview:imageView];
    }
}
- (void)initUI{
    
    /*动态web http://littlesvr.ca/apng/images/world-cup-2014-42.webp
             https://upload-images.jianshu.io/upload_images/14783885-392024644087619a.gif?imageMogr2/auto-orient/strip/imageView2/2/w/440/format/webp
    **/
    
    /*静态web https://www.gstatic.com/webp/gallery/2.webp **/
    
    /*gif https://upload-images.jianshu.io/upload_images/3885450-f94ea2ba66ea1b2c.gif **/

    
    SDAnimatedImageView *imageView = [SDAnimatedImageView new];
    imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 3);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    
    FLAnimatedImageView *imageView1 = [FLAnimatedImageView new];
    imageView1.frame = CGRectMake(0, self.view.bounds.size.height / 3, self.view.bounds.size.width, self.view.bounds.size.height / 3);
    imageView1.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView1];
    
    SDAnimatedImageView *imageView2 = [SDAnimatedImageView new];
    imageView2.frame = CGRectMake(0, 2 * self.view.bounds.size.height / 3, self.view.bounds.size.width, self.view.bounds.size.height / 3);
    imageView2.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView2];
    
    NSURL *gifURL = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/3885450-f94ea2ba66ea1b2c.gif"];
    NSURL *staticWebPURL = [NSURL URLWithString:@"https://www.gstatic.com/webp/gallery/2.webp"];
    NSURL *animatedWebPURL = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/14783885-392024644087619a.gif?imageMogr2/auto-orient/strip/imageView2/2/w/440/format/webp"];
    
    gifURL = [NSURL URLWithString:@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-06-29/1656491704481.webp"];
    staticWebPURL = [NSURL URLWithString:@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-06-29/1656491704481.webp"];
    animatedWebPURL = [NSURL URLWithString:@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-06-29/1656491704481.webp"];
    
    [imageView sd_setImageWithURL:gifURL];
    
    [imageView1 sd_setImageWithURL:staticWebPURL placeholderImage:nil options:0 context:@{SDWebImageContextImageThumbnailPixelSize : @(CGSizeMake(300, 300))} progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            NSLog(@"%@", @"Static WebP load success");
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger maxFileSize = 4096;
            NSData *webpData = [SDImageWebPCoder.sharedCoder encodedDataWithImage:image format:SDImageFormatWebP options:@{SDImageCoderEncodeMaxFileSize : @(maxFileSize)}];
            if (webpData) {
                DDLogInfo(@"webpData length:%ld",webpData.length);
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
