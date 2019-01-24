//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGNetworkActivityManagement.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRGNetworkActivityManagement (Private)

+ (void)increaseNumberOfRunningRequests;
+ (void)decreaseNumberOfRunningRequests;

@end

NS_ASSUME_NONNULL_END
