//
//  DXBaseRequest.m
//  Live
//
//  Created by wenjie hua on 2017/3/14.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "DXBaseRequest.h"
#import "RequestBaseManager.h"
#import <objc/runtime.h>

@implementation DXBaseRequest

- (YTKRequestMethod)requestMethod{
    return YTKRequestMethodPOST;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeGzip;
}

- (NSInteger)cacheTimeInSeconds{
    return 10.0;
}

- (NSDictionary *)createBaseArgument{
    if ([RequestBaseManager shareInstance].getBaseRequest) {
        [RequestBaseManager shareInstance].getBaseRequest();
    }
    return [[RequestBaseManager shareInstance] baseArgument];
}

- (void)startRequestWithCompletionBlockWithSuccess:(DXRequestSuccessBlock)success failure:(DXRequesrFailedBlock)failure {
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *dicResponse = request.responseJSONObject;
        if (dicResponse != nil) {
            
            NSString *codeStr;
            if ([[dicResponse objectForKey:@"code"] isKindOfClass:[NSNull class]] || [dicResponse objectForKey:@"code"] == nil) {
                codeStr = @"";
            } else {
                codeStr = [[dicResponse objectForKey:@"code"] stringValue];
            }
            
            // 返回码判断
            BOOL bsuccess = [codeStr isEqualToString:@"0"];
            if (bsuccess) {
                id result = [dicResponse objectForKey:@"data"];     // data可能为Dictionary / Array
                if (result) {
                    NSLog(@"=====SUCCESS=====\n请求接口 : %@\n请求参数 : %@\n=================\n",request.requestUrl,request.requestArgument);
                    if (success) {
                        success(result);
                    }
                } else {
                    if (success) {
                        success(nil);
                    }
                }
            } else {
                NSLog(@"=====ERROR=====\n请求接口 : %@\n请求参数 : %@\n返回主体 : %@\n=================\n",request.requestUrl,request.requestArgument,dicResponse);
                // 错误信息处理
                if (([RequestBaseManager shareInstance].dealSuccessNetEerror && [RequestBaseManager shareInstance].dealSuccessNetEerror(dicResponse))) {
                    return;
                }
                NSString *strErr = [dicResponse objectForKey:@"errmsg"];
                if ((id)strErr == [NSNull null] || strErr == nil || strErr.length == 0) {
                    strErr = @"请求失败";
                }
                
                if (failure) {
                    failure(strErr, codeStr, nil);
                }
            }
            
        } else {
            if (failure) {
                failure(@"服务器出错", @"nil", nil);
            }
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        NSLog(@"=====FAILURE=====\n请求接口 : %@\n请求参数 : %@\n返回主体 : %@\n=================\n",request.requestUrl,request.requestArgument,request.responseObject);
        
        NSInteger errorCode = ((NSHTTPURLResponse *)request.requestTask.response).statusCode;
        
        NSString *errmsg;
        
        // 网络断开情况
        if (errorCode == 0) {
            errmsg = @"网络不给力，请检查后重试";
        } else {
            if (errorCode == NSURLErrorTimedOut) {
                errmsg = @"网络不给力，请检查后重试";
            } else if (errorCode == NSURLErrorNotConnectedToInternet){
                errmsg = @"网络未连接，请检查网络设置";
            } else if (errorCode == NSURLErrorNetworkConnectionLost){
                errmsg = @"网络不稳定，连接丢失";
            } else if (errorCode == NSURLErrorCannotConnectToHost){
                errmsg = @"无法连接服务器";
            } else {
                errmsg = @"请求失败";
            }
        }
        if (failure) {
            failure(errmsg, nil, request.requestTask.error);
        }
    }];
}


- (id)requestArgument {
    NSMutableDictionary *mdic = [[NSMutableDictionary alloc] init];
    Class cls = [self class];
    unsigned int count;
    
    Ivar *vars = class_copyIvarList(cls, &count);
    
    for (int i = 0; i < count; i ++) {
        Ivar thisIvar = vars[i];
        
        const char* name = ivar_getName(thisIvar);  //获取成员变量的名字
        
        NSMutableString *ocName = [NSMutableString stringWithUTF8String:name];
        if ([ocName hasPrefix:@"_"]) {
            ocName = [NSMutableString stringWithString:[ocName substringFromIndex:1]];
        }
        
        
        if ([ocName isEqualToString:@"mid"]) {
            ocName = [[NSMutableString alloc]initWithString:@"id"];
        }
        
        NSString *key = [ocName copy];
        
        if ([self valueForKey:key] != nil && [[self valueForKey:key] isKindOfClass:[NSString class]]) {
            [mdic setObject:[self valueForKey:key] forKey:key];
        } else if (![[self valueForKey:key] isKindOfClass:[NSMutableArray class]] && [[self valueForKey:key] isKindOfClass:[NSArray class]]) {
            [mdic setObject:[self valueForKey:key] forKey:key];
        }else if ([self valueForKey:key] != nil && [[self valueForKey:key] isKindOfClass:[NSNumber class]]){
            [mdic setObject:[self valueForKey:key] forKey:key];
        }
    }
    free(vars);
    [mdic setValuesForKeysWithDictionary:[self createBaseArgument]];
    return (NSDictionary *)mdic;
}

@end
