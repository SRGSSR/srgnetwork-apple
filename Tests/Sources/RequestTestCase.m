//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NetworkBaseTestCase.h"

// For tests, you can use:
//   - https://httpbin.org for HTTP-related tests.
//   - https://badssl.com for SSL-related tests.

@interface RequestTestCase : NetworkBaseTestCase

@end

@implementation RequestTestCase

#pragma mark Tests

- (void)testSuccessful
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    [[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(data);
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        [expectation fulfill];
    }] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testSuccessfulFromBackgroundThread
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
        [[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            XCTAssertNotNil(data);
            XCTAssertNotNil(response);
            XCTAssertNil(error);
            [expectation fulfill];
        }] resume];
    });
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testSuccessfulJSONDictionary
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/json"];
    [[SRGRequest JSONDictionaryRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(JSONDictionary);
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        [expectation fulfill];
    }] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testNeverStarted
{
    [self expectationForElapsedTimeInterval:3. withHandler:nil];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTFail(@"Completion block must not be called");
    }];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testIncorrectJSONDictionary
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    [[SRGRequest JSONDictionaryRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(JSONDictionary);
        XCTAssertNotNil(response);
        XCTAssertEqualObjects(error.domain, SRGNetworkErrorDomain);
        XCTAssertEqual(error.code, SRGNetworkErrorInvalidData);
        [expectation fulfill];
    }] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testCancel
{
    [self expectationForElapsedTimeInterval:3. withHandler:nil];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTFail(@"Completion block must not be called");
    }];
    [request resume];
    XCTAssertTrue(request.running);
    
    [request cancel];
    XCTAssertFalse(request.running);
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
    
    XCTAssertFalse(request.running);
}

- (void)testCancellationErrorsEnabled
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(data);
        XCTAssertNil(response);
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorCancelled);
        [expectation fulfill];
    }] requestWithOptions:SRGRequestOptionCancellationErrorsEnabled];
    [request resume];
    [request cancel];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testHTTPError
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/status/404"];
    [[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(data);
        XCTAssertNotNil(response);
        XCTAssertEqualObjects(error.domain, SRGNetworkErrorDomain);
        XCTAssertEqual(error.code, SRGNetworkErrorHTTP);
        XCTAssertEqualObjects(error.userInfo[SRGNetworkHTTPStatusCodeKey], @404);
        XCTAssertEqualObjects(error.userInfo[SRGNetworkFailingURLKey], URL);
        [expectation fulfill];
    }] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testHTTPErrorsDisabled
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/status/404"];
    [[[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(data);
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        [expectation fulfill];
    }] requestWithOptions:SRGRequestOptionHTTPErrorsDisabled] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testFriendlyPublicWiFiMessages
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://untrusted-root.badssl.com"];
    [[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(data);
        XCTAssertNil(response);
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorServerCertificateUntrusted);
        XCTAssertTrue([error.localizedDescription containsString:@"WiFi"]);
        XCTAssertNotNil(error.userInfo[NSURLErrorFailingURLStringErrorKey]);
        [expectation fulfill];
    }] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testFriendlyPublicWiFiMessagesDisabled
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://untrusted-root.badssl.com"];
    [[[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(data);
        XCTAssertNil(response);
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorServerCertificateUntrusted);
        XCTAssertFalse([error.localizedDescription containsString:@"WiFi"]);
        XCTAssertNotNil(error.userInfo[NSURLErrorFailingURLStringErrorKey]);
        [expectation fulfill];
    }] requestWithOptions:SRGRequestOptionFriendlyWiFiMessagesDisabled] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testCompletionBlockThread
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    [[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertTrue(NSThread.isMainThread);
        [expectation fulfill];
    }] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testBackgroundThreadCompletionEnabled
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    [[[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertFalse(NSThread.isMainThread);
        [expectation fulfill];
    }] requestWithOptions:SRGRequestOptionBackgroundCompletionEnabled] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

// Use autorelease pools to force pool drain before testing weak variables (otherwise objects might have been added to
// a pool by ARC depending on how they are used, and might therefore still be alive before a pool is drained)
- (void)testDeallocation
{
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    
    // Non-resumed requests are deallocated when not used
    __weak SRGRequest *request1;
    @autoreleasepool {
        request1 = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            XCTFail(@"Must not be called since the request has not been resumed");
        }];
    }
    XCTAssertNil(request1);
    
    // Resumed requests are self-retained during their lifetime
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Request finished"];
    
    __block SRGRequest *request2 = nil;
    @autoreleasepool {
        request2 = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // Release the local strong reference
            request2 = nil;
            [expectation2 fulfill];
        }];
        [request2 resume];
    }
    XCTAssertNotNil(request2);
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    XCTAssertNil(request2);
}

- (void)testCancelledRequestDeallocation
{
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    __block SRGRequest *request = nil;
    @autoreleasepool {
        request = [[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // Release the local strong reference
            request = nil;
            [expectation fulfill];
        }] requestWithOptions:SRGRequestOptionCancellationErrorsEnabled];
        [request resume];
        [request cancel];
    }
    XCTAssertNotNil(request);
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    XCTAssertNil(request);
}

- (void)testStatus
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    __block SRGRequest *request = nil;
    request = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // The request is considered running until after the completion block has been executed
        XCTAssertTrue(request.running);
        
        // Fulfill expectation after block execution to capture the `running` update occurring after it
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expectation fulfill];
            request = nil;
        });
    }];
    XCTAssertFalse(request.running);
    
    [request resume];
    XCTAssertTrue(request.running);
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    XCTAssertFalse(request.running);
}

- (void)testRunningKVO
{
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing
    }];
    
    [self keyValueObservingExpectationForObject:request keyPath:@"running" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
        XCTAssertEqualObjects(change[NSKeyValueChangeNewKey], @YES);
        return YES;
    }];
    
    [request resume];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
}

- (void)testMultipleResumes
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [expectation fulfill];
    }];
    [request resume];
    [request resume];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
}

- (void)testReuse
{
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing
    }];
    
    // Wait until the request is not running anymore
    [self keyValueObservingExpectationForObject:request keyPath:@"running" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
        return [change[NSKeyValueChangeNewKey] isEqual:@NO];
    }];
    
    [request resume];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    // Restart it
    [self keyValueObservingExpectationForObject:request keyPath:@"running" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
        return [change[NSKeyValueChangeNewKey] isEqual:@YES];
    }];
    
    [request resume];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
}

- (void)testReuseAfterCancel
{
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing
    }];
    
    // Wait until the request is not running anymore
    [self keyValueObservingExpectationForObject:request keyPath:@"running" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
        return [change[NSKeyValueChangeNewKey] isEqual:@NO];
    }];
    
    [request resume];
    [request cancel];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
    
    // Restart it
    [self keyValueObservingExpectationForObject:request keyPath:@"running" handler:^BOOL(id  _Nonnull observedObject, NSDictionary * _Nonnull change) {
        return [change[NSKeyValueChangeNewKey] isEqual:@YES];
    }];
    
    [request resume];
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
}

- (void)testNestedRequests
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Requests succeeded"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    [[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(data);
        XCTAssertNil(error);
        
        [[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            XCTAssertNotNil(data);
            XCTAssertNil(error);
            
            [expectation fulfill];
        }] resume];
    }] resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

- (void)testCopy
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    [[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(data);
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        [expectation fulfill];
    }].copy resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}


@end
