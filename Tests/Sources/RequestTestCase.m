//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <SRGNetwork/SRGNetwork.h>
#import <XCTest/XCTest.h>

@interface RequestTestCase : XCTestCase

@end

@implementation RequestTestCase

#pragma mark Helpers

- (XCTestExpectation *)expectationForElapsedTimeInterval:(NSTimeInterval)timeInterval withHandler:(void (^)(void))handler
{
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"Wait for %@ seconds", @(timeInterval)]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
        handler ? handler() : nil;
    });
    return expectation;
}

#pragma mark Tests

- (void)testSuccessful
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(data);
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [request resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testSuccessfulJSONDictionary
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/json"];
    SRGRequest *request = [SRGRequest JSONDictionaryRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(JSONDictionary);
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [request resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testNeverStarted
{
    [self expectationForElapsedTimeInterval:3. withHandler:nil];
    
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/bytes/100"];
    __unused SRGRequest *request = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTFail(@"Completion block must not be called");
    }];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testHTTPError
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/status/404"];
    SRGRequest *request = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNil(data);
        XCTAssertNotNil(response);
        XCTAssertEqualObjects(error.domain, SRGNetworkErrorDomain);
        XCTAssertEqual(error.code, SRGNetworkErrorHTTP);
        XCTAssertEqualObjects(error.userInfo[SRGNetworkHTTPStatusCodeKey], @404);
        XCTAssertEqualObjects(error.userInfo[SRGNetworkFailingURLKey], URL);
        [expectation fulfill];
    }];
    [request resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testIncorrectJSONDictionary
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest JSONDictionaryRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNil(JSONDictionary);
        XCTAssertNotNil(response);
        XCTAssertEqualObjects(error.domain, SRGNetworkErrorDomain);
        XCTAssertEqual(error.code, SRGNetworkErrorInvalidData);
        [expectation fulfill];
    }];
    [request resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testCancel
{
    [self expectationForElapsedTimeInterval:3. withHandler:nil];
    
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTFail(@"Completion block must not be called");
    }];
    [request resume];
    [request cancel];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testCancellationErrorsEnabled
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:SRGRequestOptionCancellationErrorsEnabled completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNil(data);
        XCTAssertNil(response);
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorCancelled);
        [expectation fulfill];
    }];
    [request resume];
    [request cancel];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testHTTPErrorsDisabled
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/status/404"];
    SRGRequest *request = [SRGRequest requestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession options:SRGRequestOptionHTTPErrorsDisabled completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNil(data);
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [request resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

@end
