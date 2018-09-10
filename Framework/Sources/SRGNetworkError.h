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
     *  `SRGNetworkHTTPStatusCodeKey` key.
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

// Information available for `SRGNetworkErrorHTTP`.
OBJC_EXPORT NSString * const SRGNetworkHTTPStatusCodeKey;           // Key to access the HTTP status code as an `NSNumber` (wrapping an `NSInteger` value).
OBJC_EXTERN NSString * const SRGNetworkFailingURLKey;               // Key to access the failing URL.

NS_ASSUME_NONNULL_END
