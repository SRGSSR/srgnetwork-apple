//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Network error constants. More information is available from the `userInfo` associated with these errors.
 */
typedef NS_ENUM(NSInteger, SRGNetworkErrorCode) {
    /**
     *  An HTTP error has been encountered. The HTTP status code is available from the user info under the
     *  `SRGNetworkHTTPStatusCodeKey` key (as an `NSNumber`).
     */
    SRGNetworkErrorHTTP,
    /**
     *  The data which was received is invalid.
     */
    SRGNetworkErrorInvalidData
};

/**
 *  Common domain for network errors.
 */
OBJC_EXPORT NSString * const SRGNetworkErrorDomain;

/**
 *  Error user information keys, @see `SRGNetworkErrorCode`.
 */
OBJC_EXPORT NSString * const SRGNetworkHTTPStatusCodeKey;

NS_ASSUME_NONNULL_END
