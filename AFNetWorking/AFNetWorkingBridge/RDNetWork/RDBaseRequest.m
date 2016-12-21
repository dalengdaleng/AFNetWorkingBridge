//
//  RDBaseRequest.m
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "RDBaseRequest.h"
#import "RDNetworkPrivate.h"
#import "RDNetworkAgent.h"

@implementation RDBaseRequest

// for subclasses to overwrite
- (void)requestCompleteFilter
{
}

- (void)requestFailedFilter
{
}

- (NSString *)requestUrl
{
    return @"";
}

- (NSString *)cdnUrl
{
    return @"";
}

- (NSString *)baseUrl
{
    return @"";
}

- (NSTimeInterval)requestTimeoutInterval
{
    return 60;
}

- (id)requestArgument
{
    return nil;
}

- (id)cacheFileNameFilterForRequestArgument:(id)argument
{
    return argument;
}

- (RDRequestMethod)requestMethod
{
    return RDRequestMethodGet;
}

- (RDRequestSerializerType)requestSerializerType
{
    return RDRequestSerializerTypeHTTP;
}

- (RDResponseSerializerType)responseSerializerType
{
    return RDResponseSerializerTypeJSON;
}

- (NSArray *)requestAuthorizationHeaderFieldArray
{
    return nil;
}

- (NSDictionary *)requestHeaderFieldValueDictionary
{
    return nil;
}

- (NSURLRequest *)buildCustomUrlRequest
{
    return nil;
}

- (BOOL)useCDN
{
    return NO;
}

- (id)jsonValidator
{
    return nil;
}

- (BOOL)statusCodeValidator
{
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <= 299) {
        return YES;
    } else {
        return NO;
    }
}

- (AFConstructingBlock)constructingBodyBlock
{
    return nil;
}

- (NSString *)resumableDownloadPath
{
    return nil;
}

- (AFDownloadProgressBlock)resumableDownloadProgressBlock
{
    return nil;
}

// append self to request queue
- (void)start
{
    [self toggleAccessoriesWillStartCallBack];
    [[RDNetworkAgent sharedInstance] addRequest:self];
}

// cancel self from request queue
- (void)stop
{
    [self toggleAccessoriesWillStopCallBack];
    self.delegate = nil;
    [[RDNetworkAgent sharedInstance] cancelRequest:self];
    [self toggleAccessoriesDidStopCallBack];
}

- (BOOL)isExecuting
{
    return self.requestOperation.isExecuting;
}

- (void)startWithCompletionBlockWithSuccess:(RDRequestCompletionBlock)success
                                    failure:(RDRequestCompletionBlock)failure
{
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(RDRequestCompletionBlock)success
                              failure:(RDRequestCompletionBlock)failure
{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (id)responseJSONObject {
    return self.requestOperation.responseObject;
}

- (NSData *)responseData {
    return self.requestOperation.responseData;
}

- (NSString *)responseString {
    return self.requestOperation.responseString;
}

- (NSInteger)responseStatusCode {
    return self.requestOperation.response.statusCode;
}

- (NSDictionary *)responseHeaders
{
    return self.requestOperation.response.allHeaderFields;
}

#pragma mark - Request Accessoies
- (void)addAccessory:(id<RDRequestAccessory>)accessory
{
    if (!self.requestAccessories)
    {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}

@end

@implementation RDBaseRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack {
    for (id<RDRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestWillStart:)]) {
            [accessory requestWillStart:self];
        }
    }
}

- (void)toggleAccessoriesWillStopCallBack {
    for (id<RDRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestWillStop:)]) {
            [accessory requestWillStop:self];
        }
    }
}

- (void)toggleAccessoriesDidStopCallBack {
    for (id<RDRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestDidStop:)]) {
            [accessory requestDidStop:self];
        }
    }
}

@end

@implementation RDTaskResponse

+ (RDTaskResponse *)responseWithObject:(id)aObject
{
    RDTaskResponse *response = [[RDTaskResponse alloc] init];
    
    if ([aObject isKindOfClass:[NSError class]])
    {
        NSError *error = (NSError *)aObject;
        [response setErrorCode:(int)error.code];
        [response setMessage:error.description];
        [response setStatus:RDTaskStatusFailed];
    }
    return response;
}
@end
