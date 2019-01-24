//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGFirstPageRequest.h"

#import "NSBundle+SRGNetwork.h"
#import "SRGNetworkError.h"
#import "SRGNetworkParsers.h"
#import "SRGPage+Private.h"
#import "SRGPageRequest+Subclassing.h"

@implementation SRGFirstPageRequest

#pragma mark Class methods

+ (SRGFirstPageRequest *)dataRequestWithURLRequest:(NSURLRequest *)URLRequest
                                           session:(NSURLSession *)session
                                           options:(SRGRequestOptions)options
                                           builder:(SRGDataPageBuilder)builder
                                   completionBlock:(SRGDataPageCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest
                                          session:session
                                          options:options
                                           parser:nil
                                             page:nil
                                          builder:builder
                                  completionBlock:completionBlock];
}

+ (SRGFirstPageRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                session:(NSURLSession *)session
                                                options:(SRGRequestOptions)options
                                                builder:(SRGJSONArrayPageBuilder)builder
                                        completionBlock:(SRGJSONArrayPageCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest session:session options:options parser:^id _Nullable(NSData * _Nullable data, NSError *__autoreleasing *pError) {
        return SRGNetworkJSONArrayParser(data, pError);
    } page:nil builder:^NSURLRequest * _Nullable(id  _Nullable object, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
        return builder(response, size, number);
    } completionBlock:completionBlock];
}

+ (SRGFirstPageRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                     session:(NSURLSession *)session
                                                     options:(SRGRequestOptions)options
                                                     builder:(SRGJSONDictionaryPageBuilder)builder
                                             completionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest session:session options:options parser:^id _Nullable(NSData * _Nullable data, NSError *__autoreleasing *pError) {
        return SRGNetworkJSONDictionaryParser(data, pError);
    } page:nil builder:builder completionBlock:completionBlock];
}

#pragma mark Page management

- (SRGFirstPageRequest *)requestWithPageSize:(NSUInteger)pageSize
{
    NSURLRequest *URLRequest = [self URLRequestForPageWithSize:pageSize number:0];
    SRGPage *page = [[SRGPage alloc] initWithSize:pageSize number:0 URLRequest:URLRequest];
    return [self requestWithPage:page class:SRGFirstPageRequest.class];
}

- (SRGPageRequest *)requestWithPage:(SRGPage *)page
{
    return [self requestWithPage:page class:SRGPageRequest.class];
}

@end
