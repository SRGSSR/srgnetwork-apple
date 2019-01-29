//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGBaseRequest.h"
#import "SRGNetworkTypes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Simple request to retrieve data from the network.
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
 *  Data request started with the provided session, calling the specified block on completion.
 *
 *  @discussion The completion block will likely be called on a background thread (this depends on how the session was
 *              configured).
 */
+ (SRGRequest *)dataRequestWithURLRequest:(NSURLRequest *)URLRequest
                                  session:(NSURLSession *)session
                          completionBlock:(SRGDataCompletionBlock)completionBlock;

/**
 *  Request started with the provided session, calling the specified block on completion, and returning the response as
 *  a JSON array.
 *
 *  @discussion An error is returned to the completion block if the response could not be transformed into a JSON
 *              array. The completion block will likely be called on a background thread (this depends on how the
 *              session was configured).
 */
+ (SRGRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest
                                       session:(NSURLSession *)session
                               completionBlock:(SRGJSONArrayCompletionBlock)completionBlock;

/**
 *  Request started with the provided session, calling the specified block on completion, and returning the response as
 *  a JSON dictionary.
 *
 *  @discussion An error is returned to the completion block if the response could not be transformed into a JSON
 *              dictionary. The completion block will likely be called on a background thread (this depends on how
 *              the session was configured).
 */
+ (SRGRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest
                                            session:(NSURLSession *)session
                                    completionBlock:(SRGJSONDictionaryCompletionBlock)completionBlock;

/**
 *  Object request started with the provided session, turning the response into an object through a mandatory parsing
 *  block (if response data is retrieved), and calling the specified block on completion.
 *
 *  @discussion An error is returned to the completion block if parsing fails. The parsing and completion blocks will
 *              likely be called on a background thread (this depends on how the session was configured).
 */
+ (SRGRequest *)objectRequestWithURLRequest:(NSURLRequest *)URLRequest
                                    session:(NSURLSession *)session
                                     parser:(SRGResponseParser)parser
                            completionBlock:(SRGObjectCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
