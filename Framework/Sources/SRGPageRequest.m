//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGPageRequest.h"

#import "SRGBaseRequest+Subclassing.h"
#import "SRGPage+Private.h"
#import "SRGPageRequest+Subclassing.h"

@interface SRGPageRequest ()

@property (nonatomic) NSURLRequest *firstPageURLRequest;
@property (nonatomic) SRGPage *page;

@property (nonatomic, copy) SRGObjectPageBuilder builder;
@property (nonatomic, copy) SRGObjectPageCompletionBlock pageCompletionBlock;

@end

@implementation SRGPageRequest

#pragma mark Object lifecycle

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                           options:(SRGRequestOptions)options
                            parser:(SRGResponseParser)parser
                              page:(SRGPage *)page
                           builder:(SRGObjectPageBuilder)builder
                   completionBlock:(SRGObjectPageCompletionBlock)completionBlock
{
    if (! page) {
        page = [[SRGPage alloc] initWithSize:SRGPageDefaultSize number:0 URLRequest:URLRequest];
    }
    
    SRGObjectCompletionBlock pageCompletionBlock = ^(id  _Nullable object, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, page, nil, response, error);
            return;
        }
        
        NSURLRequest *nextURLRequest = builder(object, response, page.size, page.number + 1);
        SRGPage *nextPage = nextURLRequest ? [[SRGPage alloc] initWithSize:page.size number:page.number + 1 URLRequest:nextURLRequest] : nil;
        completionBlock(object, page, nextPage, response, nil);
    };
    
    if (self = [super initWithURLRequest:page.URLRequest session:session options:options parser:parser completionBlock:pageCompletionBlock]) {
        self.firstPageURLRequest = URLRequest;
        self.page = page;
        self.builder = builder;
        self.pageCompletionBlock = completionBlock;
    }
    return self;
}

#pragma mark Request generation

- (NSURLRequest *)URLRequestForPageWithSize:(NSUInteger)size number:(NSUInteger)number
{
    if (size == SRGPageDefaultSize && number == 0) {
        return self.firstPageURLRequest;
    }
    else {
        return self.builder(nil, nil, size, number) ?: self.firstPageURLRequest;
    }
}

- (__kindof SRGPageRequest *)requestWithPage:(SRGPage *)page class:(Class)cls
{
    id request = [[cls alloc] initWithURLRequest:self.firstPageURLRequest
                                         session:self.session
                                         options:self.options
                                          parser:self.parser
                                            page:page ?: self.page
                                         builder:self.builder
                                 completionBlock:self.pageCompletionBlock];
    NSAssert([request isKindOfClass:SRGPageRequest.class], @"A page request subclass must be returned");
    return request;
}

@end
