//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGFirstPageRequest.h"

#import "SRGNetworkError.h"
#import "SRGNetworkParsers.h"
#import "SRGPage+Private.h"
#import "SRGPageRequest+Subclassing.h"

@implementation SRGFirstPageRequest

#pragma mark Class methods

+ (SRGFirstPageRequest *)dataRequestWithURLRequest:(NSURLRequest *)URLRequest
                                           session:(NSURLSession *)session
                                             sizer:(SRGPageSizer)sizer
                                         paginator:(SRGDataPaginator)paginator
                                   completionBlock:(SRGDataPageCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest
                                          session:session
                                           parser:nil
                                             page:nil
                                            sizer:sizer
                                        paginator:paginator
                                  completionBlock:completionBlock];
}

+ (SRGFirstPageRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                session:(NSURLSession *)session
                                                  sizer:(SRGPageSizer)sizer
                                              paginator:(SRGJSONArrayPaginator)paginator
                                        completionBlock:(SRGJSONArrayPageCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest session:session parser:^id _Nullable(NSData *data, NSError *__autoreleasing *pError) {
        return SRGNetworkJSONArrayParser(data, pError);
    } page:nil sizer:sizer paginator:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull URLRequest, id  _Nullable object, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
        return paginator(URLRequest, response, size, number);
    } completionBlock:completionBlock];
}

+ (SRGFirstPageRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                     session:(NSURLSession *)session
                                                       sizer:(SRGPageSizer)sizer
                                                   paginator:(SRGJSONDictionaryPaginator)paginator
                                             completionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest session:session parser:^id _Nullable(NSData *data, NSError *__autoreleasing *pError) {
        return SRGNetworkJSONDictionaryParser(data, pError);
    } page:nil sizer:sizer paginator:paginator completionBlock:completionBlock];
}

+ (SRGFirstPageRequest *)objectRequestWithURLRequest:(NSURLRequest *)URLRequest
                                             session:(NSURLSession *)session
                                              parser:(SRGResponseParser)parser
                                               sizer:(SRGPageSizer)sizer
                                           paginator:(SRGObjectPaginator)paginator
                                     completionBlock:(SRGObjectPageCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest
                                          session:session
                                           parser:parser
                                             page:nil
                                            sizer:sizer
                                        paginator:paginator
                                  completionBlock:completionBlock];
}

#pragma mark Page management

- (SRGFirstPageRequest *)requestWithPageSize:(NSUInteger)pageSize
{
    NSURLRequest *URLRequest = [self URLRequestForFirstPageWithSize:pageSize];
    SRGPage *page = [[SRGPage alloc] initWithSize:pageSize number:0 URLRequest:URLRequest];
    return [self requestWithPage:page class:SRGFirstPageRequest.class];
}

- (SRGPageRequest *)requestWithPage:(SRGPage *)page
{
    return [self requestWithPage:page class:SRGPageRequest.class];
}

@end
