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
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        NSString *bundlePath = [[NSBundle bundleForClass:[SRGNetworkRequest class]].bundlePath stringByAppendingPathComponent:@"SRGNetwork.bundle"];
        s_bundle = [NSBundle bundleWithPath:bundlePath];
        NSAssert(s_bundle, @"Please add SRGNetwork.bundle to your project resources");
    });
    return s_bundle;
}

@end
