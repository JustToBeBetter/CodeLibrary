//
//  FaceDetectView.h
//  MNNKitDemo
//
//  Created by tsia on 2019/12/24.
//  Copyright © 2019 tsia. All rights reserved.
//

#import "VideoBaseDetectView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FaceDetectView : VideoBaseDetectView

@property (nonatomic, assign) BOOL showPointOrder;

@property (nonatomic, assign) BOOL useRedColor;

@end

NS_ASSUME_NONNULL_END
