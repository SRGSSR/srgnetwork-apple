//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGRequest.h"

#import "NSBundle+SRGNetwork.h"

#import <SRGNetwork/SRGNetwork.h>
#import <UIKit/UIKit.h>

static NSInteger s_numberOfRunningRequests = 0;
static void (^s_networkActivityManagementHandler)(BOOL) = nil;

@interface SRGRequest ()

@property (nonatomic) NSURLRequest *URLRequest;
@property (nonatomic, copy) void (^completionBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionTask *sessionTask;

@property (nonatomic) SRGRequestOptions options;

@property (nonatomic, getter=isRunning) BOOL running;

@end

@implementation SRGRequest

#pragma mark Class methods

+ (SRGRequest *)requestWithURLRequest:(NSURLRequest *)URLRequest session:(NSURLSession *)session options:(SRGRequestOptions)options completionBlock:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock
{
    return [[self.class alloc] initWithURLRequest:URLRequest session:session options:options completionBlock:completionBlock];
}

+ (SRGRequest *)JSONDictionaryRequestWithURLRequest:(NSURLRequest *)URLRequest session:(NSURLSession *)session options:(SRGRequestOptions)options completionBlock:(void (^)(NSDictionary * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionBlock
{
    return [self requestWithURLRequest:URLRequest session:session options:options completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, response, error);
            return;
        }
        
        id JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (! [JSONDictionary isKindOfClass:NSDictionary.class]) {
            completionBlock(nil, response, [NSError errorWithDomain:SRGNetworkErrorDomain
                                                               code:SRGNetworkErrorInvalidData
                                                           userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"Error message returned when a server response data is incorrect.") }]);
            return;
        }
        
        completionBlock(JSONDictionary, response, nil);
    }];
}

+ (SRGRequest *)JSONArrayRequestWithURLRequest:(NSURLRequest *)URLRequest session:(NSURLSession *)session options:(SRGRequestOptions)options completionBlock:(void (^)(NSArray * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionBlock
{
    return [self requestWithURLRequest:URLRequest session:session options:options completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, response, error);
            return;
        }
        
        id JSONArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (! [JSONArray isKindOfClass:NSArray.class]) {
            completionBlock(nil, response, [NSError errorWithDomain:SRGNetworkErrorDomain
                                                               code:SRGNetworkErrorInvalidData
                                                           userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"Error message returned when a server response data is incorrect.") }]);
            return;
        }
        
        completionBlock(JSONArray, response, nil);
    }];
}

#pragma mark Object lifecycle

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest session:(NSURLSession *)session options:(SRGRequestOptions)options completionBlock:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionBlock
{
    if (self = [super init]) {
        self.URLRequest = URLRequest;
        self.session = session;
        self.options = options;
        self.completionBlock = completionBlock;
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return [self initWithURLRequest:[NSURLRequest new] session:[NSURLSession new] options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing
    }];
}

#pragma clang diagnostic pop

- (void)dealloc
{
    [self.sessionTask cancel];
}

#pragma mark Getters and setters

- (void)setRunning:(BOOL)running
{
    if (running != _running) {
        if (running) {
            if (s_numberOfRunningRequests == 0) {
                s_networkActivityManagementHandler ? s_networkActivityManagementHandler(YES) : nil;
            }
            ++s_numberOfRunningRequests;
        }
        else {
            --s_numberOfRunningRequests;
            if (s_numberOfRunningRequests == 0) {
                s_networkActivityManagementHandler ? s_networkActivityManagementHandler(NO) : nil;
            }
        }
    }
    
    _running = running;
}

#pragma mark Session task management

- (void)resume
{
    if (self.running) {
        return;
    }
    
    // No weakify / strongify dance here, so that the request retains itself while it is running
    void (^completionBlock)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable) = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ((self.options & SRGNetworkRequestMainThreadCompletionEnabled) != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionBlock(data, response, error);
            });
        }
        else {
            self.completionBlock(data, response, error);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.running = NO;
        });
    };
    
    self.sessionTask = [self.session dataTaskWithRequest:self.URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
                if ((self.options & SRGRequestOptionCancellationErrorsEnabled) == 0) {
                    return;
                }
            }
            else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorServerCertificateUntrusted) {
                if ((self.options & SRGNetworkRequestPublicWiFiIssuesDisabled) == 0) {
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
                if ((self.options & SRGRequestOptionHTTPErrorsDisabled) == 0) {
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
    
    self.running = YES;
    [self.sessionTask resume];
}

- (void)cancel
{
    self.running = NO;
    [self.sessionTask cancel];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; URLRequest = %@; running = %@>",
            self.class,
            self,
            self.URLRequest,
            self.running ? @"YES" : @"NO"];
}

@end

@implementation SRGRequest (AutomaticNetworkActivityManagement)

#pragma mark Class methods

+ (void)enableNetworkActivityManagementWithHandler:(void (^)(BOOL))handler
{
    s_networkActivityManagementHandler = handler;
    handler(s_numberOfRunningRequests != 0);
}

+ (void)enableNetworkActivityIndicatorManagement
{
    [self enableNetworkActivityManagementWithHandler:^(BOOL active) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = active;
    }];
}

+ (void)disableNetworkActivityManagement
{
    s_networkActivityManagementHandler ? s_networkActivityManagementHandler(NO) : nil;
    s_networkActivityManagementHandler = nil;
}

@end
