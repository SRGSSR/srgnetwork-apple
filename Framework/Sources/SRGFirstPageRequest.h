//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGPageRequest.h"

NS_ASSUME_NONNULL_BEGIN

// Page builder block signatures.
typedef NSURLRequest * _Nullable (^SRGDataPageBuilder)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number, NSURLRequest *firstPageURLRequest);
typedef NSURLRequest * _Nullable (^SRGJSONArrayPageBuilder)(NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number, NSURLRequest *firstPageURLRequest);
typedef NSURLRequest * _Nullable (^SRGJSONDictionaryPageBuilder)(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number, NSURLRequest *firstPageURLRequest);

// Completion block signatures.
typedef void (^SRGDataPageCompletionBlock)(NSData * _Nullable data, SRGPage *page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void (^SRGJSONArrayPageCompletionBlock)(NSArray * _Nullable JSONArray, SRGPage *page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void (^SRGJSONDictionaryPageCompletionBlock)(NSDictionary * _Nullable JSONDictionary, SRGPage *page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error);

/**
 *  Request for the first page of a list of results.
 */
@interface SRGFirstPageRequest : SRGPageRequest

/**
 *  Convenience initializers for requests started with the provided session and options, calling the specified block
 *  on completion. Note that JSON requests will fail with an error if the data cannot be parsed in the expected format.
 *
 *  @param URLRequest      The request to execute.
 *  @param session         The session for which the request is executed.
 *  @param options         Options to apply (0 if none).
 *  @param builder         A block with which the URL request for a next page can be built from response information, or
 *                         directly from the first page URL request.
 *  @param completionBlock The completion block which will be called when the request ends.
 *
 *  @discussion Blocks will likely be called on a background thread (this depends on how the session was configured).
 */
+ (SRGFirstPageRequest *)dataRequestWithURLRequest:(NSURLRequest *)URLRequest
                                           session:(NSURLSession *)session
                                           options:(SRGRequestOptions)options
                                           builder:(SRGDataPageBuilder)builder
                                   completionBlock:(SRGDataPageCompletionBlock)completionBlock;

+ (SRGFirstPageRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                session:(NSURLSession *)session
                                                options:(SRGRequestOptions)options
                                                builder:(SRGJSONArrayPageBuilder)builder
                                        completionBlock:(SRGJSONArrayPageCompletionBlock)completionBlock;

+ (SRGFirstPageRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                     session:(NSURLSession *)session
                                                     options:(SRGRequestOptions)options
                                                     builder:(SRGJSONDictionaryPageBuilder)builder
                                             completionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock;

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
