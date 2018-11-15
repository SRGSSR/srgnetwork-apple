//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGNetworkRequest.h"

#import "NSBundle+SRGNetwork.h"
#import "NSHTTPURLResponse+SRGNetwork.h"
#import "SRGNetworkError.h"

@interface  SRGNetworkRequest ()

@property (nonatomic) NSURLRequest *URLRequest;
@property (nonatomic) NSURLSessionTask *sessionTask;

@end

@implementation SRGNetworkRequest

#pragma marl Object lifecycle

- (instancetype)initWithURLRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;
{
    if (self = [super init]) {
        self.URLRequest = request;
        self.sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
                    if ((options & SRGNetworkRequestOptionCancellationErrorsProcessed) == 0) {
                        return;
                    }
                }
                else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorServerCertificateUntrusted) {
                    if ((options & SRGNetworkRequestPublicWiFiIssuesDisabled) == 0) {
                        // TODO: Use SRGNetworkFailingURLKey, or keep NSURLErrorKey? (probably keep if it was in the original error, so that
                        //       only the message is changed)
                        NSError *publicWiFiError = [NSError errorWithDomain:error.domain
                                                                       code:error.code
                                                                   userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"You are likely connected to a public wifi network with no Internet access", @"The error message when request a media or a media list on a public network with no Internet access (e.g. SBB)"),
                                                                               NSURLErrorKey : self.URLRequest.URL }];
                        completionBlock(nil, response, publicWiFiError);
                        return;
                    }
                }
                
                completionBlock(nil, response, error);
                return;
            }
            
            if ([response isKindOfClass:NSHTTPURLResponse.class]) {
                NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
                NSInteger HTTPStatusCode = HTTPURLResponse.statusCode;
                
                // Properly handle HTTP error codes >= 400 as real errors
                if (HTTPStatusCode >= 400) {
                    if ((options & SRGNetworkRequestOptionHTTPErrorsDisabled) == 0) {
                        NSError *HTTPError = [NSError errorWithDomain:SRGNetworkErrorDomain
                                                                 code:SRGNetworkErrorHTTP
                                                             userInfo:@{ NSLocalizedDescriptionKey : [NSHTTPURLResponse srg_localizedStringForStatusCode:HTTPStatusCode],
                                                                         SRGNetworkFailingURLKey : response.URL,
                                                                         SRGNetworkHTTPStatusCodeKey : @(HTTPStatusCode) }];
                        completionBlock(nil, response, HTTPError);
                    }
                    else {
                        completionBlock(nil, response, nil);
                    }
                    return;
                }
            }
            
            completionBlock(data, response, nil);
        }];
    }
    return self;
}

- (instancetype)initWithJSONDictionaryURLRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSDictionary * _Nullable, NSURLResponse * _Nullable response, NSError * _Nullable))completionBlock
{
    return [self initWithURLRequest:request session:session options:options completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, response, error);
            return;
        }
        
        id JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (! JSONDictionary || ! [JSONDictionary isKindOfClass:NSDictionary.class]) {
            completionBlock(nil, response, [NSError errorWithDomain:SRGNetworkErrorDomain
                                                               code:SRGNetworkErrorInvalidData
                                                           userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"Error message returned when a server response data is incorrect.") }]);
            return;
        }
        
        completionBlock(JSONDictionary, response, nil);
    }];
}

- (instancetype)initWithJSONArrayURLRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSArray * _Nullable, NSURLResponse * _Nullable response, NSError * _Nullable))completionBlock
{
    return [self initWithURLRequest:request session:session options:options completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, response, error);
            return;
        }
        
        id JSONArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (! JSONArray || ! [JSONArray isKindOfClass:NSArray.class]) {
            completionBlock(nil, response, [NSError errorWithDomain:SRGNetworkErrorDomain
                                                               code:SRGNetworkErrorInvalidData
                                                           userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"Error message returned when a server response data is incorrect.") }]);
            return;
        }
        
        completionBlock(JSONArray, response, nil);
    }];
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return [self initWithURLRequest:[NSURLRequest new] session:[NSURLSession new] options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing
    }];
}

#pragma mark Request management

- (void)resume
{
    [self.sessionTask resume];
}

- (void)cancel
{
    [self.sessionTask cancel];
}

@end
