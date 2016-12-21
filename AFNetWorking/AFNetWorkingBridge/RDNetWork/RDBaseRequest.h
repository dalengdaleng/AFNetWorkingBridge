//
//  RDBaseRequest.h
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//
/*
 这个类是基类，用于封装AFNetWorking接口
*/

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFDownloadRequestOperation.h"

//http 请求类型
typedef NS_ENUM(NSInteger , RDRequestMethod) {
    RDRequestMethodGet = 0,
    RDRequestMethodPost,
    RDRequestMethodHead,
    RDRequestMethodPut,
    RDRequestMethodDelete,
    RDRequestMethodPatch
};

//请求的SerializerType
typedef NS_ENUM(NSInteger , RDRequestSerializerType) {
    RDRequestSerializerTypeHTTP = 0,
    RDRequestSerializerTypeJSON,
//    RDRequestSerializerTypeXML,
};

//返回的ResponseType
typedef NS_ENUM(NSInteger , RDResponseSerializerType) {
    RDResponseSerializerTypeHTTP = 0,
    RDResponseSerializerTypeJSON,
    RDResponseSerializerTypeXML
};

//post 富文件数据block
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
//断点续传，获得下载进度block
typedef void (^AFDownloadProgressBlock)(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);


@class RDBaseRequest;
typedef void(^RDRequestCompletionBlock)(__kindof RDBaseRequest *request);//Block回调

//定义协议方法，返回请求处理
@protocol RDRequestDelegate <NSObject>
@optional
- (void)requestFinished:(RDBaseRequest *)request;
- (void)requestFailed:(RDBaseRequest *)request;
- (void)clearRequest;
@end

//定义协议方法，处理请求
@protocol RDRequestAccessory <NSObject>
@optional
- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;
@end


@interface RDBaseRequest : NSObject
// Tag
@property (nonatomic) NSInteger tag;
// User info
@property (nonatomic, strong) NSDictionary *userInfo;
//AFNetWorking http处理定义
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
// request delegate object
@property (nonatomic, weak) id<RDRequestDelegate> delegate;
//server response
@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;
@property (nonatomic, strong, readonly) NSData *responseData;
@property (nonatomic, strong, readonly) NSString *responseString;
@property (nonatomic, strong, readonly) id responseJSONObject;
@property (nonatomic, readonly) NSInteger responseStatusCode;
//return UI block
@property (nonatomic, copy) RDRequestCompletionBlock successCompletionBlock;
@property (nonatomic, copy) RDRequestCompletionBlock failureCompletionBlock;
//more accessory
@property (nonatomic, strong) NSMutableArray *requestAccessories;

// append self to request queue
- (void)start;
// cancel self from request queue
- (void)stop;
//是否正在执行
- (BOOL)isExecuting;

// block回调
- (void)startWithCompletionBlockWithSuccess:(RDRequestCompletionBlock)success
                                    failure:(RDRequestCompletionBlock)failure;

- (void)setCompletionBlockWithSuccess:(RDRequestCompletionBlock)success
                              failure:(RDRequestCompletionBlock)failure;
// 清除block，block置nil来打破循环引用
- (void)clearCompletionBlock;
// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<RDRequestAccessory>)accessory;

// 以下方法由子类继承来覆盖默认值
// 请求成功的回调
- (void)requestCompleteFilter;
// 请求失败的回调
- (void)requestFailedFilter;
// 请求的URL
- (NSString *)requestUrl;
// 请求的CdnURL
- (NSString *)cdnUrl;
// 请求的BaseURL
- (NSString *)baseUrl;
// 请求的连接超时时间，默认为60秒
- (NSTimeInterval)requestTimeoutInterval;
// 请求的参数列表
- (id)requestArgument;
// 用于在cache结果，计算cache文件名时，忽略掉一些指定的参数
- (id)cacheFileNameFilterForRequestArgument:(id)argument;
// Http请求的方法
- (RDRequestMethod)requestMethod;
// 请求的SerializerType
- (RDRequestSerializerType)requestSerializerType;
// 返回的ResponseType
- (RDResponseSerializerType)responseSerializerType;
// 请求的Server用户名和密码
- (NSArray *)requestAuthorizationHeaderFieldArray;
// 在HTTP头添加的自定义参数
- (NSDictionary *)requestHeaderFieldValueDictionary;

// 构建自定义的UrlRequest，
// 若这个方法返回非nil对象，会忽略requestUrl, requestArgument, requestMethod, requestSerializerType
- (NSURLRequest *)buildCustomUrlRequest;

// 是否使用CDN的host地址
- (BOOL)useCDN;

// 用于检查JSON是否合法的对象
- (id)jsonValidator;

// 用于检查Status Code是否正常的方法
- (BOOL)statusCodeValidator;

// 当POST的内容带有文件等富文本时使用
- (AFConstructingBlock)constructingBodyBlock;

// 当需要断点续传时，指定续传的地址
- (NSString *)resumableDownloadPath;

// 当需要断点续传时，获得下载进度的回调
- (AFDownloadProgressBlock)resumableDownloadProgressBlock;
@end

@interface RDBaseRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

/**
 *  task返回的状态响应
 */
typedef NS_ENUM(NSUInteger, RDTaskStatus) {
    RDTaskStatusSuccess = 0,
    RDTaskStatusFailed,
    RDTaskStatusProcessing,
};

/**
 *  task response 结构，不同应用根据自己的协议方式解析数据
 */

@interface RDTaskResponse : NSObject

@property (assign, nonatomic) RDTaskStatus status;      // 任务状态
@property (assign, nonatomic) int errorCode;            // 错误码
@property (copy, nonatomic) NSString *message;          // 错误描述
@property (strong, nonatomic) id data;       // 数据

// 解析数据的函数
+ (RDTaskResponse *)responseWithObject:(id)aObject;

@end