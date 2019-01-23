//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NetworkBaseTestCase.h"

@interface RequestQueueTestCase : NetworkBaseTestCase

@end

@implementation RequestQueueTestCase

#pragma mark Tests

- (void)testCreation
{
    SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] init];
    XCTAssertFalse(requestQueue.running);
}

- (void)testSingleRequest
{
    __block BOOL requestFinished = NO;
    __block BOOL requestQueueFinished = NO;
    
    XCTestExpectation *queueStartedExpectation = [self expectationWithDescription:@"Queue started"];
    XCTestExpectation *queueFinishedExpectation = [self expectationWithDescription:@"Queue finished"];
    
    XCTestExpectation *requestCompletionExpectation = [self expectationWithDescription:@"Request completed"];
    
    __block SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNil(error);
        
        if (! finished) {
            XCTAssertTrue(requestQueue.running);
            [queueStartedExpectation fulfill];
        }
        else {
            XCTAssertFalse(requestQueue.running);
            XCTAssertTrue(requestFinished);
            
            requestQueueFinished = YES;
            [queueFinishedExpectation fulfill];
        }
    }];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertFalse(requestQueueFinished);
        [requestQueue reportError:error];
        
        requestFinished = YES;
        [requestCompletionExpectation fulfill];
    }];
    [requestQueue addRequest:request resume:YES];
    
    // The queue is immediately running
    XCTAssertTrue(requestQueue.running);
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    XCTAssertFalse(request.running);
    XCTAssertFalse(requestQueue.running);
}

- (void)testEmptyQueue
{
    SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] init];
    [requestQueue resume];
    
    // Empty queues can never be running
    XCTAssertFalse(requestQueue.running);
}

- (void)testDeallocation
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
    __weak SRGRequestQueue *requestQueue;
    @autoreleasepool {
        requestQueue = [[SRGRequestQueue alloc] init];
    }
    XCTAssertNil(requestQueue);
#pragma clang diagnostic pop
}

- (void)testDeallocationWithRequests
{
    [self expectationForElapsedTimeInterval:3. withHandler:nil];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
    __weak SRGRequestQueue *requestQueue;
    @autoreleasepool {
        requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
            if (finished) {
                XCTFail(@"No finished state change expected since the queue is deallocated early");
            }
        }];
        NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
        SRGRequest *request = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            XCTFail(@"The request must be cancelled when the parent queue is deallocated");
        }];
        [requestQueue addRequest:request resume:YES];
    }
    [self waitForExpectationsWithTimeout:5. handler:nil];
#pragma clang diagnostic pop
}

- (void)testParallelRequests
{
    __block BOOL request1Finished = NO;
    __block BOOL request2Finished = NO;
    __block BOOL requestQueueFinished = NO;
    
    XCTestExpectation *queueStartedExpectation = [self expectationWithDescription:@"Queue started"];
    XCTestExpectation *queueFinishedExpectation = [self expectationWithDescription:@"Queue finished"];
    
    XCTestExpectation *request1CompletionExpectation = [self expectationWithDescription:@"Request 1 completed"];
    XCTestExpectation *request2CompletionExpectation = [self expectationWithDescription:@"Request 2 completed"];
    
    __block SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNil(error);
        
        if (! finished) {
            XCTAssertTrue(requestQueue.running);
            [queueStartedExpectation fulfill];
        }
        else {
            XCTAssertFalse(requestQueue.running);
            XCTAssertTrue(request1Finished);
            XCTAssertTrue(request2Finished);
            
            requestQueueFinished = YES;
            [queueFinishedExpectation fulfill];
        }
    }];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request1 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertFalse(requestQueueFinished);
        [requestQueue reportError:error];
        
        request1Finished = YES;
        [request1CompletionExpectation fulfill];
    }];
    [requestQueue addRequest:request1 resume:YES];
    
    // The queue is immediately running
    XCTAssertTrue(requestQueue.running);
    
    SRGRequest *request2 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertFalse(requestQueueFinished);
        [requestQueue reportError:error];
        
        request2Finished = YES;
        [request2CompletionExpectation fulfill];
    }];
    [requestQueue addRequest:request2 resume:YES];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    XCTAssertFalse(request1.running);
    XCTAssertFalse(request2.running);
    XCTAssertFalse(requestQueue.running);
}

