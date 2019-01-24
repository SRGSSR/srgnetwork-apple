//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Rquest options.
 */
typedef NS_OPTIONS(NSUInteger, SRGRequestOptions) {
    /**
     *  By default, cancelled requests will not call the associated completion block. If this flag is set, though,
     *  cancelled requests will call the completion block with an associated error.
     */
    SRGRequestOptionCancellationErrorsEnabled = (1UL << 0),
    /**
     *  By default, and unlike `NSURLSession` tasks, requests return an `NSError` when an HTTP error status code has
     *  been received. If this flag is set, though, this mechanism is disabled, and the behavior is similar to the
     *  one of `NSURLSession` tasks (the status code can be retrieved from the response).
     */
    SRGRequestOptionHTTPErrorsDisabled = (1UL << 1),
    /**
     *  Some errors might be related to a public WiFi being used, which is why friendly error messages are returned
     *  by default when this might be the case. The error domain and code are left unaltered. This behavior can be
     *  disabled, in which case the original (non-friendly) error message is kept.
     */
    SRGNetworkOptionFriendlyWiFiMessagesDisabled = (1UL << 2),
    /**
     *  By default, request completion blocks are called on a background thread. Enable this flag to have them called
     *  on the main thread.
     */
    SRGNetworkRequestMainThreadCompletionEnabled = (1UL << 2),
};

/**
 *  Abstract base class for requests.
 */
@interface SRGBaseRequest : NSObject

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
