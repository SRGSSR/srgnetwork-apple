//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGNetworkTypes.h"
#import "SRGPageRequest.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Request for the first page of a list of results.
 */
@interface SRGFirstPageRequest : SRGPageRequest

/**
 *  Data request started with the provided session and options, calling the specified block on completion. Pagination
 *  requires a seed (defines how the original request is tuned to alter its page size to another value) as well as a
 *  paginator (defines how subsequent pages of results are loaded).
 *
 *  @discussion The completion block will likely be called on a background thread (this depends on how the session was
 *              configured).
 */
+ (SRGFirstPageRequest *)dataRequestWithURLRequest:(NSURLRequest *)URLRequest
                                           session:(NSURLSession *)session
                                           options:(SRGRequestOptions)options
                                              seed:(SRGDataPageSeed)seed
                                         paginator:(SRGDataPaginator)paginator
                                   completionBlock:(SRGDataPageCompletionBlock)completionBlock;

/**
 *  Request started with the provided session and options, calling the specified block on completion, and returning
 *  the response as a JSON array. Pagination requires a seed (defines how the original request is tuned to alter its
 *  page size to another value) as well as a paginator (defines how subsequent pages of results are loaded).
 *
 *  @discussion An error is returned to the completion block if the response could not be transformed into a JSON
 *              array. The completion block will likely be called on a background thread (this depends on how the
 *              session was configured).
 */

+ (SRGFirstPageRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                session:(NSURLSession *)session
                                                options:(SRGRequestOptions)options
                                                   seed:(SRGDataPageSeed)seed
                                              paginator:(SRGJSONArrayPaginator)paginator
                                        completionBlock:(SRGJSONArrayPageCompletionBlock)completionBlock;

/**
 *  Request started with the provided session and options, calling the specified block on completion, and returning
 *  the response as a JSON dictionary. Pagination requires a seed (defines how the original request is tuned to alter
 *  its page size to another value) as well as a paginator (defines how subsequent pages of results are loaded).
 *
 *  @discussion An error is returned to the completion block if the response could not be transformed into a JSON
 *              dictionary. The completion block will likely be called on a background thread (this depends on how
 *              the session was configured).
 */
+ (SRGFirstPageRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                     session:(NSURLSession *)session
                                                     options:(SRGRequestOptions)options
                                                        seed:(SRGJSONDictionaryPageSeed)seed
                                                   paginator:(SRGJSONDictionaryPaginator)paginator
                                             completionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock;

/**
 *  Object request started with the provided session and options, turning the response into an object through a mandatory
 *  parsing block, and calling the specified block on completion. Pagination requires a seed (defines how the original
 *  request is tuned to alter its page size to another value) as well as a paginator (defines how subsequent pages of
 *  results are loaded).
 *
 *  @discussion An error is returned to the completion block if parsing fails. The parsing and completion blocks will
 *              likely be called on a background thread (this depends on how the session was configured).
 */
+ (SRGFirstPageRequest *)objectRequestWithURLRequest:(NSURLRequest *)URLRequest
                                             session:(NSURLSession *)session
                                             options:(SRGRequestOptions)options
                                              parser:(SRGResponseParser)parser
                                                seed:(SRGObjectPageSeed)seed
                                           paginator:(SRGObjectPaginator)paginator
                                     completionBlock:(SRGObjectPageCompletionBlock)completionBlock;

/**
 *  Return an equivalent request, but with the specified page size.
 *
 *  @param pageSize The page size to use.
 */
- (SRGFirstPageRequest *)requestWithPageSize:(NSUInteger)pageSize;

/**
 *  Return an equivalent request, but for the specified page. You never instantiate pages yourself, you receive them
 *  in the completion block of a request supporting pagination. Subsequent pages can then be retrieved by calling this
*   method and executing the returned request.
 *
 *  @param page The page to request. If `nil`, the first page is requested (for the same page size as the receiver).
 *
 *  @discussion The `-requestWithPage:` method must be called on a related request, otherwise the behavior is undefined.
 */
- (SRGPageRequest *)requestWithPage:(nullable SRGPage *)page;

@end

NS_ASSUME_NONNULL_END
