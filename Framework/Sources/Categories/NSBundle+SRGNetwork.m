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
    static NSBundle *s_bundle;
    static dispatch_once_t s_once;
    dispatch_once(&s_once, ^{
        NSString *bundlePath = [[NSBundle bundleForClass:[SRGNetworkRequest class]].bundlePath stringByAppendingPathComponent:@"SRGNetwork.bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
        NSAssert(bundle, @"Please add SRGNetwork.bundle to your project resources");
    });
    return bundle;
}

@end
