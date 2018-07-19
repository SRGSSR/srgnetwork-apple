//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGNetwork.h"

#import "NSBundle+SRGNetwork.h"

NSString *SRGNetworkMarketingVersion(void)
{
    return [NSBundle srg_networkBundle].infoDictionary[@"CFBundleShortVersionString"];
}
