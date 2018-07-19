//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRGNetworkRequest : NSObject

- (instancetype)initWithRequest:(NSURLRequest *)request session:(NSURLSession *)session completionBlock:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completionBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithJSONDictionaryRequest:(NSURLRequest *)request session:(NSURLSession *)session completionBlock:(void (^)(NSDictionary * _Nullable JSONDictionary, NSError * _Nullable error))completionBlock;
- (instancetype)initWithJSONArrayRequest:(NSURLRequest *)request session:(NSURLSession *)session completionBlock:(void (^)(NSArray * _Nullable JSONArray, NSError * _Nullable error))completionBlock;

- (void)resume;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
