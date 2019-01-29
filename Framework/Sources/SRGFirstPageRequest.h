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
 *  When initializing a request with pagination, two blocks are required (which might not be called on the main thread,
 *  depending on how the session was configured):
 *    - A sizer, which defines how the original request is tuned to change its page size to another value.
 *    - A paginator, which defines how subsequent pages of results are loaded.
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
 *  Data request started with the provided session and options, calling the specified block on completion.
 *
 *  @discussion The completion block will likely be called on a background thread (this depends on how the session was
 *              configured).
 */
+ (SRGFirstPageRequest *)dataRequestWithURLRequest:(NSURLRequest *)URLRequest
                                           session:(NSURLSession *)session
                                           options:(SRGRequestOptions)options
                                             sizer:(SRGPageSizer)sizer
                                         paginator:(SRGDataPaginator)paginator
                                   completionBlock:(SRGDataPageCompletionBlock)completionBlock;

/**
 *  Request started with the provided session and options, calling the specified block on completion, and returning
 *  the response as a JSON array.
 *
 *  @discussion An error is returned to the completion block if the response could not be transformed into a JSON
 *              array. The completion block will likely be called on a background thread (this depends on how the
 *              session was configured).
 */
+ (SRGFirstPageRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                session:(NSURLSession *)session
                                                options:(SRGRequestOptions)options
                                                  sizer:(SRGPageSizer)sizer
                                              paginator:(SRGJSONArrayPaginator)paginator
                                        completionBlock:(SRGJSONArrayPageCompletionBlock)completionBlock;

/**
 *  Request started with the provided session and options, calling the specified block on completion, and returning
 *  the response as a JSON dictionary.
 *
 *  @discussion An error is returned to the completion block if the response could not be transformed into a JSON
 *              dictionary. The completion block will likely be called on a background thread (this depends on how
 *              the session was configured).
 */
+ (SRGFirstPageRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                     session:(NSURLSession *)session
                                                     options:(SRGRequestOptions)options
                                                       sizer:(SRGPageSizer)sizer
                                                   paginator:(SRGJSONDictionaryPaginator)paginator
                                             completionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock;

/**
 *  Object request started with the provided session and options, turning the response into an object through a mandatory
 *  parsing block (if response data is retrieved), and calling the specified block on completion.
 *
 *  @discussion An error is returned to the completion block if parsing fails. The parsing and completion blocks will
 *              likely be called on a background thread (this depends on how the session was configured).
 */
+ (SRGFirstPageRequest *)objectRequestWithURLRequest:(NSURLRequest *)URLRequest
                                             session:(NSURLSession *)session
                                             options:(SRGRequestOptions)options
                                              parser:(SRGResponseParser)parser
                                               sizer:(SRGPageSizer)sizer
                                           paginator:(SRGObjectPaginator)paginator
                                     completionBlock:(SRGObjectPageCompletionBlock)completionBlock;

/**
 *  Return an equivalent request, but with the specified page size.
 *
 *  @param pageSize The page size to use.
 */
- (SRGFirstPageRequest *)requestWithPageSize:(NSUInteger)pageSize;

/**
 *  Return an equivalent request, but for the specified page.
 *
 *  @param page The page to request. If `nil`, the first page is requested (for the same page size as the receiver).
 *
 *  @discussion The `-requestWithPage:` method must be called on a related request, otherwise the behavior is undefined.
 */
- (SRGPageRequest *)requestWithPage:(nullable SRGPage *)page;

@end

NS_ASSUME_NONNULL_END
