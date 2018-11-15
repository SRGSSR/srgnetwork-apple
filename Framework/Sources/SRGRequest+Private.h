//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Block signatures.
typedef void (^SRGRequestCompletionBlock)(NSDictionary * _Nullable JSONDictionary, NSHTTPURLResponse * _Nullable HTTPResponse, NSError * _Nullable error);

/**
 *  Private interface for implementation purposes.
 */
@interface SRGRequest (Private)

/**
 *  Create a request from a URL request, starting it with the provided session, and calling the specified block on completion.
 */
- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest session:(NSURLSession *)session completionBlock:(SRGRequestCompletionBlock)completionBlock;

/**
 *  The underlying low-level request.
 */
@property (nonatomic, readonly) NSURLRequest *URLRequest;

/**
 *  The session.
 */
@property (nonatomic, readonly) NSURLSession *session;

@end

NS_ASSUME_NONNULL_END
