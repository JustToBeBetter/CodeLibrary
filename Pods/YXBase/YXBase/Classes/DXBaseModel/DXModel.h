//
//  DXModel.h
//  Live
//  基础模型
//  具备自转换能力：dic->model / arr->model
//  Created by 戴奕 on 2017/3/24.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXModel : NSObject

/**
 一般没有数组数据的Model直接使用，有数组的Model的子类重写这个方法
 
 @param dic 数据解析之后得到的字典
 
 @return 返回Model类
 */
- (instancetype)initWithDic:(NSDictionary *)dic;

/**
 数组类直接使用该方法
 
 @param arr 数据解析后得到的数组
 
 @return 数组信息
 */
+ (NSArray *)modelsFromArr:(NSArray *)arr;

@end
