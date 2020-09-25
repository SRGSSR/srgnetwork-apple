//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NetworkBaseTestCase.h"

// For tests, you can use:
//   - https://httpbin.org for HTTP-related tests.
//   - https://badssl.com for SSL-related tests.

/**
 *  Check whether two arrays of network states (booleans) are consistent. This is the case if all last common states are
 *  consistent. Checking for simple equality does not work, as some unit tests might leave the initial state either as
 *  running or not.
 */
static BOOL NetworkActivtiyStatesAreConsistent(NSArray<NSNumber *> *states1, NSArray<NSNumber *> *states2)
{
    if (states1.count < states2.count) {
        return [[states2 subarrayWithRange:NSMakeRange(states2.count - states1.count, states1.count)] isEqualToArray:states1];
    }
    else {
        return [[states1 subarrayWithRange:NSMakeRange(states1.count - states2.count, states2.count)] isEqualToArray:states2];
    }
}

@interface NetworkActivityManagementTestCase : NetworkBaseTestCase

@end

@implementation NetworkActivityManagementTestCase

#pragma mark Tests

- (void)testNormalNetworkActivity
{
    NSMutableArray<NSNumber *> *states = [NSMutableArray array];
    [SRGNetworkActivityManagement enableWithHandler:^(BOOL active) {
        [states addObject:@(active)];
    }];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request succeeded"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Fulfill expectation after block execution to capture the `running` update occurring after it
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expectation fulfill];
        });
    }];
    [request resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
    
    NSArray<NSNumber *> *expectedStates = @[@NO, @YES, @NO];
    XCTAssertTrue(NetworkActivtiyStatesAreConsistent(states, expectedStates));
}

- (void)testNormalNetworkActivityWithBackgroundRequest
{
    NSMutableArray<NSNumber *> *states = [NSMutableArray array];
    [SRGNetworkActivityManagement enableWithHandler:^(BOOL active) {
        [states addObject:@(active)];
    }];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request succeeded"];
    
    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
        SRGRequest *request = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // Fulfill expectation after block execution to capture the `running` update occurring after it
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [expectation fulfill];
            });
        }];
        [request resume];
    });
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
    
    NSArray<NSNumber *> *expectedStates = @[@NO, @YES, @NO];
    XCTAssertTrue(NetworkActivtiyStatesAreConsistent(states, expectedStates));
}

- (void)testEnableNetworkActivityWhenActive
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request succeeded"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Fulfill expectation after block execution to capture the `running` update occurring after it
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expectation fulfill];
        });
    }];
    [request resume];
    
    NSMutableArray<NSNumber *> *states = [NSMutableArray array];
    [SRGNetworkActivityManagement enableWithHandler:^(BOOL active) {
        [states addObject:@(active)];
    }];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
    
    NSArray<NSNumber *> *expectedStates = @[@YES, @NO];
    XCTAssertTrue(NetworkActivtiyStatesAreConsistent(states, expectedStates));
}

- (void)testDisableNetworkActivity
{
    NSMutableArray<NSNumber *> *states = [NSMutableArray array];
    [SRGNetworkActivityManagement enableWithHandler:^(BOOL active) {
        [states addObject:@(active)];
    }];
    
    [SRGNetworkActivityManagement disable];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request succeeded"];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Fulfill expectation after block execution to capture the `running` update occurring after it
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expectation fulfill];
        });
    }];
    [request resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
    
    NSArray<NSNumber *> *expectedStates = @[@NO];
    XCTAssertTrue(NetworkActivtiyStatesAreConsistent(states, expectedStates));
}

- (void)testDisableNetworkActivityWhenActive
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request succeeded"];
    
    NSMutableArray<NSNumber *> *states = [NSMutableArray array];
    [SRGNetworkActivityManagement enableWithHandler:^(BOOL active) {
        [states addObject:@(active)];
    }];
    
    NSURL *URL = [NSURL URLWithString:@"https://httpbin.org/bytes/100"];
    SRGRequest *request = [SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:URL] session:NSURLSession.sharedSession completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Fulfill expectation after block execution to capture the `running` update occurring after it
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expectation fulfill];
        });
    }];
    [request resume];
    
    [SRGNetworkActivityManagement disable];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
    
    NSArray<NSNumber *> *expectedStates = @[@NO, @YES, @NO];
    XCTAssertTrue(NetworkActivtiyStatesAreConsistent(states, expectedStates));
}

@end
