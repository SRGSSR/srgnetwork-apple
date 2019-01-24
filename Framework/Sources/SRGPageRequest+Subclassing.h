//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGPageRequest.h"

#import "SRGBaseRequest+Subclassing.h"

NS_ASSUME_NONNULL_BEGIN

// Block signatures.
typedef NSURLRequest * _Nullable (^SRGObjectPageBuilder)(id _Nullable object, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number, NSURLRequest *firstPageURLRequest);
typedef void (^SRGObjectPageCompletionBlock)(id _Nullable object, SRGPage *page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error);

/**
 *  Methods to be used when implementing a `SRGPageRequest` subclass.
 */
@interface SRGPageRequest (Subclassing)

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                           options:(SRGRequestOptions)options
                            parser:(nullable SRGResponseParser)parser
                              page:(nullable SRGPage *)page
                           builder:(SRGObjectPageBuilder)builder
                   completionBlock:(SRGObjectPageCompletionBlock)completionBlock;

@property (nonatomic, readonly, copy) SRGObjectPageBuilder builder;
@property (nonatomic, readonly, copy) SRGObjectPageCompletionBlock pageCompletionBlock;

@end

NS_ASSUME_NONNULL_END
