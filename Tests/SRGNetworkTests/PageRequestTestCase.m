//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NetworkBaseTestCase.h"

@import libextobjc;

// For more test APIs, have a look at https://github.com/toddmotto/public-apis

@interface PageRequestTestCase : NetworkBaseTestCase

@end

@implementation PageRequestTestCase

#pragma mark Service examples

- (SRGFirstPageRequest *)integrationLayerV2LatestVideosWithCompletionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock
{
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://il.srgssr.ch/integrationlayer/2.0/rts/mediaList/video/latestEpisodes.json"]];
    return [SRGFirstPageRequest JSONDictionaryRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession sizer:^NSURLRequest *(NSURLRequest * _Nonnull URLRequest, NSUInteger size) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
        URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"pageSize" value:@(size).stringValue] ];
        return [NSURLRequest requestWithURL:URLComponents.URL];
    } paginator:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull URLRequest, NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
        id next = JSONDictionary[@"next"];
        NSURL *nextURL = [next isKindOfClass:NSString.class] ? [NSURL URLWithString:next] : nil;
        return nextURL ? [NSURLRequest requestWithURL:nextURL] : nil;
    } completionBlock:completionBlock];
}

- (SRGFirstPageRequest *)hummingbirdV4SportNewsFeedWithCompletionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock
{
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://hummingbird.rts.ch/api/sport/v4/feed"]];
    return [SRGFirstPageRequest JSONDictionaryRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession sizer:^NSURLRequest *(NSURLRequest * _Nonnull URLRequest, NSUInteger size) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
        URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"limit" value:@(size).stringValue] ];
        return [NSURLRequest requestWithURL:URLComponents.URL];
    } paginator:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull URLRequest, NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
        
        NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray array];
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"offset" value:@(number * size).stringValue]];
        if (size != SRGPageUnspecifiedSize) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"limit" value:@(size).stringValue]];
        }
        URLComponents.queryItems = queryItems.copy;
        
        return [NSURLRequest requestWithURL:URLComponents.URL];
    } completionBlock:completionBlock];
}

- (SRGFirstPageRequest *)anAPIOfIceAndFireCharactersRandomAccessWithCompletionBlock:(SRGJSONArrayPageCompletionBlock)completionBlock
{
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.anapioficeandfire.com/api/characters"]];
    return [SRGFirstPageRequest JSONArrayRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession sizer:^NSURLRequest *(NSURLRequest * _Nonnull URLRequest, NSUInteger size) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
        URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"pageSize" value:@(size).stringValue] ];
        return [NSURLRequest requestWithURL:URLComponents.URL];
    } paginator:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull URLRequest, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
        // Remark: The next page URL could also be extracted by casting the response to an `NSHTTPURLResponse` and having
        //         a look at the `Link` header.
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
        
        NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray array];
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"page" value:@(number + 1).stringValue]];
        if (size != SRGPageUnspecifiedSize) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"pageSize" value:@(size).stringValue]];
        }
        URLComponents.queryItems = queryItems.copy;
        
        return [NSURLRequest requestWithURL:URLComponents.URL];
    } completionBlock:completionBlock];
}

#pragma mark Tests

