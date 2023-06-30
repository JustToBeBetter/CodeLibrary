//
//  FaceDetectionViewController.h
//  MNNKitDemo
//
//  Created by tsia on 2019/12/24.
//  Copyright © 2019 tsia. All rights reserved.
//

#import "VideoBaseViewController.h"
#import "Live2DView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FaceDetectionViewController : VideoBaseViewController
{
    @protected Live2DView *_live2dView;
}
@property (strong, nonatomic,nullable) Live2DView *live2dView;

@property (nonatomic, copy) void (^sendL2dDataCallBack)(NSArray *dataArray);

@end

NS_ASSUME_NONNULL_END
