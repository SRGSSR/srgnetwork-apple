//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SRGNetworkRequestOptions) {
    SRGNetworkRequestOptionIgnoreCancellationErrors = (1UL << 0),
    SRGNetworkRequestOptionIgnoreHTTPErrors = (1UL << 0),
};

@interface SRGNetworkRequest : NSObject

- (instancetype)initWithRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response,  NSError * _Nullable error))completionBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithJSONDictionaryRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;
- (instancetype)initWithJSONArrayRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSArray * _Nullable JSONArray, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (void)resume;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
