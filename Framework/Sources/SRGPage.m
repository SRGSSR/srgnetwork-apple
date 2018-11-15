//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGPage.h"

#import "SRGNetworkLogger.h"

#import <libextobjc/libextobjc.h>

const NSInteger SRGPageDefaultSize = 10;
const NSInteger SRGPageMaximumSize = 100;
const NSInteger SRGPageUnlimitedSize = NSIntegerMax;

@interface SRGPage ()

@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger number;
@property (nonatomic) NSURL *URL;

@end

@implementation SRGPage

#pragma mark Class methods

+ (NSURLRequest *)request:(NSURLRequest *)request withPage:(SRGPage *)page
{
    if (page.URL) {
        NSURL *nextPageURL = page.URL;
        if (! [page.URL.host isEqualToString:request.URL.host]) {
            NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:page.URL resolvingAgainstBaseURL:NO];
            URLComponents.host = request.URL.host;
            nextPageURL = URLComponents.URL;
        }
        
        NSMutableURLRequest *pageRequest = [NSMutableURLRequest requestWithURL:nextPageURL];
        [request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, NSString * _Nonnull value, BOOL * _Nonnull stop) {
            [pageRequest setValue:value forHTTPHeaderField:field];
        }];
        return [pageRequest copy];
    }
    else {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
        NSString *pageSize = (page.size != SRGPageUnlimitedSize) ? @(page.size).stringValue : @"unlimited";
        NSMutableArray *queryItems = [NSMutableArray arrayWithObject:[NSURLQueryItem queryItemWithName:@"pageSize" value:pageSize]];
        if (URLComponents.queryItems) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", @keypath(NSURLQueryItem.new, name), @"pageSize"];
            NSArray<NSURLQueryItem *> *originalQueryItems = [URLComponents.queryItems filteredArrayUsingPredicate:predicate];
            [queryItems addObjectsFromArray:originalQueryItems];
        }
        URLComponents.queryItems = [queryItems copy];
        
        NSMutableURLRequest *sizeRequest = [request mutableCopy];
        sizeRequest.URL = URLComponents.URL;
        return [sizeRequest copy];
    }
}

+ (SRGPage *)firstPageWithSize:(NSInteger)size
{
    return [[self.class alloc] initWithSize:size number:0 URL:nil];
}

#pragma mark Object lifecycle

- (SRGPage *)initWithSize:(NSInteger)size number:(NSInteger)number URL:(NSURL *)URL
{
    if (size < 1) {
        SRGNetworkLogWarning(@"page", @"The minimum page size is 1. This minimum value will be used.");
        size = 1;
    }
    else if (size > SRGPageMaximumSize && size != SRGPageUnlimitedSize) {
        SRGNetworkLogWarning(@"page", @"The maximum page size for this request is %@. This maximum value will be used.", @(SRGPageMaximumSize));
        size = SRGPageMaximumSize;
    }
    
    if (self = [super init]) {
        self.number = MAX(number, 0);
        self.URL = URL;
        self.size = size;
    }
    return self;
}

#pragma mark Helpers

- (SRGPage *)nextPageWithURL:(NSURL *)URL
{
    return [[self.class alloc] initWithSize:self.size number:self.number + 1 URL:URL];
}

- (SRGPage *)firstPage
{
    return [[self.class alloc] initWithSize:self.size number:0 URL:nil];
}

#pragma mark Equality

- (BOOL)isEqual:(id)object
{
    if (! [object isKindOfClass:self.class]) {
        return NO;
    }
    
    SRGPage *otherPage = object;
    return self.size == otherPage.size && self.number == otherPage.number && (self.URL == otherPage.URL || [self.URL isEqual:otherPage.URL]);
}

- (NSUInteger)hash
{
    return [NSString stringWithFormat:@"%@_%@_%@", @(self.size), @(self.number), self.URL.absoluteString].hash;
}

#pragma mark NSCopying protocol

- (id)copyWithZone:(NSZone *)zone
{
    return [[self.class allocWithZone:zone] initWithSize:self.size number:self.number URL:self.URL];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; size = %@; number = %@; URL = %@>",
            self.class,
            self,
            self.size == SRGPageUnlimitedSize ? @"unlimited" : @(self.size),
            @(self.number),
            self.URL];
}

@end
