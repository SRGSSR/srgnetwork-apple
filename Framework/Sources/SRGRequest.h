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
 *  Convenience initializers. JSON requests will fail with an error if the data cannot be parsed in the expected format.
 */
+ (SRGRequest *)requestWithURLRequest:(NSURLRequest *)URLRequest session:(NSURLSession *)session options:(SRGRequestOptions)options completionBlock:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;
+ (SRGRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest session:(NSURLSession *)session options:(SRGRequestOptions)options completionBlock:(void (^)(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;
+ (SRGRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest session:(NSURLSession *)session options:(SRGRequestOptions)options completionBlock:(void (^)(NSArray * _Nullable JSONArray, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

/**
 *  Create a request from a URL request, starting it with the provided session, and calling the specified block on completion.
 *
 *  @param URLRequest      The request to execute.
 *  @param session         The session for which the request is executed.
 *  @param options         Options to apply (0 if none).
 *  @param completionBlock The completion block which will be called when the request ends. Beware that the block might be
 *                         called on a background thread, depending on how the session has been configured.
 */
- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest session:(NSURLSession *)session options:(SRGRequestOptions)options completionBlock:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock NS_DESIGNATED_INITIALIZER;

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
@property (readonly, getter=isRunning) BOOL running;

/**
 *  The underlying low-level request.
 */
@property (readonly) NSURLRequest *URLRequest;

/**
 *  The session.
 */
@property (readonly) NSURLSession *session;

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
 *              disabled as well. The handler is always called on the main thread.
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

@interface SRGRequest (Unavailable)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
