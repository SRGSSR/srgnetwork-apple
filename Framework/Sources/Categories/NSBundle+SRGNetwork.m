//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSBundle+SRGNetwork.h"

#import "SRGNetworkRequest.h"

@implementation NSBundle (SRGNetwork)

#pragma mark Class methods

+ (NSBundle *)srg_networkBundle
{
    static NSBundle *bundle;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        bundle = [NSBundle bundleForClass:[SRGNetworkRequest class]];
    });
    return bundle;
}

@end
