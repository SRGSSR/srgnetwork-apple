//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGRequest.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Request queues provide a convenient way to manage related requests, whether these requests occur in parallel or
 *  in cascade.
 *  
 *  A request queue is simply a collection of requests, which is running iff at least one of the requests added to
 *  it is running. The state of the queue automatically adjusts when you add requests to an existing queue. You can
 *  add all requests right from the start, or even add requests to a queue when needed. This makes it possible to
 *  support most common request needs, for example:
 *    - You can create a queue and add a batch of requests to it (parallel requests).
 *    - You can add a request to a queue, wait until you get an answer, and use this answer to perform another request
 *      (probably using some data you received), added to the same queue (cascading requests).
 *    - You can also pass a queue around so that subsets of your applications can add their own requests to it
 *      as needed.
 *
 *  As a general rule, you should use a request queue to group requests for which you want a common behavior when
 *  at least one of them is running, or none of them is. For example, if you need to perform ten different requests
 *  to fill a screen of content, you can group them with a single queue, and adjust your UI depending on the status
 *  of the queue (e.g. displaying a loading indicator when the queue is running).
 *
 *  ## State change
 *
 *  A request queue is instantiated with an optional state change block, which is called when the running status
 *  of the queue changes. This makes it possible to capture the state of all associated requests without additional
 *  manual management (e.g. without counting finished requests). The call order of the involved blocks is always as
 *  follows:
 *
 *    - queue state change block call, `finished` = `NO`
 *    - request 1 completion block (if not cancelled)
 *    - .....
 *    - request N completion block (if not cancelled)
 *    - queue state change block call, `finished` = `YES`
 *
 *  Note that an empty queue (i.e. without any request attached to it) will never switch to the running state.
 *
 *  ## Error reporting
 *
 *  As requests finish, you can report back the errors they encounter to the queue by calling `-reportError:`
 *  on it. These errors are then made available to the status change block when it is called at the end.
 *
 *  ## Lifetime
 *
 *  A request queue must be retained somewhere, otherwise all requests associated with it will be cancelled when
 *  the queue is deallocated. 
 *
 *  By design, a request queue is not intended to be reused (you cannot remove connections added to a queue). 
 *  If you need another queue for the same requests, start with a fresh one.
 *
 *  ## Relationship between requests and queues
 *
 *  The link between requests and queues is weak (i.e. queues reference requests but do not retain them). You can
 *  therefore safely reference queues from within request completion blocks without creating retain cycles.
 */
@interface SRGRequestQueue : NSObject

/**
 *  Create a request queue with an optional block to respond to its status changes.
 *
 *  @param stateChangeBlock The block which will be called when the queue status changes. The block can be called
 *                          several times during the queue lifetime.
 *
 *  @discussion When `running` changes from `NO` to `YES`, the block is called with `finished` = `NO` and no error. This
 *              is e.g. the perfect time to update your UI to tell your user data is being requested. Conversely, when 
 *              `running` changes from `YES` to `NO`, the block is called with `finished` = `YES` and an optional error
 *              (if errors have been reported to the queue using). This is e.g. the perfect time to update your UI and 
 *              display errors if any.
 *
 *              When the state change block is called, the queue is already in the correct state. This means `running` 
 *              is `YES` within the state change block when it is called because the queue started, and `NO` if it is
 *              called if the queue finished.
 *
 *              If several errors have been reported, the error code is `SRGDataProviderErrorMultiple`. You can obtain
 *              the error list from the associated user info. If a single error is reported, it is reported as is.
 *
 *              Moreover, unlike completion blocks, state change blocks are called when the queue state changes, whether
 *              this happens because connections are added, normally complete or are cancelled.
 */
- (instancetype)initWithStateChangeBlock:(nullable void (^)(BOOL finished, NSError * _Nullable error))stateChangeBlock;

/**
 *  Add a request to the queue. The queue status will immediately be updated according to the status of the request
 *  added to it.
 *
 *  @param request The request to add to the queue.
 *  @param resume  If set to `YES`, `-resume` is automatically called on the request when added to the queue.
 *
 *  @discussion Adding the same request to two different queues is not supported and leads to undefined behavior.
 */
- (void)addRequest:(SRGRequest *)request resume:(BOOL)resume;

/**
 *  Call `-resume` on all requests within the queue.
 */
- (void)resume;

/**
 *  Call `-cancel` on all requests within the queue.
 */
- (void)cancel;

/**
 *  Report an error to the queue. Nothing happens if the error is `nil` (this eliminates the need to check whether an
 *  error is `nil` before reporting it). Errors are collected during running sessions, and cleaned up when the queue
 *  has returned to the non-running state.
 */
- (void)reportError:(nullable NSError *)error;

/**
 *  Return `YES` iff the queue is running.
 *
 *  @discussion This property is KVO-observable.
 */
@property (nonatomic, readonly, getter=isRunning) BOOL running;

@end

NS_ASSUME_NONNULL_END
