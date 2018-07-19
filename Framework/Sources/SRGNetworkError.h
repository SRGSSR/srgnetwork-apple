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
     *  A redirect was encountered. This is e.g. often encountered on public wifis with a login page. Use the 
     *  `SRGNetworkRedirectionURLKey` info key to retrieve the redirection URL (as an `NSURL`).
     */
    SRGNetworkErrorRedirect,
    /**
     *  The data which was received is invalid.
     */
    SRGNetworkErrorCodeInvalidData
};

/**
 *  Common domain for network errors.
 */
OBJC_EXPORT NSString * const SRGNetworkErrorDomain;

/**
 *  Error user information keys, @see `SRGNetworkErrorCode`.
 */
OBJC_EXPORT NSString * const SRGNetworkHTTPStatusCodeKey;
OBJC_EXPORT NSString * const SRGNetworkRedirectionURLKey;

NS_ASSUME_NONNULL_END
