//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSHTTPURLResponse (SRGNetwork)

/**
 *  Returns a capitalized localized string for the specified `NSURLErrorDomain` error code. If the error code has no match
 *  in the domain, the method returns a generic message.
 *
 *  @discussion This method fixes incorrectly non-translated error descriptions in `NSURLErrorDomain` errors.
 */
+ (NSString *)srg_localizedStringForURLErrorCode:(NSInteger)errorCode;

/**
 *  Returns a capitalized localized string for the specified HTTP status code.
 *
 *  @discussion This method is a fix for the buggy +localizedStringForStatusCode: public method. See
 *                http://openradar.appspot.com/radar?id=5498641225613312.
 */
+ (NSString *)srg_localizedStringForStatusCode:(NSInteger)statusCode;

@end

NS_ASSUME_NONNULL_END
