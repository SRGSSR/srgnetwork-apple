//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGPageRequest.h"

#import "SRGBaseRequest+Subclassing.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Methods to be used when implementing a `SRGPageRequest` subclass.
 */
@interface SRGPageRequest (Subclassing)

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                           options:(SRGRequestOptions)options
                            parser:(nullable SRGResponseParser)parser
                              page:(nullable SRGPage *)page
                             sizer:(SRGPageSizer)sizer
                         paginator:(SRGObjectPaginator)paginator
                   completionBlock:(SRGObjectPageCompletionBlock)completionBlock;

- (NSURLRequest *)URLRequestForFirstPageWithSize:(NSUInteger)size;
- (__kindof SRGPageRequest *)requestWithPage:(nullable SRGPage *)page class:(Class)cls;

@end

NS_ASSUME_NONNULL_END
