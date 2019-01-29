//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGPageRequest.h"

#import "SRGBaseRequest+Subclassing.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Methods accessible to `SRGPageRequest` subclasses.
 */
@interface SRGPageRequest (Subclassing)

/**
 *  Create a request started with the provided session and options, calling the specified block on completion. Pagination
 *  requires a sizer (defines how the original request is tuned to change its page size to another value) as well as a
 *  paginator (defines how subsequent pages of results are loaded).
 *
 *  @param URLRequest      The request to execute.
 *  @param session         The session for which the request is executed.
 *  @param parser          An optional parser. If no error is returned (by reference), the extracted object will be
 *                         returned to the completion block, otherwise an error will be returned instead.
 *  @param page            The page to associate the request with.
 *  @param sizer           A block through which the original request can be tuned for other page sizes.
 *  @param paginator       A block to build or extract the URL request needed to load another page of content.
 *  @param completionBlock The completion block which will be called when the request ends.
 */
- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                            parser:(nullable SRGResponseParser)parser
                              page:(nullable SRGPage *)page
                             sizer:(SRGPageSizer)sizer
                         paginator:(SRGObjectPaginator)paginator
                   completionBlock:(SRGObjectPageCompletionBlock)completionBlock;

/**
 *  Return the URL request needed to load the first page of content with a given size.
 */
- (NSURLRequest *)URLRequestForFirstPageWithSize:(NSUInteger)size;

/**
 *  Return the request for loading the specified page of content (first one if `nil`), with the specified
 *  class.
 *
 *  @discussion The class must be a `SRGPageRequest` or a subclass of it, otherwise the behavior is undefined.
 */
- (__kindof SRGPageRequest *)requestWithPage:(nullable SRGPage *)page class:(Class)cls;

@end

NS_ASSUME_NONNULL_END
