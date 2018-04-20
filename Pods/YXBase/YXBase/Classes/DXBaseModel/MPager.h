//
//  MPager.h
//  Live
//
//  Created by wenjie hua on 2017/3/28.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "DXModel.h"

@interface MPager : DXModel

/**
 页码
 */
@property (nonatomic, strong) NSNumber *pageNo;

/**
 每页个数
 */
@property (nonatomic, strong) NSNumber *pageSize;

/**
 总记录数
 */
@property (nonatomic, strong) NSNumber *records;

/**
 总页数
 */
@property (nonatomic, strong) NSNumber *pages;

/**
 是否是第一页
 */
@property (nonatomic, assign) BOOL firstPage;

/**
 是否最后一页
 */
@property (nonatomic, assign) BOOL lastPage;

@end
