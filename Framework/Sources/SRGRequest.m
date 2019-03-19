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
                          completionBlock:(SRGDataCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest
                                          session:session
                                           parser:nil
                                        extractor:nil
                                  completionBlock:completionBlock];
}

+ (SRGRequest *)objectRequestWithURLRequest:(NSURLRequest *)URLRequest
                                    session:(NSURLSession *)session
                                     parser:(SRGResponseParser)parser
                            completionBlock:(SRGObjectCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest
                                          session:session
                                           parser:parser
                                        extractor:nil
                                  completionBlock:completionBlock];
}

+ (SRGRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest
                                       session:(NSURLSession *)session
                               completionBlock:(SRGJSONArrayCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest session:session parser:^id _Nullable(NSData *data, NSError * _Nullable __autoreleasing * _Nullable pError) {
        return SRGNetworkJSONArrayParser(data, pError);
    } extractor:nil completionBlock:completionBlock];
}

+ (SRGRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest
                                            session:(NSURLSession *)session
                                    completionBlock:(SRGJSONDictionaryCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest session:session parser:^id _Nullable(NSData *data, NSError * _Nullable __autoreleasing * _Nullable pError) {
        return SRGNetworkJSONDictionaryParser(data, pError);
    } extractor:nil completionBlock:completionBlock];
}

@end
