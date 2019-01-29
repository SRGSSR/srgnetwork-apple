//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGNetworkTypes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Abstract base class for requests.
 *
 *  This class is not meant to be instantiated as is. Use a concrete `SRGRequest` for a standard request, or
 *  `SRGFirstPageRequest` for a request with pagination support.
 *
 *  Requests support various options (none applied by default), controlling how they behave. To apply options,
 *  call `-requestWithOptions:` to apply options to the receiver.
 *
 *  Note that all concrete requests take a completion block as parameter, called when they finish, either successfully
 *  or because of an error.
 *
 *  ## Thread-safety
 *
 *  Network requests can be started from any thread. By default, their completion block will be called on the main
 *  thread, though. This can be changed by calling `-requestWithOptions:` on an existing request, with the
 *  `SRGNetworkRequestBackgroundThreadCompletionEnabled` option.
 *
 *  This choice has been made to avoid common programming errors. Since all request work is done on background threads,
 *  the completion block is most of the time namely used to trigger UI updates, which have to occur on the main thread.
 */
@interface SRGBaseRequest : NSObject

/**
 *  Return a clone of the receiver, with the specified options. Previously applied options are replaced.
 */
- (__kindof SRGBaseRequest *)requestWithOptions:(SRGRequestOptions)options;

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
 *  @discussion `running` is immediately set to `NO`. Request completion blocks won't be called. You can restart a
 *              cancelled request by `-calling` resume again.
 */
- (void)cancel;

/**
 *  Return `YES` iff the request is running.
 *
 *  @discussion The request is considered running from the time it has been started to right after the associated
 *              completion block has been executed. It is immediately reset to `NO` when the request is cancelled.
 *
 *              This property is KVO-observable (changes are not necessarily observed on the main thread, though).
 */
@property (nonatomic, readonly, getter=isRunning) BOOL running;

/**
 *  The underlying low-level request.
 */
@property (nonatomic, readonly) NSURLRequest *URLRequest;

/**
 *  The session.
 */
@property (nonatomic, readonly) NSURLSession *session;

/**
 *  The applied options.
 */
@property (nonatomic, readonly) SRGRequestOptions options;

@end

@interface SRGBaseRequest (Unavailable)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
