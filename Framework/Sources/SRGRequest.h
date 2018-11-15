//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `SRGRequest` objects provide a way to manage the data retrieval process associated with a data provider 
 *  service request. You never instantiate `SRGRequest` objects directly, you merely use the ones returned 
 *  when calling `SRGDataProvider` service methods.
 *
 *  Requests are not started by default. Once you have an `SRGRequest` instance, call the `-resume` method
 *  to start the request. A started request keeps itself alive while it is running. You can therefore send
 *  a request locally without keeping a reference to it (but this makes it impossible to cancel the request
 *  manually afterwards). If you want to be able to cancel a request, keep a reference to it. 
 *
 *  To manage several related requests, use an `SRGRequestQueue`.
 */
@interface SRGRequest : NSObject

/**
 *  Start performing the request.
 *
 *  @discussion `running` is immediately set to `YES`. Attempting to resume an already running request does nothing.
 *              You can restart a finished request by calling `-resume` again.
 */
- (void)resume;

/**
 *  Cancel the request.
 *
 *  @discussion `running` is immediately set to `NO`. Request completion blocks (@see `SRGDataProvider`) won't be called.
 *              You can restart a cancelled request by `-calling` resume again.
 */
- (void)cancel;

/**
 *  Return `YES` iff the request is running. 
 *
 *  @discussion The request is considered running from the time it has been started to right after the associated
 *              completion block (@see `SRGDataProvider`) has been executed. It is immediately reset to `NO`
 *              when the request is cancelled.
 *
 *              This property is KVO-observable.
 */
@property (nonatomic, readonly, getter=isRunning) BOOL running;

@end

/**
 *  Automatic network activity management for requests (opt-in).
 */
@interface SRGRequest (AutomaticNetworkActivityManagement)

/**
 *  Enable automatic network activity indicator management. The activity indicator is automatically shown when at least
 *  one request is running.
 *
 *  Automatic network activity management is an opt-in. You should call this method early in your application lifecycle
 *  if desired. The method can be called at any time though, the handler will be called accordingly.
 *
 *  @discussion Any handler previously registered with `+enableNetworkActivityManagementWithHandler:` is replaced.
 */
+ (void)enableNetworkActivityIndicatorManagement NS_EXTENSION_UNAVAILABLE_IOS("Network activity indicator management is not available for extensions");

/**
 *  Enable automatic network activity management with a custom handler. The handler is called when network activity
 *  changes (the network is considered to be active when at least one request is running), providing the new status as a
 *  boolean `active` parameter.
 *
 *  Automatic network activity management is an opt-in. You should call this method early in your application lifecycle
 *  if desired. The method can be called at any time though, the network activity indicator will be updated accordingly.
 *
 *  @discussion Any previously registered handler is replaced. If automatic indicator management was used, it is
 *              disabled as well.
 */
+ (void)enableNetworkActivityManagementWithHandler:(void (^)(BOOL active))handler;

/**
 *  Disable automatic network management (handler and automatic activity indicator management).
 *
 *  @discussion When called, any previous handler is called with `active` set to `NO`. If using automatic activity
 *              indicator management, the indicator is hidden as well.
 */
+ (void)disableNetworkActivityManagement;

@end

NS_ASSUME_NONNULL_END
