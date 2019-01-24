//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NetworkBaseTestCase.h"

#import <libextobjc/libextobjc.h>

// TODO: Test for each type of pagination implementation
// TODO: Test data, JSON array, JSON dict

@interface PageRequestTestCase : NetworkBaseTestCase

@end

@implementation PageRequestTestCase

#pragma mark Service examples

- (SRGFirstPageRequest *)integrationLayerV2LatestVideosWithCompletionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock
{
    // TODO: Document builder: Only called when building a next page or for custom page size setting
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://il.srgssr.ch/integrationlayer/2.0/rts/mediaList/video/latestEpisodes.json"]];
    return [SRGFirstPageRequest JSONDictionaryRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession options:0 builder:^NSURLRequest * _Nullable(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number) {
        id next = JSONDictionary[@"next"];
        NSURL *nextURL = [next isKindOfClass:NSString.class] ? [NSURL URLWithString:next] : nil;
        if (nextURL) {
            return [NSURLRequest requestWithURL:nextURL];
        }
        else {
            NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URLRequest.URL resolvingAgainstBaseURL:NO];
            NSMutableArray<NSURLQueryItem *> *queryItems = [URLComponents.queryItems mutableCopy] ?: [NSMutableArray array];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", @keypath(NSURLQueryItem.new, name), @"pageSize"];
            [queryItems filterUsingPredicate:predicate];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"pageSize" value:@(size).stringValue]];
            
            URLComponents.queryItems = [queryItems copy];
            return [NSURLRequest requestWithURL:URLComponents.URL];
        }
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
    
    [self waitForExpectationsWithTimeout:5. handler:nil];
}


@end
