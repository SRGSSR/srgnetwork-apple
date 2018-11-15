//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGFirstPageRequest.h"

#import "SRGFirstPageRequest+Private.h"
#import "SRGPage+Private.h"
#import "SRGPageRequest+Private.h"
#import "SRGRequest+Private.h"

@interface SRGFirstPageRequest ()

@property (nonatomic, copy) SRGPageCompletionBlock pageCompletionBlock;

@end

@implementation SRGFirstPageRequest

#pragma mark Class methods

+ (SRGPage *)nextPageAfterPage:(SRGPage *)page fromJSONDictionary:(NSDictionary *)JSONDictionary
{
    id next = JSONDictionary[@"next"];
    
    // Ensure the next field is a string. In now and next requests, we have a next dictionary entry, which
    // does not correspond to next page information, but to next program information
    return [next isKindOfClass:NSString.class] ? [page nextPageWithURL:[NSURL URLWithString:next]] : nil;
}

#pragma mark Object lifecycle

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest session:(NSURLSession *)session pageCompletionBlock:(SRGPageCompletionBlock)pageCompletionBlock
{
    SRGPage *page = [SRGPage firstPageWithSize:SRGPageDefaultSize];
    
    SRGRequestCompletionBlock requestCompletionBlock = ^(NSDictionary * _Nullable JSONDictionary, NSHTTPURLResponse * _Nullable HTTPResponse, NSError * _Nullable error) {
        SRGPage *nextPage = [SRGFirstPageRequest nextPageAfterPage:page fromJSONDictionary:JSONDictionary];
        pageCompletionBlock(JSONDictionary, JSONDictionary[@"total"], page, nextPage, HTTPResponse, error);
    };
    
    if (self = [super initWithURLRequest:URLRequest session:session completionBlock:requestCompletionBlock]) {
        self.page = page;
        self.pageCompletionBlock = pageCompletionBlock;
    }
    return self;
}

#pragma mark Page management

- (__kindof SRGPageRequest *)requestWithPage:(SRGPage *)page withClass:(Class)cls
{
    NSURLRequest *URLRequest = [SRGPage request:self.URLRequest withPage:page];
    SRGPageRequest *pageRequest = [[cls alloc] initWithURLRequest:URLRequest session:self.session completionBlock:^(NSDictionary * _Nullable JSONDictionary, NSHTTPURLResponse * _Nullable HTTPResponse, NSError * _Nullable error) {
        SRGPage *nextPage = [SRGFirstPageRequest nextPageAfterPage:page fromJSONDictionary:JSONDictionary];
        self.pageCompletionBlock(JSONDictionary, JSONDictionary[@"total"],  page, nextPage, HTTPResponse, error);
    }];
    pageRequest.page = page;
    pageRequest.pageCompletionBlock = self.pageCompletionBlock;
    return pageRequest;
}

- (SRGFirstPageRequest *)requestWithPageSize:(NSInteger)pageSize
{
    SRGPage *page = [SRGPage firstPageWithSize:pageSize];
    return [self requestWithPage:page withClass:SRGFirstPageRequest.class];
}

- (SRGPageRequest *)requestWithPage:(SRGPage *)page
{
    if (! page) {
        page = self.page.firstPage;
    }
    
    return [self requestWithPage:page withClass:SRGPageRequest.class];
}

@end