- (void)testParallelRequestsFromBackgroundThreads
{
    __block BOOL request1Finished = NO;
    __block BOOL request2Finished = NO;
    __block BOOL requestQueueFinished = NO;
    
    XCTestExpectation *queueStartedExpectation = [self expectationWithDescription:@"Queue started"];
    XCTestExpectation *queueFinishedExpectation = [self expectationWithDescription:@"Queue finished"];
    
    XCTestExpectation *request1CompletionExpectation = [self expectationWithDescription:@"Request 1 completed"];
    XCTestExpectation *request2CompletionExpectation = [self expectationWithDescription:@"Request 2 completed"];
    
    __block SRGRequestQueue *requestQueue = nil;
    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
            XCTAssertTrue([NSThread isMainThread]);
            XCTAssertNil(error);
            
            if (! finished) {
                XCTAssertTrue(requestQueue.running);
                [queueStartedExpectation fulfill];
            }
            else {
                XCTAssertFalse(requestQueue.running);
                XCTAssertTrue(request1Finished);
                XCTAssertTrue(request2Finished);
                
                requestQueueFinished = YES;
                [queueFinishedExpectation fulfill];
            }
        }];
    });
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    
    __block SRGRequest *request1 = nil;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UNSPECIFIED, 0), ^{
        request1 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            XCTAssertFalse(requestQueueFinished);
            [requestQueue reportError:error];
            
            request1Finished = YES;
            [request1CompletionExpectation fulfill];
        }];
        [requestQueue addRequest:request1 resume:YES];
    });
    
    __block SRGRequest *request2 = nil;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        request2 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            XCTAssertFalse(requestQueueFinished);
            [requestQueue reportError:error];
            
            request2Finished = YES;
            [request2CompletionExpectation fulfill];
        }];
        [requestQueue addRequest:request2 resume:YES];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    XCTAssertFalse(request2.running);
    XCTAssertFalse(requestQueue.running);
}

- (void)testCascadingRequests
{
    XCTestExpectation *queueStartedExpectation = [self expectationWithDescription:@"Queue started"];
    XCTestExpectation *queueFinishedExpectation = [self expectationWithDescription:@"Queue finished"];
    
    XCTestExpectation *requestsFinishedExpectation = [self expectationWithDescription:@"Requests finished"];
    
    __block SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNil(error);
        
        if (! finished) {
            XCTAssertTrue(requestQueue.running);
            [queueStartedExpectation fulfill];
        }
        else {
            XCTAssertFalse(requestQueue.running);
            [queueFinishedExpectation fulfill];
        }
    }];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request1 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [requestQueue reportError:error];
        
        SRGRequest *request2 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [requestQueue reportError:error];
            
            [requestsFinishedExpectation fulfill];
        }];
        [requestQueue addRequest:request2 resume:YES];
        XCTAssertTrue(request2.running);
    }];
    [requestQueue addRequest:request1 resume:YES];
    XCTAssertTrue(request1.running);
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    XCTAssertFalse(request1.running);
    XCTAssertFalse(requestQueue.running);
}

- (void)testError
{
    XCTestExpectation *queueStartedExpectation = [self expectationWithDescription:@"Queue started"];
    XCTestExpectation *queueFinishedExpectation = [self expectationWithDescription:@"Queue finished"];
    
    XCTestExpectation *requestCompletionExpectation = [self expectationWithDescription:@"Request completed"];
    
    __block SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        XCTAssertTrue([NSThread isMainThread]);
        
        if (! finished) {
            XCTAssertTrue(requestQueue.running);
            XCTAssertNil(error);
            [queueStartedExpectation fulfill];
        }
        else {
            XCTAssertFalse(requestQueue.running);
            XCTAssertEqualObjects(error.domain, SRGNetworkErrorDomain);
            XCTAssertEqual(error.code, SRGNetworkErrorHTTP);
            
            [queueFinishedExpectation fulfill];
        }
    }];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/status/404"];
    SRGRequest *request = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [requestQueue reportError:error];
        [requestCompletionExpectation fulfill];
    }];
    [requestQueue addRequest:request resume:YES];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
}

- (void)testErrors
{
    XCTestExpectation *queueStartedExpectation = [self expectationWithDescription:@"Queue started"];
    XCTestExpectation *queueFinishedExpectation = [self expectationWithDescription:@"Queue finished"];
    
    XCTestExpectation *request1CompletionExpectation = [self expectationWithDescription:@"Request 1 completed"];
    XCTestExpectation *request2CompletionExpectation = [self expectationWithDescription:@"Request 2 completed"];
    
    __block SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        XCTAssertTrue([NSThread isMainThread]);
        
        if (! finished) {
            XCTAssertTrue(requestQueue.running);
            XCTAssertNil(error);
            [queueStartedExpectation fulfill];
        }
        else {
            XCTAssertFalse(requestQueue.running);
            XCTAssertEqualObjects(error.domain, SRGNetworkErrorDomain);
            XCTAssertEqual(error.code, SRGNetworkErrorMultiple);
            XCTAssertEqual([error.userInfo[SRGNetworkErrorsKey] count], 2);
            
            [queueFinishedExpectation fulfill];
        }
    }];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/status/404"];
    SRGRequest *request1 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [requestQueue reportError:error];
        [request1CompletionExpectation fulfill];
    }];
    [requestQueue addRequest:request1 resume:YES];
    
    // The queue is immediately running
    XCTAssertTrue(requestQueue.running);
    
    SRGRequest *request2 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [requestQueue reportError:error];
        [request2CompletionExpectation fulfill];
    }];
    [requestQueue addRequest:request2 resume:YES];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    XCTAssertFalse(request1.running);
    XCTAssertFalse(request2.running);
    XCTAssertFalse(requestQueue.running);
}

