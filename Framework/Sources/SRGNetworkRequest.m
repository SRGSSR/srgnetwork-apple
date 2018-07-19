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

@property (nonatomic) NSURLSessionTask *sessionTask;

@end

@implementation SRGNetworkRequest

#pragma marl Object lifecycle

- (instancetype)initWithRequest:(NSURLRequest *)request session:(NSURLSession *)session withCompletionBlock:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completionBlock;
{
    if (self = [super init]) {
        self.sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
                    return;
                }
                else {
                    completionBlock(nil, error);
                }
                return;
            }
            
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
                NSInteger HTTPStatusCode = HTTPURLResponse.statusCode;
                
                // Properly handle HTTP error codes >= 400 as real errors
                if (HTTPStatusCode >= 400) {
                    NSError *HTTPError = [NSError errorWithDomain:SRGNetworkErrorDomain
                                                             code:SRGNetworkErrorHTTP
                                                         userInfo:@{ NSLocalizedDescriptionKey : [NSHTTPURLResponse srg_localizedStringForStatusCode:HTTPStatusCode],
                                                                     NSURLErrorKey : response.URL,
                                                                     SRGNetworkHTTPStatusCodeKey : @(HTTPStatusCode) }];
                    completionBlock(nil, HTTPError);
                    return;
                }
                // Block redirects and return an error with URL information. Currently no redirection is expected for services we use, this
                // means redirection is probably related to a public hotspot with login page (e.g. SBB)
                else if (HTTPStatusCode >= 300) {
                    NSMutableDictionary *userInfo = [@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"You are likely connected to a public wifi network with no Internet access", @"The error message when request a media or a media list on a public network with no Internet access (e.g. SBB)"),
                                                        NSURLErrorKey : response.URL } mutableCopy];
                    
                    NSString *redirectionURLString = HTTPURLResponse.allHeaderFields[@"Location"];
                    if (redirectionURLString) {
                        NSURL *redirectionURL = [NSURL URLWithString:redirectionURLString];
                        userInfo[SRGNetworkRedirectionURLKey] = redirectionURL;
                    }
                    
                    NSError *redirectError = [NSError errorWithDomain:SRGNetworkErrorDomain
                                                                 code:SRGNetworkErrorRedirect
                                                             userInfo:[userInfo copy]];
                    completionBlock(nil, redirectError);
                    return;
                }
            }
            
            completionBlock(data, nil);
        }];
    }
    return self;
}

- (instancetype)initWithJSONDictionaryRequest:(NSURLRequest *)request session:(NSURLSession *)session withCompletionBlock:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completionBlock
{
    return [self initWithRequest:request session:session withCompletionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        id JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (! JSONDictionary || ! [JSONDictionary isKindOfClass:[NSDictionary class]]) {
            completionBlock(nil, [NSError errorWithDomain:SRGNetworkErrorDomain
                                                     code:SRGNetworkErrorInvalidData
                                                 userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"The error message when the response from IL server is incorrect.") }]);
            return;
        }
        
        completionBlock(JSONDictionary, nil);
    }];
}

- (instancetype)initWithJSONArrayRequest:(NSURLRequest *)request session:(NSURLSession *)session withCompletionBlock:(void (^)(NSArray * _Nullable, NSError * _Nullable))completionBlock
{
    return [self initWithRequest:request session:session withCompletionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        id JSONArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (! JSONArray || ! [JSONArray isKindOfClass:[NSArray class]]) {
            completionBlock(nil, [NSError errorWithDomain:SRGNetworkErrorDomain
                                                     code:SRGNetworkErrorInvalidData
                                                 userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"The error message when the response from IL server is incorrect.") }]);
            return;
        }
        
        completionBlock(JSONArray, nil);
    }];
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return [self initWithRequest:[NSURLRequest new] session:[NSURLSession new] withCompletionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
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
