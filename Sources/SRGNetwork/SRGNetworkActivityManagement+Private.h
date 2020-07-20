//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGNetworkActivityManagement.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Private category for implementation purposes.
 */
@interface SRGNetworkActivityManagement (Private)

/**
 *  Increase the number of running request. When > 0, network activity is reported.
 */
+ (void)increaseNumberOfRunningRequests;

/**
 *  Decrease the number of running request. When = 0, network activity is not reported.
 */
+ (void)decreaseNumberOfRunningRequests;

@end

NS_ASSUME_NONNULL_END
