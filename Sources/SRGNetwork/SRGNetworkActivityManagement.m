//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGNetworkActivityManagement.h"

@import UIKit;

static NSInteger s_numberOfRunningRequests = 0;
static void (^s_networkActivityManagementHandler)(BOOL) = nil;

@implementation SRGNetworkActivityManagement

#pragma mark Class methods

#if TARGET_OS_IOS

+ (void)enable
{
    [self enableWithHandler:^(BOOL active) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = active;
    }];
}

#endif

+ (void)enableWithHandler:(void (^)(BOOL))handler
{
    s_networkActivityManagementHandler = handler;
    handler(s_numberOfRunningRequests != 0);
}

+ (void)disable
{
    s_networkActivityManagementHandler ? s_networkActivityManagementHandler(NO) : nil;
    s_networkActivityManagementHandler = nil;
}

+ (void)increaseNumberOfRunningRequests
{
    void (^increase)(void) = ^{
        if (s_numberOfRunningRequests == 0) {
            s_networkActivityManagementHandler ? s_networkActivityManagementHandler(YES) : nil;
        }
        ++s_numberOfRunningRequests;
    };
    
    if (NSThread.isMainThread) {
        increase();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), increase);
    }
}

+ (void)decreaseNumberOfRunningRequests
{
    void (^decrease)(void) = ^{
        --s_numberOfRunningRequests;
        if (s_numberOfRunningRequests == 0) {
            s_networkActivityManagementHandler ? s_networkActivityManagementHandler(NO) : nil;
        }
    };
    
    if (NSThread.isMainThread) {
        decrease();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), decrease);
    }
}

@end
