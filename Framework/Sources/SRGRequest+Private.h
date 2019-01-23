//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGRequest+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRGRequest (Private)

// Agnostic block signatures.
typedef void (^SRGObjectCompletionBlock)(id _Nullable object, NSURLResponse * _Nullable response, NSError * _Nullable error);

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                           options:(SRGRequestOptions)options
                            parser:(nullable SRGResponseParser)parser
                   completionBlock:(SRGObjectCompletionBlock)completionBlock;

@property (nonatomic, readonly, copy) void (^completionBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@end

NS_ASSUME_NONNULL_END
