//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NetworkBaseTestCase.h"

#import <libextobjc/libextobjc.h>

// For more test APIs, have a look at https://github.com/toddmotto/public-apis

@interface PageRequestTestCase : NetworkBaseTestCase

@end

@implementation PageRequestTestCase

#pragma mark Service examples

- (SRGFirstPageRequest *)integrationLayerV1LatestVideosWithCompletionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock
{
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://il.srgssr.ch/integrationlayer/1.0/ue/rts/video/latestEpisodes.json"]];
    return [SRGFirstPageRequest JSONDictionaryRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession options:0 sizer:^NSURLRequest *(NSURLRequest * _Nonnull URLRequest, NSUInteger size) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
        URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"pageSize" value:@(size).stringValue] ];
        return [NSURLRequest requestWithURL:URLComponents.URL];
    } paginator:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull URLRequest, NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
        URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"pageSize" value:@(size).stringValue],
                                      [NSURLQueryItem queryItemWithName:@"pageNumber" value:@(number + 1).stringValue] ];
        return [NSURLRequest requestWithURL:URLComponents.URL];
    } completionBlock:completionBlock];
}

- (SRGFirstPageRequest *)integrationLayerV2LatestVideosWithCompletionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock
{
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://il.srgssr.ch/integrationlayer/2.0/rts/mediaList/video/latestEpisodes.json"]];
    return [SRGFirstPageRequest JSONDictionaryRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession options:0 sizer:^NSURLRequest *(NSURLRequest * _Nonnull URLRequest, NSUInteger size) {
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
    return [SRGFirstPageRequest JSONDictionaryRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession options:0 sizer:^NSURLRequest *(NSURLRequest * _Nonnull URLRequest, NSUInteger size) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
        URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"limit" value:@(size).stringValue] ];
        return [NSURLRequest requestWithURL:URLComponents.URL];
    } paginator:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull URLRequest, NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
        URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"limit" value:@(size).stringValue],
                                      [NSURLQueryItem queryItemWithName:@"offset" value:@(number * size).stringValue] ];
        return [NSURLRequest requestWithURL:URLComponents.URL];
    } completionBlock:completionBlock];
}

- (SRGFirstPageRequest *)anAPIOfIceAndFireCharactersRandomAccessWithCompletionBlock:(SRGJSONArrayPageCompletionBlock)completionBlock
{
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.anapioficeandfire.com/api/characters"]];
    return [SRGFirstPageRequest JSONArrayRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession options:0 sizer:^NSURLRequest *(NSURLRequest * _Nonnull URLRequest, NSUInteger size) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
        URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"pageSize" value:@(size).stringValue] ];
        return [NSURLRequest requestWithURL:URLComponents.URL];
    } paginator:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull URLRequest, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
        URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"pageSize" value:@(size).stringValue],
                                      [NSURLQueryItem queryItemWithName:@"page" value:@(number + 1).stringValue] ];
        return [NSURLRequest requestWithURL:URLComponents.URL];
    } completionBlock:completionBlock];
}

#pragma mark Tests

- (void)testConstruction
{
    // Default page size
    SRGFirstPageRequest *request1 = [self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }];
    XCTAssertFalse(request1.running);
    XCTAssertEqual(request1.page.number, 0);
    XCTAssertEqual(request1.page.size, SRGPageDefaultSize);
    
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
    XCTAssertEqual(request3.page.size, SRGPageDefaultSize);
    
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
    
    // Override with default page
    SRGFirstPageRequest *request7 = [[[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPageSize:36] requestWithPageSize:SRGPageDefaultSize];
    XCTAssertFalse(request7.running);
    XCTAssertEqual(request7.page.number, 0);
    XCTAssertEqual(request7.page.size, SRGPageDefaultSize);
}

- (void)testPageInformation
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request finished"];
    
    __block SRGFirstPageRequest *request = [[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertEqual(page.number, 0);
        XCTAssertEqual(page.size, 5);
        
        XCTAssertEqual(request.page.number, 0);
        XCTAssertEqual(request.page.size, 5);
        
        [expectation fulfill];
    }] requestWithPageSize:5];
    
    XCTAssertEqual(request.page.number, 0);
    XCTAssertEqual(request.page.size, 5);
    
    [request resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

- (void)testIntegrationLayerV1Pagination
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Requests succeeded"];
    
    __block SRGFirstPageRequest *request = [[self integrationLayerV1LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (page.number == 0 && nextPage) {
            [[request requestWithPage:nextPage] resume];
        }
        else if (page.number == 1) {
            [expectation fulfill];
        }
        else {
            XCTFail(@"Only first two pages are expected");
        }
    }] requestWithPageSize:2];
    [request resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

- (void)testIntegrationLayerV2Pagination
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Requests succeeded"];
    
    __block SRGFirstPageRequest *request = [[self integrationLayerV2LatestVideosWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (page.number == 0 && nextPage) {
            [[request requestWithPage:nextPage] resume];
        }
        else if (page.number == 1) {
            [expectation fulfill];
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
    
    __block SRGFirstPageRequest *request = [[self hummingbirdV4SportNewsFeedWithCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (page.number == 0 && nextPage) {
            [[request requestWithPage:nextPage] resume];
        }
        else if (page.number == 1) {
            [expectation fulfill];
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
    
    __block SRGFirstPageRequest *request = [[self anAPIOfIceAndFireCharactersRandomAccessWithCompletionBlock:^(NSArray * _Nullable JSONArray, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertEqual(JSONArray.count, 2);
        
        if (page.number == 0 && nextPage) {
            [[request requestWithPage:nextPage] resume];
        }
        else if (page.number == 1) {
            [expectation fulfill];
        }
        else {
            XCTFail(@"Only first two pages are expected");
        }
    }] requestWithPageSize:2];
    [request resume];
    
    [self waitForExpectationsWithTimeout:30. handler:nil];
}

@end
