//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

// Completion block signatures.
typedef void (^SRGDataCompletionBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void (^SRGJSONArrayCompletionBlock)(NSArray * _Nullable JSONArray, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void (^SRGJSONDictionaryCompletionBlock)(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error);

/**
 *  `SRGRequest` objects provide a way to manage the data retrieval process associated with a data provider 
 *  service request. You never instantiate `SRGRequest` objects directly, you merely use the ones returned 
 *  when calling `SRGDataProvider` service methods.
 *
 *  Requests are not started by default. Once you have an `SRGRequest` instance, call the `-resume` method
 *  to start the request. A started request keeps itself alive while it is running. You can therefore execute
 *  a request "locally" in your code, without keeping a reference to it (but this makes it impossible to cancel
 *  the request manually afterwards). If you want to be able to cancel a request, keep a reference to it. 
 *
 *  To manage several related requests, use an `SRGRequestQueue`.
 */
@interface SRGRequest : SRGBaseRequest

/**
 *  Convenience initializers for requests started with the provided session and options, calling the specified block
 *  on completion. Note that JSON requests will fail with an error if the data cannot be parsed in the expected format.
 *
 *  @param URLRequest      The request to execute.
 *  @param session         The session for which the request is executed.
 *  @param options         Options to apply (0 if none).
 *  @param completionBlock The completion block which will be called when the request ends.
 *
 *  @discussion The block will likely be called on a background thread (this depends on how the session was configured).
 */
+ (SRGRequest *)dataRequestWithURLRequest:(NSURLRequest *)URLRequest
                                  session:(NSURLSession *)session
                                  options:(SRGRequestOptions)options
                          completionBlock:(SRGDataCompletionBlock)completionBlock;

+ (SRGRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest
                                            session:(NSURLSession *)session
                                            options:(SRGRequestOptions)options
                                    completionBlock:(SRGJSONDictionaryCompletionBlock)completionBlock;

+ (SRGRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest
                                       session:(NSURLSession *)session
                                       options:(SRGRequestOptions)options
                               completionBlock:(SRGJSONArrayCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
