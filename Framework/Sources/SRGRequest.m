//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGRequest.h"

#import "SRGBaseRequest+Subclassing.h"
#import "SRGNetworkParsers.h"

@implementation SRGRequest

#pragma mark Class methods

+ (SRGRequest *)dataRequestWithURLRequest:(NSURLRequest *)URLRequest
                                  session:(NSURLSession *)session
                                  options:(SRGRequestOptions)options
                          completionBlock:(SRGDataCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest
                                          session:session
                                          options:options
                                           parser:nil
                                  completionBlock:completionBlock];
}

+ (SRGRequest *)objectRequestWithURLRequest:(NSURLRequest *)URLRequest
                                    session:(NSURLSession *)session
                                    options:(SRGRequestOptions)options
                                     parser:(SRGResponseParser)parser
                            completionBlock:(SRGObjectCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest
                                          session:session
                                          options:options
                                           parser:parser
                                  completionBlock:completionBlock];
}

+ (SRGRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest
                                       session:(NSURLSession *)session
                                       options:(SRGRequestOptions)options
                               completionBlock:(SRGJSONArrayCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest session:session options:options parser:^id _Nullable(NSData *data, NSError * _Nullable __autoreleasing * _Nullable pError) {
        return SRGNetworkJSONArrayParser(data, pError);
    } completionBlock:completionBlock];
}

+ (SRGRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest
                                            session:(NSURLSession *)session
                                            options:(SRGRequestOptions)options
                                    completionBlock:(SRGJSONDictionaryCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest session:session options:options parser:^id _Nullable(NSData *data, NSError * _Nullable __autoreleasing * _Nullable pError) {
        return SRGNetworkJSONDictionaryParser(data, pError);
    } completionBlock:completionBlock];
}

@end