- (void)testConstruction
{
    // Unspecified page size
    SRGFirstPageRequest *request1 = [self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }];
    XCTAssertFalse(request1.running);
    XCTAssertEqual(request1.page.number, 0);
    XCTAssertEqual(request1.page.size, SRGPageUnspecifiedSize);
    
    // Specific page size
    SRGFirstPageRequest *request2 = [[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPageSize:10];
    XCTAssertFalse(request2.running);
    XCTAssertEqual(request2.page.number, 0);
    XCTAssertEqual(request2.page.size, 10);
    
    // Override with nil page
    SRGPageRequest *request3 = [[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPage:nil];
    XCTAssertFalse(request3.running);
    XCTAssertEqual(request3.page.number, 0);
    XCTAssertEqual(request3.page.size, SRGPageUnspecifiedSize);
    
    // Incorrect page size
    SRGFirstPageRequest *request4 = [[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPageSize:1];
    XCTAssertFalse(request4.running);
    XCTAssertEqual(request4.page.number, 0);
    XCTAssertEqual(request4.page.size, 1);
    
    // Override with page size, twice
    SRGFirstPageRequest *request5 = [[[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPageSize:18] requestWithPageSize:3];
    XCTAssertFalse(request5.running);
    XCTAssertEqual(request5.page.number, 0);
    XCTAssertEqual(request5.page.size, 3);
    
    // First page
    SRGPageRequest *request6 = [[[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPageSize:36] requestWithPage:nil];
    XCTAssertFalse(request6.running);
    XCTAssertEqual(request6.page.number, 0);
    XCTAssertEqual(request6.page.size, 36);
    
    // Override with unspecified page size
    SRGFirstPageRequest *request7 = [[[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPageSize:36] requestWithPageSize:SRGPageUnspecifiedSize];
    XCTAssertFalse(request7.running);
    XCTAssertEqual(request7.page.number, 0);
    XCTAssertEqual(request7.page.size, SRGPageUnspecifiedSize);
}

- (void)testPageInformation
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    __block SRGFirstPageRequest *request = nil;
    request = [[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertEqual(page.number, 0);
        XCTAssertEqual(page.size, 5);
        
        XCTAssertEqual(request.page.number, 0);
        XCTAssertEqual(request.page.size, 5);
        
        [expectation fulfill];
        request = nil;
    }] requestWithPageSize:5];
    
    XCTAssertEqual(request.page.number, 0);
    XCTAssertEqual(request.page.size, 5);
    
    [request resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

- (void)testIntegrationLayerV2Pagination
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Requests succeeded"];
    
    __block SRGFirstPageRequest *request = nil;
    request = [[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (page.number == 0 && nextPage) {
            [[request requestWithPage:nextPage] resume];
        }
        else if (page.number == 1) {
            [expectation fulfill];
            request = nil;
        }
        else {
            XCTFail(@"Only first two pages are expected");
        }
    }] requestWithPageSize:2];
    [request resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

- (void)testHummingbirdV4Pagination
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Requests succeeded"];
    
    __block SRGFirstPageRequest *request = nil;
    request = [[self hummingbirdV4SportNewsFeedWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (page.number == 0 && nextPage) {
            [[request requestWithPage:nextPage] resume];
        }
        else if (page.number == 1) {
            [expectation fulfill];
            request = nil;
        }
        else {
            XCTFail(@"Only first two pages are expected");
        }
    }] requestWithPageSize:2];
    [request resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

- (void)testAnAPIOfIceAndFirePagination
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Requests succeeded"];
    
    __block SRGFirstPageRequest *request = nil;
    request = [[self anAPIOfIceAndFireCharactersRandomAccessWithCompletionBlock:^(NSArray * _Nullable JSONArray, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertEqual(JSONArray.count, 2);
        
        if (page.number == 0 && nextPage) {
            [[request requestWithPage:nextPage] resume];
        }
        else if (page.number == 1) {
            [expectation fulfill];
            request = nil;
        }
        else {
            XCTFail(@"Only first two pages are expected");
        }
    }] requestWithPageSize:2];
    [request resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

- (void)testDefaultPaginationSizerBehavior
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Requests succeeded"];
    
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://il.srgssr.ch/integrationlayer/2.0/rts/mediaList/video/latestEpisodes.json"]];;
    [[SRGFirstPageRequest JSONDictionaryRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession sizer:^NSURLRequest *(NSURLRequest * _Nonnull URLRequest, NSUInteger size) {
        XCTFail(@"Is not called when no sizing occurs");
        // Dummy
        return URLRequest;
    } paginator:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull URLRequest, NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
        // Dummy
        return URLRequest;
    } completionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(JSONDictionary);
        [expectation fulfill];
    }] resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

- (void)testPageRequestWithOptions
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Requests succeeded"];
    
    __block SRGFirstPageRequest *request = nil;
    request = [[self anAPIOfIceAndFireCharactersRandomAccessWithCompletionBlock:^(NSArray * _Nullable JSONArray, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(JSONArray);
        XCTAssertNil(error);
        
        if (page.number == 0 && nextPage) {
            [[request requestWithPage:nextPage] resume];
        }
        else if (page.number == 1) {
            [expectation fulfill];
            request = nil;
        }
        else {
            XCTFail(@"Only first two pages are expected");
        }
    }] requestWithOptions:SRGRequestOptionCancellationErrorsEnabled];
    [request resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

- (void)testCopy
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Requests succeeded"];
    
    __block SRGFirstPageRequest *request = nil;
    request = [[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (page.number == 0 && nextPage) {
            [[request requestWithPage:nextPage] resume];
        }
        else if (page.number == 1) {
            [expectation fulfill];
            request = nil;
        }
        else {
            XCTFail(@"Only first two pages are expected");
        }
    }] requestWithPageSize:2].copy;
    [request resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

- (void)testOptionInheritanceWhenApplyingPageSize
{
    SRGFirstPageRequest *request1 = [self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing, will not be run
    }];
    XCTAssertEqual(request1.options, 0);
    
    SRGFirstPageRequest *request2 = [request1 requestWithOptions:SRGRequestOptionCancellationErrorsEnabled];
    XCTAssertEqual(request2.options, SRGRequestOptionCancellationErrorsEnabled);
    
    SRGFirstPageRequest *request3 = [request2 requestWithPageSize:20];
    XCTAssertEqual(request3.options, SRGRequestOptionCancellationErrorsEnabled);
}

- (void)testOptionInheritanceBetweenPages
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Requests succeeded"];
    
    __block SRGFirstPageRequest *request = nil;
    request = [[[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (page.number == 0 && nextPage) {
            SRGPageRequest *nextRequest = [request requestWithPage:nextPage];
            XCTAssertEqual(nextRequest.options, SRGRequestOptionCancellationErrorsEnabled);
            [nextRequest resume];
        }
        else if (page.number == 1) {
            [expectation fulfill];
            request = nil;
        }
        else {
            XCTFail(@"Only first two pages are expected");
        }
    }] requestWithPageSize:2] requestWithOptions:SRGRequestOptionCancellationErrorsEnabled];
    [request resume];
    
    XCTAssertEqual(request.options, SRGRequestOptionCancellationErrorsEnabled);
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

@end
