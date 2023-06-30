//
//  MMAuthorizationHelper.h


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMAuthorizationHelper : NSObject

//相册权限
+ (void)requestAblumAuthorityWithCompletionHandler:(void (^)(NSError *_Nullable error))handler;

//照相机\麦克风权限
+ (BOOL)requestMediaCapturerAccessWithHandler:(void (^)(NSError *_Nullable error))handler;

@end

NS_ASSUME_NONNULL_END
