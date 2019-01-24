//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NetworkBaseTestCase.h"

// TODO: Test for each type of pagination implementation
// TODO: Test data, JSON array, JSON dict

@interface PageRequestTestCase : NetworkBaseTestCase

@end

@implementation PageRequestTestCase

#pragma mark Tests

- (void)testConstruction
{
    // Default page size
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://il.srgssr.ch/integrationlayer/2.0/rts/mediaList/video/trending.json"]];
    SRGFirstPageRequest *request1 = [SRGFirstPageRequest dataRequestWithURLRequest:URLRequest session:NSURLSession.sharedSession options:0 builder:^NSURLRequest * _Nullable(NSData * _Nullable data, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number, NSURLRequest * _Nonnull firstPageURLRequest) {
        return nil;
    } completionBlock:^(NSData * _Nullable data, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }];
    XCTAssertFalse(request1.running);
    XCTAssertEqual(request1.page.number, 0);
    XCTAssertEqual(request1.page.size, 10 /*SRGPageDefaultSize*/);
    
#if 0
    // Specific page size
    SRGFirstPageRequest *request2 = [[self.dataProvider tvLatestEpisodesForVendor:SRGVendorSWI withCompletionBlock:^(NSArray<SRGMedia *> * _Nullable medias, SRGPage *page, SRGPage * _Nullable nextPage, NSHTTPURLResponse * _Nullable HTTPResponse, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPageSize:10];
    XCTAssertFalse(request2.running);
    XCTAssertEqual(request2.page.number, 0);
    XCTAssertEqual(request2.page.size, 10);
    
    // Override with nil page
    SRGPageRequest *request3 = [[self.dataProvider tvLatestEpisodesForVendor:SRGVendorSWI withCompletionBlock:^(NSArray<SRGMedia *> * _Nullable medias, SRGPage *page, SRGPage * _Nullable nextPage, NSHTTPURLResponse * _Nullable HTTPResponse, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPage:nil];
    XCTAssertFalse(request3.running);
    XCTAssertEqual(request3.page.number, 0);
    XCTAssertEqual(request3.page.size, SRGPageDefaultSize);
    
    // Incorrect page size
    SRGFirstPageRequest *request4 = [[self.dataProvider tvLatestEpisodesForVendor:SRGVendorSWI withCompletionBlock:^(NSArray<SRGMedia *> * _Nullable medias, SRGPage *page, SRGPage * _Nullable nextPage, NSHTTPURLResponse * _Nullable HTTPResponse, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPageSize:0];
    XCTAssertFalse(request4.running);
    XCTAssertEqual(request4.page.number, 0);
    XCTAssertEqual(request4.page.size, 1);
    
    // Over maximum page size
    SRGFirstPageRequest *request5 = [[self.dataProvider tvEditorialMediasForVendor:SRGVendorSWI withCompletionBlock:^(NSArray<SRGMedia *> * _Nullable medias, SRGPage * _Nonnull page, SRGPage * _Nullable nextPage, NSHTTPURLResponse * _Nullable HTTPResponse, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPageSize:101];
    XCTAssertFalse(request5.running);
    XCTAssertEqual(request5.page.number, 0);
    XCTAssertEqual(request5.page.size, 100);
    
    // Override with page size, twice
    SRGFirstPageRequest *request6 = [[[self.dataProvider tvLatestEpisodesForVendor:SRGVendorSWI withCompletionBlock:^(NSArray<SRGMedia *> * _Nullable medias, SRGPage *page, SRGPage * _Nullable nextPage, NSHTTPURLResponse * _Nullable HTTPResponse, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPageSize:18] requestWithPageSize:3];
    XCTAssertFalse(request6.running);
    XCTAssertEqual(request6.page.number, 0);
    XCTAssertEqual(request6.page.size, 3);
    
    // First page
    SRGPageRequest *request7 = [[[self.dataProvider tvLatestEpisodesForVendor:SRGVendorSWI withCompletionBlock:^(NSArray<SRGMedia *> * _Nullable medias, SRGPage *page, SRGPage * _Nullable nextPage, NSHTTPURLResponse * _Nullable HTTPResponse, NSError * _Nullable error) {
        // Nothing, the request isn't run
    }] requestWithPageSize:36] requestWithPage:nil];
    XCTAssertFalse(request7.running);
    XCTAssertEqual(request7.page.number, 0);
    XCTAssertEqual(request7.page.size, 36);
#endif
}


@end
