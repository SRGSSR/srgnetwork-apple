//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGRequestQueue.h"

#import "NSBundle+SRGNetwork.h"
#import "SRGNetworkError.h"
#import "SRGNetworkLogger.h"

#import <libextobjc/libextobjc.h>
#import <MAKVONotificationCenter/MAKVONotificationCenter.h>

static NSMapTable<SRGRequestQueue *, NSHashTable<SRGBaseRequest *> *> *s_relationshipTable = nil;

@interface SRGRequestQueue ()

@property (nonatomic) SRGRequestQueueOptions options;

@property (nonatomic, readonly) NSSet<SRGBaseRequest *> *requests;
@property (nonatomic, copy) void (^stateChangeBlock)(BOOL running, NSError *error);
@property (nonatomic) NSMutableArray<NSError *> *errors;
@property (nonatomic, getter=isRunning) BOOL running;

@end

@implementation SRGRequestQueue

@synthesize running = _running;

#pragma mark Class methods

+ (void)initialize
{
    if (self != SRGRequestQueue.class) {
        return;
    }
    
    s_relationshipTable = [NSMapTable mapTableWithKeyOptions:NSHashTableWeakMemory
                                                valueOptions:NSHashTableStrongMemory];
}

#pragma mark Object lifecycle

- (instancetype)initWithStateChangeBlock:(void (^)(BOOL, NSError *))stateChangeBlock
{
    if (self = [super init]) {
        self.errors = [NSMutableArray array];
        self.stateChangeBlock = stateChangeBlock;
        [s_relationshipTable setObject:[NSHashTable hashTableWithOptions:NSHashTableWeakMemory] forKey:self];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithStateChangeBlock:nil];
}

- (void)dealloc
{
    for (SRGBaseRequest *request in self.requests) {
        [request cancel];
    }
    
    [s_relationshipTable removeObjectForKey:self];
}

#pragma mark Getters and setters

- (NSArray<SRGBaseRequest *> *)requests
{
    return [s_relationshipTable objectForKey:self].copy;
}

#pragma mark Options

- (SRGRequestQueue *)requestQueueWithOptions:(SRGRequestQueueOptions)options
{
    SRGRequestQueue *requestQueue = [[self.class alloc] initWithStateChangeBlock:self.stateChangeBlock];
    requestQueue.options = options;
    return requestQueue;
}

#pragma mark Request management

- (void)addRequest:(SRGBaseRequest *)request resume:(BOOL)resume
{
    NSHashTable<SRGBaseRequest *> *requests = [s_relationshipTable objectForKey:self];
    if ([requests containsObject:request]) {
        return;
    }
    [requests addObject:request];
    
    @weakify(self)
    [request addObserver:self keyPath:@keypath(request, running) options:NSKeyValueObservingOptionNew block:^(MAKVONotification *notification) {
        @strongify(self)
        
        [self checkStateChange];
    }];
    
    if (resume) {
        [request resume];
    }
    
    [self checkStateChange];
}

- (void)resume
{
    for (SRGBaseRequest *request in self.requests) {
        [request resume];
    }
}

- (void)cancel
{
    for (SRGBaseRequest *request in self.requests) {
        [request cancel];
    }
}

- (void)reportError:(NSError *)error
{
    if (! error) {
        return;
    }
    
    if (! self.running) {
        SRGNetworkLogInfo(@"Request Queue", @"The error %@ was reported to a non-running queue and will therefore be lost.", error);
        return;
    }
    
    [self.errors addObject:error];
    
    if ((self.options & SRGRequestQueueOptionAutomaticCancellationOnErrorEnabled) != 0) {
        [self cancel];
    }
}

#pragma mark State management

- (void)checkStateChange
{
    // Running iff at least one request is running
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == YES", @keypath(SRGBaseRequest.new, running)];
    BOOL running = ([self.requests.allObjects filteredArrayUsingPredicate:predicate].count != 0);
    if (running != self.running) {
        self.running = running;
        
        if (running) {
            [self.errors removeAllObjects];
            
            SRGNetworkLogDebug(@"Request Queue", @"Started %@", self);
            
            if (NSThread.isMainThread) {
                self.stateChangeBlock ? self.stateChangeBlock(NO, nil) : nil;
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.stateChangeBlock ? self.stateChangeBlock(NO, nil) : nil;
                });
            }
        }
        else {
            NSError *error = (self.errors.count <= 1) ? self.errors.firstObject : [NSError errorWithDomain:SRGNetworkErrorDomain
                                                                                                      code:SRGNetworkErrorMultiple
                                                                                                  userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"Several errors have been encountered", @"The main error message if multiple errors have been encountered. Finally, the developer could should which one to display, and not show this message."),
                                                                                                              SRGNetworkErrorsKey : self.errors }];
            
            SRGNetworkLogDebug(@"Request Queue", @"Ended %@ with error: %@", self, error);
            
            if (NSThread.isMainThread) {
                self.stateChangeBlock ? self.stateChangeBlock(YES, error) : nil;
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.stateChangeBlock ? self.stateChangeBlock(YES, error) : nil;
                });
            }
        }
    }
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; requests = %@; running = %@>",
            self.class,
            self,
            self.requests,
            self.running ? @"YES" : @"NO"];
}

@end
