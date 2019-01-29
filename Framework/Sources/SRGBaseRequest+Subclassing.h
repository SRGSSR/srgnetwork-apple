//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGBaseRequest.h"
#import "SRGNetworkTypes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Methods accessible to `SRGBaseRequest` subclasses.
 */
@interface SRGBaseRequest (Subclassing)

/**
 *  Create a request started with the provided session and options, calling the specified block on completion.
 *
 *  @param URLRequest      The request to execute.
 *  @param session         The session for which the request is executed.
 *  @param options         Options to apply (0 if none).
 *  @param parser          An optional parser. If no error is returned (by reference), the extracted object will be
 *                         returned to the completion block, otherwise an error will be returned instead. The parser
 *                         is only called if data has been retrieved.
 *  @param completionBlock The completion block which will be called when the request ends.
 *
 *  @discussion The block will likely be called on a background thread (this depends on how the session was configured).
 */
- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                           options:(SRGRequestOptions)options
                            parser:(nullable SRGResponseParser)parser
                   completionBlock:(SRGObjectCompletionBlock)completionBlock;

/**
 *  The parser to be used, if any.
 */
@property (nonatomic, readonly, copy, nullable) SRGResponseParser parser;

@end

NS_ASSUME_NONNULL_END
