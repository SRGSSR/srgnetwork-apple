//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

// Block signatures.
typedef id _Nullable (^SRGResponseParser)(NSData * _Nullable data, NSError **pError);
typedef void (^SRGObjectCompletionBlock)(id _Nullable object, NSURLResponse * _Nullable response, NSError * _Nullable error);

/**
 *  Methods to be used when implementing a `SRGBaseRequest` subclass.
 */
@interface SRGBaseRequest (Subclassing)

/**
 *  Create a request started with the provided session and options, calling the specified block on completion.
 *
 *  @param URLRequest      The request to execute.
 *  @param session         The session for which the request is executed.
 *  @param options         Options to apply (0 if none).
 *  @param parser          An optional parser. If no error is returned (by reference), the extracted object will be
 *                         returend to the completion block, otherwise an error will be returned instead.
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
