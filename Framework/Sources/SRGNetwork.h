//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

// Official version number.
FOUNDATION_EXPORT NSString *SRGNetworkMarketingVersion(void);

// Public headers.
#import "NSHTTPURLResponse+SRGNetwork.h"
#import "SRGBaseRequest.h"
#import "SRGFirstPageRequest.h"
#import "SRGNetworkError.h"
#import "SRGNetworkParsers.h"
#import "SRGNetworkTypes.h"
#import "SRGPage.h"
#import "SRGPageRequest.h"
#import "SRGRequest.h"
#import "SRGRequestQueue.h"

#if TARGET_OS_IOS

#import "SRGNetworkActivityManagement.h"

#endif
