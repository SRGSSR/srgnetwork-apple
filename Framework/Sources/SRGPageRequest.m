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

@property (nonatomic, copy) SRGObjectPageSeed seed;
@property (nonatomic, copy) SRGObjectPaginator paginator;
@property (nonatomic, copy) SRGObjectPageCompletionBlock pageCompletionBlock;

@end

@implementation SRGPageRequest

#pragma mark Object lifecycle

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                           options:(SRGRequestOptions)options
                            parser:(SRGResponseParser)parser
                              page:(SRGPage *)page
                              seed:(SRGObjectPageSeed)seed
                         paginator:(SRGObjectPaginator)paginator
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
        
        NSURLRequest *nextURLRequest = paginator(URLRequest, object, response, page.size, page.number + 1);
        SRGPage *nextPage = nextURLRequest ? [[SRGPage alloc] initWithSize:page.size number:page.number + 1 URLRequest:nextURLRequest] : nil;
        completionBlock(object, page, nextPage, response, nil);
    };
    
    if (self = [super initWithURLRequest:page.URLRequest session:session options:options parser:parser completionBlock:pageCompletionBlock]) {
        self.firstPageURLRequest = URLRequest;
        self.page = page;
        self.seed = seed;
        self.paginator = paginator;
        self.pageCompletionBlock = completionBlock;
    }
    return self;
}

#pragma mark Request generation

- (NSURLRequest *)URLRequestForFirstPageWithSize:(NSUInteger)size
{
    if (size == SRGPageDefaultSize) {
        return self.firstPageURLRequest;
    }
    else {
        return self.seed(self.firstPageURLRequest, size);
    }
}

- (__kindof SRGPageRequest *)requestWithPage:(SRGPage *)page class:(Class)cls
{
    id request = [[cls alloc] initWithURLRequest:self.firstPageURLRequest
                                         session:self.session
                                         options:self.options
                                          parser:self.parser
                                            page:page ?: self.page
                                            seed:self.seed
                                       paginator:self.paginator
                                 completionBlock:self.pageCompletionBlock];
    NSAssert([request isKindOfClass:SRGPageRequest.class], @"A page request subclass must be returned");
    return request;
}

@end
