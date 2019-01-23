//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGPage.h"

@interface SRGPage ()

@property (nonatomic) NSUInteger size;
@property (nonatomic) NSUInteger number;
@property (nonatomic) NSURLRequest *URLRequest;

@end

@implementation SRGPage

#pragma mark Object lifecycle

- (instancetype)initWithSize:(NSUInteger)size number:(NSUInteger)number URLRequest:(NSURLRequest *)URLRequest
{
    if (self = [super init]) {
        self.number = MAX(number, 0);
        self.size = MAX(size, 1);
        self.URLRequest = URLRequest;
    }
    return self;
}

#pragma mark Equality

- (BOOL)isEqual:(id)object
{
    if (! [object isKindOfClass:self.class]) {
        return NO;
    }
    
    SRGPage *otherPage = object;
    return self.size == otherPage.size && self.number == otherPage.number && [self.URLRequest.URL isEqual:otherPage.URLRequest.URL];
}

- (NSUInteger)hash
{
    return [NSString stringWithFormat:@"%@_%@_%@", @(self.size), @(self.number), self.URLRequest.URL.absoluteString].hash;
}

#pragma mark NSCopying protocol

- (id)copyWithZone:(NSZone *)zone
{
    return [[self.class allocWithZone:zone] initWithSize:self.size number:self.number URLRequest:self.URLRequest];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; size = %@; number = %@; URL = %@>",
            self.class,
            self,
            @(self.size),
            @(self.number),
            self.URLRequest.URL];
}

@end
