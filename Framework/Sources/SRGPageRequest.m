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

@property (nonatomic, copy) SRGPageSizer sizer;
@property (nonatomic, copy) SRGObjectPaginator paginator;
@property (nonatomic, copy) SRGObjectPageCompletionBlock pageCompletionBlock;

@end

@implementation SRGPageRequest

#pragma mark Object lifecycle

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                            parser:(SRGResponseParser)parser
                              page:(SRGPage *)page
                             sizer:(SRGPageSizer)sizer
                         paginator:(SRGObjectPaginator)paginator
                   completionBlock:(SRGObjectPageCompletionBlock)completionBlock
{
    if (! page) {
        page = [[SRGPage alloc] initWithSize:SRGPageDefaultSize number:0 URLRequest:URLRequest];
    }
    
    __block SRGPage *nextPage = nil;
    
    if (self = [super initWithURLRequest:page.URLRequest session:session parser:parser extractor:^(id  _Nullable object, NSURLResponse * _Nullable response) {
        NSAssert(! NSThread.isMainThread, @"Must always be executed in the background");
        NSURLRequest *nextURLRequest = paginator(URLRequest, object, response, page.size, page.number + 1);
        nextPage = nextURLRequest ? [[SRGPage alloc] initWithSize:page.size number:page.number + 1 URLRequest:nextURLRequest] : nil;
    } completionBlock:^(id  _Nullable object, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completionBlock(object, page, nextPage, response, error);
    }]) {
        self.firstPageURLRequest = URLRequest;
        self.page = page;
        self.sizer = sizer;
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
        return self.sizer(self.firstPageURLRequest, size);
    }
}

- (__kindof SRGPageRequest *)requestWithPage:(SRGPage *)page class:(Class)cls
{
    id request = [[cls alloc] initWithURLRequest:self.firstPageURLRequest
                                         session:self.session
                                          parser:self.parser
                                            page:page ?: self.page
                                           sizer:self.sizer
                                       paginator:self.paginator
                                 completionBlock:self.pageCompletionBlock];
    NSAssert([request isKindOfClass:SRGPageRequest.class], @"A page request subclass must be returned");
    return request;
}

@end
