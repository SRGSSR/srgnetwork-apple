//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGFirstPageRequest.h"

#import "NSBundle+SRGNetwork.h"

#import "SRGNetworkError.h"
#import "SRGPage+Private.h"
#import "SRGPageRequest+Private.h"
#import "SRGRequest+Private.h"

// Agnostic block signatures.
typedef id _Nullable (^SRGPageParser)(NSData * _Nullable data, NSError **pError);
typedef NSURLRequest * _Nullable (^SRGObjectPageBuilder)(id _Nullable object, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number, NSURLRequest *firstPageURLRequest);
typedef void (^SRGObjectPageCompletionBlock)(id _Nullable object, SRGPage *page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface SRGFirstPageRequest ()

@property (nonatomic, copy) SRGPageParser parser;
@property (nonatomic, copy) SRGObjectPageBuilder builder;
@property (nonatomic, copy) SRGObjectPageCompletionBlock pageCompletionBlock;

@end

@implementation SRGFirstPageRequest

#pragma mark Class methods

+ (SRGFirstPageRequest *)dataRequestWithURLRequest:(NSURLRequest *)URLRequest
                                           session:(NSURLSession *)session
                                           options:(SRGRequestOptions)options
                                           builder:(SRGDataPageBuilder)builder
                                   completionBlock:(SRGDataPageCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest
                                          session:session
                                          options:options
                                           parser:nil
                                             page:nil
                                          builder:builder
                                  completionBlock:completionBlock];
}

+ (SRGFirstPageRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                session:(NSURLSession *)session
                                                options:(SRGRequestOptions)options
                                                builder:(SRGJSONArrayPageBuilder)builder
                                        completionBlock:(SRGJSONArrayPageCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest session:session options:options parser:^id _Nullable(NSData * _Nullable data, NSError *__autoreleasing *pError) {
        id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:pError];
        if (JSONObject && ! [JSONObject isKindOfClass:NSArray.class]) {
            if (pError) {
                *pError = [NSError errorWithDomain:SRGNetworkErrorDomain
                                              code:SRGNetworkErrorInvalidData
                                          userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"Error message returned when a server response data is incorrect.") }];
            }
            return nil;
        }
        else {
            return JSONObject;
        }
    } page:nil builder:^NSURLRequest * _Nullable(id  _Nullable object, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number, NSURLRequest *firstPageURLRequest) {
        return builder(response, size, number, firstPageURLRequest);
    } completionBlock:completionBlock];
}

+ (SRGFirstPageRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest
                                                     session:(NSURLSession *)session
                                                     options:(SRGRequestOptions)options
                                                     builder:(SRGJSONDictionaryPageBuilder)builder
                                             completionBlock:(SRGJSONDictionaryPageCompletionBlock)completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest session:session options:options parser:^id _Nullable(NSData * _Nullable data, NSError *__autoreleasing *pError) {
        id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:pError];
        if (JSONObject && ! [JSONObject isKindOfClass:NSDictionary.class]) {
            if (pError) {
                *pError = [NSError errorWithDomain:SRGNetworkErrorDomain
                                              code:SRGNetworkErrorInvalidData
                                          userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"Error message returned when a server response data is incorrect.") }];
            }
            return nil;
        }
        else {
            return JSONObject;
        }
    } page:nil builder:builder completionBlock:completionBlock];
}

#pragma mark Object lifecycle

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                           options:(SRGRequestOptions)options
                            parser:(SRGPageParser)parser
                              page:(SRGPage *)page
                           builder:(SRGObjectPageBuilder)builder
                   completionBlock:(SRGObjectPageCompletionBlock)completionBlock
{
    // TODO: Default size constant
    if (! page) {
        page = [self firstPageWithSize:10];
    }
    
    if (self = [super initWithURLRequest:URLRequest session:session options:options completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, page, nil, response, error);
            return;
        }
        
        NSError *parsingError = nil;
        id object = parser ? parser(data, &parsingError) : data;
        if (parsingError) {
            completionBlock(nil, nil, nil, response, parsingError);
            return;
        }
        
        NSURLRequest *nextURLRequest = self.builder(object, response, page.size, page.number, URLRequest);
        SRGPage *nextPage = nextURLRequest ? [[SRGPage alloc] initWithSize:page.size number:page.number + 1 URLRequest:nextURLRequest] : nil;
        completionBlock(object, page, nextPage, response, nil);
        
    }]) {
        self.parser = parser;
        self.page = page;
        self.builder = builder;
        self.pageCompletionBlock = completionBlock;
    }
    return self;
}

#pragma mark Page management

- (SRGPage *)firstPageWithSize:(NSUInteger)pageSize
{
    return [[SRGPage alloc] initWithSize:pageSize number:0 URLRequest:self.URLRequest];
}

- (__kindof SRGPageRequest *)requestWithPage:(SRGPage *)page withClass:(Class)cls
{
    return [[cls alloc] initWithURLRequest:page.URLRequest
                                   session:self.session
                                   options:self.options
                                    parser:self.parser
                                      page:page
                                   builder:self.builder
                           completionBlock:self.pageCompletionBlock];
}

- (SRGFirstPageRequest *)requestWithPageSize:(NSUInteger)pageSize
{
    SRGPage *firstPage = [self firstPageWithSize:pageSize];
    return [self requestWithPage:firstPage withClass:SRGFirstPageRequest.class];
}

- (SRGPageRequest *)requestWithPage:(SRGPage *)page
{
    return [self requestWithPage:page withClass:SRGPageRequest.class];
}

@end