- (void)testGlobalResume
{
    XCTestExpectation *queueStartedExpectation = [self expectationWithDescription:@"Queue started"];
    XCTestExpectation *queueFinishedExpectation = [self expectationWithDescription:@"Queue finished"];
    
    XCTestExpectation *request1CompletionExpectation = [self expectationWithDescription:@"Request 1 completed"];
    XCTestExpectation *request2CompletionExpectation = [self expectationWithDescription:@"Request 2 completed"];
    
    __block SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNil(error);
        
        if (! finished) {
            XCTAssertTrue(requestQueue.running);
            [queueStartedExpectation fulfill];
        }
        else {
            XCTAssertFalse(requestQueue.running);
            [queueFinishedExpectation fulfill];
        }
    }];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request1 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [requestQueue reportError:error];
        [request1CompletionExpectation fulfill];
    }];
    [requestQueue addRequest:request1 resume:NO];
    
    // The queue is not running yet
    XCTAssertFalse(requestQueue.running);
    
    SRGRequest *request2 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [requestQueue reportError:error];
        [request2CompletionExpectation fulfill];
    }];
    [requestQueue addRequest:request2 resume:NO];
    
    // The queue is still not running yet
    XCTAssertFalse(requestQueue.running);
    
    // Now run the queue
    [requestQueue resume];
    XCTAssertTrue(requestQueue.running);
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    XCTAssertFalse(request1.running);
    XCTAssertFalse(request2.running);
    XCTAssertFalse(requestQueue.running);
}

- (void)testGlobalCancel
{
    XCTestExpectation *queueStartedExpectation = [self expectationWithDescription:@"Queue started"];
    XCTestExpectation *queueFinishedExpectation = [self expectationWithDescription:@"Queue finished"];
    
    __block SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNil(error);
        
        if (! finished) {
            XCTAssertTrue(requestQueue.running);
            [queueStartedExpectation fulfill];
        }
        else {
            XCTAssertFalse(requestQueue.running);
            [queueFinishedExpectation fulfill];
        }
    }];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request1 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTFail(@"Completion block must not be called when the request has been cancelled");
    }];
    [requestQueue addRequest:request1 resume:YES];
    
    // The queue is immediately running
    XCTAssertTrue(requestQueue.running);
    
    SRGRequest *request2 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTFail(@"Completion block must not be called when the request has been cancelled");
    }];
    [requestQueue addRequest:request2 resume:YES];
    
    // Immediately cancel the queue
    [requestQueue cancel];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    XCTAssertFalse(request1.running);
    XCTAssertFalse(request2.running);
    XCTAssertFalse(requestQueue.running);
}

- (void)testKVOStateChanges
{
    SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] init];
    
    // Add a request to the queue and run it. Wait until the queue does not run anymore
    [self keyValueObservingExpectationForObject:requestQueue keyPath:@"running" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
        return [change[NSKeyValueChangeNewKey] isEqual:@NO];
    }];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request1 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing
    }];
    [requestQueue addRequest:request1 resume:YES];
    XCTAssertTrue(requestQueue.running);
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    // Add a second request. The queue must run again
    [self keyValueObservingExpectationForObject:requestQueue keyPath:@"running" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
        return [change[NSKeyValueChangeNewKey] isEqual:@NO];
    }];
    
    SRGRequest *request2 = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing
    }];
    [requestQueue addRequest:request2 resume:YES];
    XCTAssertTrue(requestQueue.running);
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
}

- (void)testReuse
{
    SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] init];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Not interested in individual request status
    }];
    [requestQueue addRequest:request resume:NO];
    
    // Wait until the queue is not running anymore
    [self keyValueObservingExpectationForObject:requestQueue keyPath:@"running" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
        return [change[NSKeyValueChangeNewKey] isEqual:@NO];
    }];
    
    [requestQueue resume];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    // Restart it
    [self keyValueObservingExpectationForObject:request keyPath:@"running" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
        return [change[NSKeyValueChangeNewKey] isEqual:@YES];
    }];
    
    [requestQueue resume];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
}

- (void)testReportedErrorsReset
{
    // Errors are only collected when the queue is running, and reset when returning to non-running state. If we perform
    // a request queue leading to a single error twice, we thus expect only a single error each time the status change block is
    // called. We do not expect errors to accumulate as a SRGNetworkErrorMultiple error
    SRGRequestQueue *requestQueue = [[SRGRequestQueue alloc] initWithStateChangeBlock:^(BOOL finished, NSError * _Nullable error) {
        if (finished) {
            XCTAssertNotNil(error);
            XCTAssertNotEqual(error.code, SRGNetworkErrorMultiple);
        }
    }];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/status/404"];
    SRGRequest *request = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [requestQueue reportError:error];
    }];
    [requestQueue addRequest:request resume:YES];
    
    // Wait until the queue is not running anymore
    [self keyValueObservingExpectationForObject:requestQueue keyPath:@"running" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
        return [change[NSKeyValueChangeNewKey] isEqual:@NO];
    }];
    
    [requestQueue resume];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    // Restart it and wait until it is not running anymore
    [self expectationForElapsedTimeInterval:2. withHandler:nil];
    
    [self keyValueObservingExpectationForObject:request keyPath:@"running" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
        return [change[NSKeyValueChangeNewKey] isEqual:@NO];
    }];
    
    [requestQueue resume];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
}

@end
