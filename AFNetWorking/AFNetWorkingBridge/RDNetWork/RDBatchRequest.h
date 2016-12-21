//
//  RDBatchRequest.h
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDRequest.h"

@class RDBatchRequest;
@protocol RDBatchRequestDelegate <NSObject>
@optional
- (void)batchRequestFinished:(RDBatchRequest *)batchRequest;
- (void)batchRequestFailed:(RDBatchRequest *)batchRequest;
@end

@interface RDBatchRequest : NSObject
@property (strong, nonatomic, readonly) NSArray *requestArray;

@property (weak, nonatomic) id<RDBatchRequestDelegate> delegate;

@property (nonatomic, copy) void (^successCompletionBlock)(RDBatchRequest *);

@property (nonatomic, copy) void (^failureCompletionBlock)(RDBatchRequest *);

@property (nonatomic) NSInteger tag;

@property (nonatomic, strong) NSMutableArray *requestAccessories;

- (id)initWithRequestArray:(NSArray *)requestArray;

- (void)start;

- (void)stop;

/// block回调
- (void)startWithCompletionBlockWithSuccess:(void (^)(RDBatchRequest *batchRequest))success
                                    failure:(void (^)(RDBatchRequest *batchRequest))failure;

- (void)setCompletionBlockWithSuccess:(void (^)(RDBatchRequest *batchRequest))success
                              failure:(void (^)(RDBatchRequest *batchRequest))failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<RDRequestAccessory>)accessory;

/// 是否当前的数据从缓存获得
- (BOOL)isDataFromCache;

@end

@interface RDBatchRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end
