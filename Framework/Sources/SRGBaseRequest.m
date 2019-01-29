//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGBaseRequest.h"

#import "NSBundle+SRGNetwork.h"
#import "NSHTTPURLResponse+SRGNetwork.h"
#import "SRGNetworkActivityManagement+Private.h"
#import "SRGBaseRequest+Subclassing.h"
#import "SRGNetworkError.h"

@interface SRGBaseRequest ()

@property (nonatomic) NSURLRequest *URLRequest;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) SRGRequestOptions options;
@property (nonatomic, copy) SRGResponseParser parser;
@property (nonatomic, copy) SRGObjectExtractor extractor;
@property (nonatomic, copy) SRGObjectCompletionBlock completionBlock;

@property (nonatomic) NSURLSessionTask *sessionTask;

@property (nonatomic, getter=isRunning) BOOL running;

@end

@implementation SRGBaseRequest

#pragma mark Object lifecycle

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                            parser:(SRGResponseParser)parser
                         extractor:(SRGObjectExtractor)extractor
                   completionBlock:(SRGObjectCompletionBlock)completionBlock
{
    if (self = [super init]) {
        self.URLRequest = URLRequest;
        self.session = session;
        self.parser = parser;
        self.extractor = extractor;
        self.completionBlock = completionBlock;
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return [self initWithURLRequest:[NSURLRequest new] session:[NSURLSession new] parser:nil extractor:nil completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
        _running = running;
        
        if (running) {
            [SRGNetworkActivityManagement increaseNumberOfRunningRequests];
        }
        else {
            [SRGNetworkActivityManagement decreaseNumberOfRunningRequests];
        }
    }
}

#pragma mark Overrides

- (SRGBaseRequest *)requestWithOptions:(SRGRequestOptions)options
{
    SRGBaseRequest *request = [[self.class alloc] initWithURLRequest:self.URLRequest
                                                             session:self.session
                                                              parser:self.parser
                                                           extractor:self.extractor
                                                     completionBlock:self.completionBlock];
    request.options = options;
    return request;
}

#pragma mark Session task management

- (void)resume
{
    if (self.running) {
        return;
    }
    
    // No weakify / strongify dance here, so that the request retains itself while it is running
    void (^completionBlock)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable) = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            self.extractor ? self.extractor(data, response) : nil;
        }
        
        if ((self.options & SRGNetworkRequestBackgroundThreadCompletionEnabled) == 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.completionBlock(data, response, error);
            });
        }
        else {
            self.completionBlock(data, response, error);
        }
        
        self.running = NO;
    };
    
    self.sessionTask = [self.session dataTaskWithRequest:self.URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
                if ((self.options & SRGRequestOptionCancellationErrorsEnabled) == 0) {
                    return;
                }
            }
            else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorServerCertificateUntrusted) {
                if ((self.options & SRGNetworkOptionFriendlyWiFiMessagesDisabled) == 0) {
                    NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                    userInfo[NSLocalizedDescriptionKey] = SRGNetworkLocalizedString(@"You are likely connected to a public WiFi network with no Internet access", @"The error message when request a media or a media list on a public network with no Internet access (e.g. SBB)");
                    
                    NSError *publicWiFiError = [NSError errorWithDomain:error.domain
                                                                   code:error.code
                                                               userInfo:[userInfo copy]];
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
        
        if (data) {
            NSError *parsingError = nil;
            id object = self.parser ? self.parser(data, &parsingError) : data;
            if (parsingError) {
                NSError *error = [NSError errorWithDomain:SRGNetworkErrorDomain
                                                     code:SRGNetworkErrorInvalidData
                                                 userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"Error message returned when a server response data is incorrect."),
                                                             NSUnderlyingErrorKey : parsingError }];
                completionBlock(nil, response, error);
                return;
            }
            
            completionBlock(object, response, nil);
        }
        else {
            completionBlock(nil, response, nil);
        }
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
