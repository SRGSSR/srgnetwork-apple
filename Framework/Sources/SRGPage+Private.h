//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRGPage (Private)

- (instancetype)initWithSize:(NSUInteger)size number:(NSUInteger)number URLRequest:(NSURLRequest *)URLRequest;

/**
 *  The request which must be executed to retrieve the page results.
 */
@property (nonatomic, readonly) NSURLRequest *URLRequest;

@end

NS_ASSUME_NONNULL_END
