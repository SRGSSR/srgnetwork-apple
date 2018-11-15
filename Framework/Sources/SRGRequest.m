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
@property (nonatomic, copy) SRGRequestCompletionBlock completionBlock;

@property (nonatomic) NSURLSession *session;
@property (nonatomic) SRGNetworkRequest *request;

@property (nonatomic, getter=isRunning) BOOL running;

@end

@implementation SRGRequest

#pragma mark Object lifecycle

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest session:(NSURLSession *)session completionBlock:(SRGRequestCompletionBlock)completionBlock
{
    if (self = [super init]) {
        self.URLRequest = URLRequest;
        self.completionBlock = completionBlock;
        self.session = session;
    }
    return self;
}

- (void)dealloc
{
    [self.request cancel];
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
    void (^requestCompletionBlock)(BOOL finished, NSDictionary * _Nullable, NSHTTPURLResponse * _Nullable HTTPResponse, NSError * _Nullable) = ^(BOOL finished, NSDictionary * _Nullable JSONDictionary, NSHTTPURLResponse * _Nullable HTTPResponse, NSError * _Nullable error) {
        if (finished) {
            self.completionBlock(JSONDictionary, HTTPResponse, error);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.running = NO;
        });
    };
    self.request = [[SRGNetworkRequest alloc] initWithJSONDictionaryURLRequest:self.URLRequest session:self.session options:SRGNetworkRequestOptionCancellationErrorsProcessed completionBlock:^(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *HTTPResponse = [response isKindOfClass:NSHTTPURLResponse.class] ? (NSHTTPURLResponse *)response : nil;
        if (error) {
            if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
                requestCompletionBlock(NO, nil, HTTPResponse, error);
            }
            else {
                requestCompletionBlock(YES, nil, HTTPResponse, error);
            }
            return;
        }
        
        requestCompletionBlock(YES, JSONDictionary, HTTPResponse, nil);
    }];
    
    self.running = YES;
    [self.request resume];
}

- (void)cancel
{
    self.running = NO;
    [self.request cancel];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; request = %@; running = %@>",
            self.class,
            self,
            self.request,
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
