//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGNetworkTypes.h"
#import "SRGPageRequest.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Request for the first page of a list of results. Once an `SRGFirstPageRequest` has been properly created, you can
 *  change the desired size for a page of results (`-requestWithPageSize:`).
 *
 *  When initializing a request with pagination, two blocks are required:
 *    - A sizer, which defines how the original request is tuned to change its page size to another value. This block
 *      is only called for page sizes different from `SRGPageUnspecifiedSize`.
 *    - A paginator, which defines how subsequent pages of results are loaded, and which is called each time a request
 *      with pagination support ends. When implementing this block, you might need to check whether a page size has
 *      been specified or not (`SRGPageUnspecifiedSize`).
 *
 *  You never instantiate page objects yourself, though, you merely receive them in the completion block of a request
 *  supporting pagination. Subsequent pages can then be retrieved by calling `-requestWithPage:` and executing the
 *  returned request.
 *
 *  Requests are not started by default. Once you have an `SRGFirstPageRequest` or `SRGPageRequest` instance, call
 *  the `-resume` method to start the request. A started request keeps itself alive while it is running. You can
 *  therefore execute a request "locally" in your code, without keeping a reference to it (but this makes it impossible
 *  to cancel the request manually afterwards). If you want to be able to cancel a request, keep a reference to it.
 *
 *  To manage several related requests, use an `SRGRequestQueue`.
 */
@interface SRGFirstPageRequest : SRGPageRequest

/**
 *  Data request started with the provided session, calling the specified block on completion.
 */
+ (SRGFirstPageRequest *)dataRequestWithURLRequest:(NSURLRequest *)URLRequest
                                           session:(NSURLSession *)session
                                             sizer:(SRGPageSizer)sizer
                                         paginator:(SRGDataPaginator)paginator
                                   completionBlock:(SRGDataPageCompletionBlock)completionBlock;

/**
 *  Request started with the provided session, calling the specified block on completion, and returning the response as
 *  a JSON array.
 *
 *  @discussion An error is returned to the completion block if the response could not be transformed into a JSON
 *              array.
 */
+ (SRGFirstPageRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                session:(NSURLSession *)session
                                                  sizer:(SRGPageSizer)sizer
                                              paginator:(SRGJSONArrayPaginator)paginator
                                        completionBlock:(SRGJSONArrayPageCompletionBlock)completionBlock;

/**
 *  Request started with the provided session, calling the specified block on completion, and returning the response as
 *  a JSON dictionary.
 *
 *  @discussion An error is returned to the completion block if the response could not be transformed into a JSON
 *              dictionary.
 */
+ (SRGFirstPageRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                     session:(NSURLSession *)session
                                                       sizer:(SRGPageSizer)sizer
                                                   paginator:(SRGJSONDictionaryPaginator)paginator
                                             completionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock;

/**
 *  Object request started with the provided session, turning the response into an object through a mandatory parsing
 *  block (if response data is retrieved), and calling the specified block on completion.
 *
 *  If helpful, some standard basic parsers are available from <SRGNetwork/SRGNetworkParsers.h>.
 *
 *  @discussion An error is returned to the completion block if parsing fails. The parsing block will be called on a
 *              background thread (except if the session is configured with the main operation queue, which is best
 *              avoided).
 */
+ (SRGFirstPageRequest *)objectRequestWithURLRequest:(NSURLRequest *)URLRequest
                                             session:(NSURLSession *)session
                                              parser:(SRGResponseParser)parser
                                               sizer:(SRGPageSizer)sizer
                                           paginator:(SRGObjectPaginator)paginator
                                     completionBlock:(SRGObjectPageCompletionBlock)completionBlock;

/**
 *  Return an equivalent request, but with the specified page size.
 *
 *  @param pageSize The page size to use. Options applied to the original request are preserved.
 */
- (SRGFirstPageRequest *)requestWithPageSize:(NSUInteger)pageSize;

/**
 *  Return an equivalent request, but for the specified page.
 *
 *  @param page The page to request. If `nil`, the first page is requested (for the same page size as the receiver).
 *
 *  @discussion The `-requestWithPage:` method must be called on a related request, otherwise the behavior is undefined.
 *              Options applied to the original request are preserved.
 */
- (SRGPageRequest *)requestWithPage:(nullable SRGPage *)page;

@end

NS_ASSUME_NONNULL_END
