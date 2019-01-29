//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGBaseRequest.h"
#import "SRGNetworkTypes.h"

NS_ASSUME_NONNULL_BEGIN

// Blocks signatures.
typedef void (^SRGObjectExtractor)(id _Nullable object, NSURLResponse * _Nullable response);

/**
 *  Methods accessible to `SRGBaseRequest` subclasses.
 */
@interface SRGBaseRequest (Subclassing)

/**
 *  Create a request started with the provided session and options, calling the specified block on completion.
 *
 *  @param URLRequest      The request to execute.
 *  @param session         The session for which the request is executed.
 *  @param parser          An optional parser. If no error is returned (by reference), the extracted object will be
 *                         returned to the completion block, otherwise an error will be returned instead. The parser
 *                         is only called if data has been retrieved.
 *  @param extractor       An optional block to be executed right before the completion block, called if the request
 *                         was successful, and which can be used to extract response information if needed, off the
 *                         main thread (no matter which options have been set).
 *  @param completionBlock The completion block which will be called when the request ends. This block might be called
 *                         on the main thread depending on the request options.
 */
- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                            parser:(nullable SRGResponseParser)parser
                         extractor:(nullable SRGObjectExtractor)extractor
                   completionBlock:(SRGObjectCompletionBlock)completionBlock;

/**
 *  The parser to be used, if any.
 */
@property (nonatomic, readonly, copy, nullable) SRGResponseParser parser;

@end

NS_ASSUME_NONNULL_END
