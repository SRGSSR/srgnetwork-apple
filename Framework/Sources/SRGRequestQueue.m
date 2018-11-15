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

static NSMapTable<SRGRequestQueue *, NSHashTable<SRGRequest *> *> *s_relationshipTable = nil;

@interface SRGRequestQueue ()

@property (nonatomic, readonly) NSSet<SRGRequest *> *requests;
@property (nonatomic, copy) void (^stateChangeBlock)(BOOL running, NSError *error);
@property (nonatomic) NSMutableArray<NSError *> *errors;
@property (nonatomic, getter=isRunning) BOOL running;

@end

@implementation SRGRequestQueue

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
    for (SRGRequest *request in self.requests) {
        [request cancel];
    }
    
    [s_relationshipTable removeObjectForKey:self];
}

#pragma mark Getters and setters

- (NSArray<SRGRequest *> *)requests
{
    return [[s_relationshipTable objectForKey:self] copy];
}

#pragma mark Request management

- (void)addRequest:(SRGRequest *)request resume:(BOOL)resume
{
    @weakify(self)
    [request addObserver:self keyPath:@keypath(request, running) options:NSKeyValueObservingOptionNew block:^(MAKVONotification *notification) {
        @strongify(self)
        [self checkStateChange];
    }];
    
    NSHashTable<SRGRequest *> *requests = [s_relationshipTable objectForKey:self];
    [requests addObject:request];
    
    if (resume) {
        [request resume];
    }
    
    [self checkStateChange];
}

- (void)resume
{
    for (SRGRequest *request in self.requests) {
        [request resume];
    }
}

- (void)cancel
{
    for (SRGRequest *request in self.requests) {
        [request cancel];
    }
}

- (void)reportError:(NSError *)error
{
    if (! error) {
        return;
    }
    
    if (! self.running) {
        SRGNetworkLogWarning(@"Request Queue", @"The error %@ was reported to a non-running queue and will therefore be lost.", error);
        return;
    }
    
    [self.errors addObject:error];
}

- (NSError *)consolidatedError
{
    if (self.errors.count <= 1) {
        return self.errors.firstObject;
    }
    else {
        return [NSError errorWithDomain:SRGNetworkErrorDomain
                                   code:SRGNetworkErrorMultiple
                               userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"Several errors have been encountered", @"The main error message if multiple errors have been encountered. Finally, the developer could should which one to display, and not show this message."),
                                           SRGNetworkErrorsKey : self.errors }];
    }
}

#pragma mark State management

- (void)checkStateChange
{
    // Running iff at least one request is running
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == YES", @keypath(SRGRequest.new, running)];
    BOOL running = ([self.requests.allObjects filteredArrayUsingPredicate:predicate].count != 0);
    
    if (running != self.running) {
        self.running = running;
        
        if (running) {
            [self.errors removeAllObjects];
            SRGNetworkLogDebug(@"Request Queue", @"Started %@", self);
            self.stateChangeBlock ? self.stateChangeBlock(NO, nil) : nil;
        }
        else {
            NSError *error = [self consolidatedError];
            SRGNetworkLogDebug(@"Request Queue", @"Ended %@ with error: %@", self, error);
            self.stateChangeBlock ? self.stateChangeBlock(YES, error) : nil;
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
