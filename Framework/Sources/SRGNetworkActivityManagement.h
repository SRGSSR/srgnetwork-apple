//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Automatic network activity management for requests (opt-in).
 */
__TVOS_PROHIBITED __WATCHOS_PROHIBITED
@interface SRGNetworkActivityManagement : NSObject

/**
 *  Enable automatic system network activity indicator management (status bar activity indicator). The activity indicator
 *  is automatically shown when at least one request is running.
 *
 *  Automatic network activity management is an opt-in. You should call this method early in your application lifecycle
 *  if desired. The method can be called at any time though, the handler will be called accordingly.
 *
 *  @discussion Any handler previously registered with `+enableWithHandler:` is replaced.
 */
+ (void)enable NS_EXTENSION_UNAVAILABLE_IOS("Network activity indicator management is not available for extensions");

/**
 *  Enable automatic network activity management with a custom handler. The handler is called when network activity
 *  changes (the network is considered to be active when at least one request is running), providing the new status as a
 *  boolean `active` parameter.
 *
 *  Automatic network activity management is an opt-in. You should call this method early in your application lifecycle
 *  if desired. The method can be called at any time though, the network activity indicator will be updated accordingly.
 *
 *  @discussion Any previously registered handler is replaced. If automatic system indicator management was used, it is
 *              disabled as well. The handler is always called on the main thread.
 */
+ (void)enableWithHandler:(void (^)(BOOL active))handler;

/**
 *  Disable automatic network management (handler and automatic activity indicator management).
 *
 *  @discussion When called, any previous handler is called with `active` set to `NO`. If using automatic system network
 *              activity indicator management, the indicator is hidden as well.
 */
+ (void)disable;

@end

NS_ASSUME_NONNULL_END
